/*
SUMMARY: Module to deploy the Hub Network and it's components based on the Azure Mission Landing Zone conceptual architecture
DESCRIPTION: The following components will be options in this deployment
              Hub Virtual Network (Vnet)
              Subnets
              Route Table
              Network Security Group
              Log Storage
              Private Link
              Azure Firewall
              Public IPs
              Private DNS Zones - Details of all the Azure Private DNS zones can be found here --> https://docs.microsoft.com/en-us/azure/private-link/private-endpoint-dns#azure-services-dns-zone-configuration
              DDos Standard Plan (optional)
PREREQS: Logging
AUTHOR/S: jspinella

*/

/*
Copyright (c) Microsoft Corporation. Licensed under the MIT license.
*/

targetScope = 'subscription'

// REQUIRED PARAMETERS

@description('Prefix value which will be prepended to all resource names. Default: anoa')
param parOrgPrefix string = 'anoa'

@description('The subscription ID for the Hub Network and resources. It defaults to the deployment subscription.')
param parHubSubscriptionId string = subscription().subscriptionId

@description('The region to deploy resources into. It defaults to the deployment location.')
param parLocation string = deployment().location

@description('Tags for the Hub Network')
param parTags object

@minLength(3)
@maxLength(15)
@description('A suffix, 3 to 15 characters in length, to append to resource names (e.g. "dev", "test", "prod", "platforms"). It defaults to "platforms".')
param parDeployEnvironment string

// RESOURCE NAMING PARAMETERS

@description('A suffix to use for naming deployments uniquely. It defaults to the Bicep resolution of the "utcNow()" function.')
param parDeploymentNameSuffix string = utcNow()

// NETWORK ADDRESS SPACE PARAMETERS

@description('The CIDR Virtual Network Address Prefix for the Hub Virtual Network.')
param parHubVirtualNetworkAddressPrefix string = '10.0.100.0/24'

@description('The CIDR Subnet Address Prefix for the default Hub subnet. It must be in the Hub Virtual Network space.')
param parHubSubnetAddressPrefix string = '10.0.100.128/27'

// FIREWALL PARAMETERS

@description('Switch which allows Azure Firewall deployment to be disabled. Default: true')
param parAzureFirewallEnabled bool = true

@description('Azure Firewall Tier associated with the Firewall to deploy. Default: Standard ')
@allowed([
  'Standard'
  'Premium'
])
param parFirewallSkuTier string

@description('Supernet CIDR address for the entire network of vnets, this address allows for communication between spokes. Recommended to use a Supernet calculator if modifying vnet addresses')
param parFirewallSupernetIPAddress string = '10.0.96.0/19'

@allowed([
  'Alert'
  'Deny'
  'Off'
])
param parFirewallThreatIntelMode string

@allowed([
  'Alert'
  'Deny'
  'Off'
])
@description('[Alert/Deny/Off] The Azure Firewall Intrusion Detection mode. Valid values are "Alert", "Deny", or "Off". The default value is "Alert".')
param parFirewallIntrusionDetectionMode string = 'Alert'

@description('An array of Firewall Diagnostic Logs categories to collect. See "https://docs.microsoft.com/en-us/azure/firewall/firewall-diagnostics#enable-diagnostic-logging-through-the-azure-portal" for valid values.')
param parFirewallDiagnosticsLogs array = [
  'AzureFirewallApplicationRule'
  'AzureFirewallNetworkRule'
  'AzureFirewallDnsProxy'
]

@description('An array of Firewall Diagnostic Metrics categories to collect. See "https://docs.microsoft.com/en-us/azure/firewall/firewall-diagnostics#enable-diagnostic-logging-through-the-azure-portal" for valid values.')
param parFirewallDiagnosticsMetrics array = [
  'AllMetrics'
]

@description('An array of Azure Firewall Public IP Address Availability Zones. It defaults to empty, or "No-Zone", because Availability Zones are not available in every cloud. See https://docs.microsoft.com/en-us/azure/virtual-network/ip-services/public-ip-addresses#sku for valid settings.')
param parFirewallClientPublicIPAddressAvailabilityZones array = []

@description('An array of Azure Firewall Public IP Address Availability Zones. It defaults to empty, or "No-Zone", because Availability Zones are not available in every cloud. See https://docs.microsoft.com/en-us/azure/virtual-network/ip-services/public-ip-addresses#sku for valid settings.')
param parFirewallManagementPublicIPAddressAvailabilityZones array = []

@description('An array of Azure Firewall Policy Rules.')
param parFirewallPolicyRuleCollectionGroups array = [
  {
    name: 'DefaultApplicationRuleCollectionGroup'
    priority: 300
    ruleCollections: [
      {
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        action: {
          type: 'Allow'
        }
        rules: [
          {
            ruleType: 'ApplicationRule'
            name: 'msftauth'
            protocols: [
              {
                protocolType: 'Https'
                port: 443
              }
            ]
            fqdnTags: []
            webCategories: []
            targetFqdns: [
              'aadcdn.msftauth.net'
              'aadcdn.msauth.net'
            ]
            targetUrls: []
            terminateTLS: false
            sourceAddresses: [
              '*'
            ]
            destinationAddresses: []
            sourceIpGroups: []
          }
        ]
        name: 'AzureAuth'
        priority: 110
      }
    ]
  }
  {
    name: 'DefaultNetworkRuleCollectionGroup'
    priority: 200
    ruleCollections: [
      {
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        action: {
          type: 'Allow'
        }
        rules: [
          {
            ruleType: 'NetworkRule'
            name: 'AzureCloud'
            ipProtocols: [
              'Any'
            ]
            sourceAddresses: [
              '*'
            ]
            sourceIpGroups: []
            destinationAddresses: [
              'AzureCloud'
            ]
            destinationIpGroups: []
            destinationFqdns: []
            destinationPorts: [
              '*'
            ]
          }
        ]
        name: 'AllowAzureCloud'
        priority: 100
      }
      {
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        action: {
          type: 'Allow'
        }
        rules: [
          {
            ruleType: 'NetworkRule'
            name: 'AllSpokeTraffic'
            ipProtocols: [
              'Any'
            ]
            sourceAddresses: [
              parFirewallSupernetIPAddress
            ]
            sourceIpGroups: []
            destinationAddresses: [
              '*'
            ]
            destinationIpGroups: []
            destinationFqdns: []
            destinationPorts: [
              '*'
            ]
          }
        ]
        name: 'AllowTrafficBetweenSpokes'
        priority: 200
      }
    ]
  }
]

// HUB NETWORK PARAMETERS

@description('An array of required subnets for the Hub Virtual Network')
param parHubSubnets array = []

@description('An array of Network Diagnostic Logs to enable for the Hub Virtual Network. See https://docs.microsoft.com/en-us/azure/azure-monitor/essentials/diagnostic-settings?tabs=CMD#logs for valid settings.')
param parHubVirtualNetworkDiagnosticsLogs array = []

@description('An array of Network Diagnostic Metrics to enable for the Hub Virtual Network. See https://docs.microsoft.com/en-us/azure/azure-monitor/essentials/diagnostic-settings?tabs=CMD#metrics for valid settings.')
param parHubVirtualNetworkDiagnosticsMetrics array = []

@description('An array of Network Security Group Rules to apply to the Hub Virtual Network. See https://docs.microsoft.com/en-us/azure/templates/microsoft.network/networksecuritygroups/securityrules?tabs=bicep#securityrulepropertiesformat for valid settings.')
param parHubNetworkSecurityGroupRules array = []

@description('An array of Network Security Group diagnostic logs to apply to the Hub Virtual Network. See https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-nsg-manage-log#log-categories for valid settings.')
param parHubNetworkSecurityGroupDiagnosticsLogs array = [
  'NetworkSecurityGroupEvent'
  'NetworkSecurityGroupRuleCounter'
]

@description('An array of Service Endpoints to enable for the Hub subnet. See https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-service-endpoints-overview for valid settings.')
param parHubSubnetServiceEndpoints array = [
  {
    service: 'Microsoft.Storage'
  }
]

// ROUTETABLE PARAMETERS

param parDisableBgpRoutePropagation bool = false

// PRIVATE DNS ZONE PARAMETERS

@description('Switch to Enable Private DNS Zones to create for the Hub Virtual Network. See https://docs.microsoft.com/en-us/azure/templates/microsoft.network/privatednszones?tabs=bicep for valid settings.')
param parEnablePrivateDnsZones bool = false

// LOGGING PARAMETERS

@description('The Storage Account SKU to use for log storage. It defaults to "Standard_GRS". See https://docs.microsoft.com/en-us/rest/api/storagerp/srp_sku_types for valid settings.')
param parLogStorageSkuName string = 'Standard_GRS'

@description('Log Analytics Workspace Resource Id Needed for NSG, VNet and Activity Logging')
param parLogAnalyticsWorkspaceResourceId string

@description('Log Analytics Workspace Name Needed Activity Logging')
param parLogAnalyticsWorkspaceName string

@description('An array of Public IP Address Diagnostic Logs for the Azure Firewall. See https://docs.microsoft.com/en-us/azure/ddos-protection/diagnostic-logging?tabs=DDoSProtectionNotifications#configure-ddos-diagnostic-logs for valid settings.')
param parPublicIPAddressDiagnosticsLogs array = [
  'DDoSProtectionNotifications'
  'DDoSMitigationFlowLogs'
  'DDoSMitigationReports'
]

@description('An array of Public IP Address Diagnostic Metrics for the Azure Firewall. See https://docs.microsoft.com/en-us/azure/ddos-protection/diagnostic-logging?tabs=DDoSProtectionNotifications for valid settings.')
param parPublicIPAddressDiagnosticsMetrics array = [
  'AllMetrics'
]

//DDOS PARAMETERS

@description('Switch which allows DDOS deployment to be disabled. Default: false')
param parDeployddosProtectionPlan bool = false

// SUPPORTED CLOUDS PARAMETERS

param parSupportedClouds array = [
  'AzureCloud'
  'AzureUSGovernment'
]

// STORAGE ACCOUNTS RBAC
@description('Account for access to Storage')
param parHubStorageAccountAccess object

// RESOURCE LOCKS
@description('Switch which allows enable resource locks on all resources. Default: true')
param parEnableResourceLocks bool = true

/*
  NAMING CONVENTION
  Here we define a naming conventions for resources.
  First, we take `parDeployEnvironment` and `parDeployEnvironment` by params.
  Then, using string interpolation "${}", we insert those values into a naming convention.
*/

var varResourceToken = 'resource_token'
var varNameToken = 'name_token'
var varNamingConvention = '${toLower(parOrgPrefix)}-${toLower(parLocation)}-${toLower(parDeployEnvironment)}-${varNameToken}-${toLower(varResourceToken)}'

// RESOURCE NAME CONVENTIONS WITH ABBREVIATIONS

var varNetworkSecurityGroupNamingConvention = replace(varNamingConvention, varResourceToken, 'nsg')
var varFirewallNamingConvention = replace(varNamingConvention, varResourceToken, 'afw')
var varFirewallPolicyNamingConvention = replace(varNamingConvention, varResourceToken, 'afwp')
var varResourceGroupNamingConvention = replace(varNamingConvention, varResourceToken, 'rg')
var varStorageAccountNamingConvention = toLower('${parOrgPrefix}st${varNameToken}unique_storage_token')
var varSubnetNamingConvention = replace(varNamingConvention, varResourceToken, 'snet')
var varPublicIpAddressNamingConvention = replace(varNamingConvention, varResourceToken, 'pip')
var varVirtualNetworkNamingConvention = replace(varNamingConvention, varResourceToken, 'vnet')
var varDdosNamingConvention = replace(varNamingConvention, varResourceToken, 'ddos')
var varPrivateDNSZoneNamingConvention = replace(varNamingConvention, varResourceToken, 'pdz-rg')

// HUB NAMES

var varHubName = 'hub'
var varHubShortName = 'hub'
var varHubResourceGroupName = replace(varResourceGroupNamingConvention, varNameToken, varHubName)
var varhubLogStorageAccountShortName = replace(varStorageAccountNamingConvention, varNameToken, varHubShortName)
var varHubLogStorageAccountUniqueName = replace(varhubLogStorageAccountShortName, 'unique_storage_token', uniqueString(parHubSubscriptionId, parDeployEnvironment, parOrgPrefix))
var varHubLogStorageAccountName = take(varHubLogStorageAccountUniqueName, 23)
var varHubVirtualNetworkName = replace(varVirtualNetworkNamingConvention, varNameToken, varHubName)
var varHubNetworkSecurityGroupName = replace(varNetworkSecurityGroupNamingConvention, varNameToken, varHubName)
var varHubSubnetName = replace(varSubnetNamingConvention, varNameToken, varHubName)
var varHubPDZResourceGroupName = replace(varPrivateDNSZoneNamingConvention, varNameToken, varHubName)
var hubddosName = replace(varDdosNamingConvention, varNameToken, varHubName)

// FIREWALL NAMES

var varFirewallName = replace(varFirewallNamingConvention, varNameToken, varHubName)
var varFirewallPolicyName = replace(varFirewallPolicyNamingConvention, varNameToken, varHubName)
var varFirewallClientPublicIPAddressName = replace(varPublicIpAddressNamingConvention, varNameToken, 'afw-client')
var varFirewallManagementPublicIPAddressName = replace(varPublicIpAddressNamingConvention, varNameToken, 'afw-mgmt')

// FIREWALL VALUES

var varFirewallPublicIPAddressSkuName = 'Standard'
var varFirewallPublicIpAllocationMethod = 'Static'

// ROUTETABLE VALUES
var varRouteTableName = '${varHubSubnetName}-routetable'

// TAGS

@description('Resource group tags')
module modTags '../../../Modules/Microsoft.Resources/tags/az.resources.tags.bicep' = {
  name: 'deploy-${varHubShortName}-tags-${parLocation}-${parDeploymentNameSuffix}'
  params: {
    tags: parTags
  }
}

// RESOURCE GROUPS

module modHubResourceGroup '../../../Modules/Microsoft.Resources/resourceGroups/az.resource.groups.bicep' = {
  name: 'deploy-hub-rg-${parLocation}-${parDeploymentNameSuffix}'
  scope: subscription(parHubSubscriptionId)
  params: {
    name: varHubResourceGroupName
    location: parLocation
    tags: modTags.outputs.tags
  }
}

// Create Private DNS Zone Resource Group - optional
module modPrivateDnsZonesResourceGroup '../../../Modules/Microsoft.Resources/resourceGroups/az.resource.groups.bicep' = if (parEnablePrivateDnsZones) {
  name: 'deploy-pdz-rg-${parLocation}-${parDeploymentNameSuffix}'
  scope: subscription(parHubSubscriptionId)
  params: {
    name: varHubPDZResourceGroupName
    location: parLocation
    tags: modTags.outputs.tags
  }
}

// HUB STORAGE - VDSS

module modHubLogStorage '../../../Modules/Microsoft.Storage/storageAccounts/az.data.storage.bicep' = {
  name: 'deploy-hub-logStorage-${parLocation}-${parDeploymentNameSuffix}'
  scope: resourceGroup(parHubSubscriptionId, varHubResourceGroupName)
  params: {
    name: varHubLogStorageAccountName
    location: parLocation
    storageAccountSku: parLogStorageSkuName
    tags: modTags.outputs.tags
    roleAssignments: (parHubStorageAccountAccess.enableRoleAssignmentForStorageAccount) ? [
      {
        principalIds: parHubStorageAccountAccess.principalIds
        roleDefinitionIdOrName: parHubStorageAccountAccess.roleDefinitionIdOrName
      }
    ] : []
    lock: parEnableResourceLocks ? 'CanNotDelete' : ''
  }
  dependsOn: [
    modHubResourceGroup
  ]
}

// HUB NSG - VDSS

module modHubNetworkSecurityGroup '../../../Modules/Microsoft.Network/networkSecurityGroups/az.net.network.security.group.with.diagnostics.bicep' = {
  name: 'deploy-hub-networkSecurityGroup-${parLocation}-${parDeploymentNameSuffix}'
  scope: resourceGroup(parHubSubscriptionId, varHubResourceGroupName)
  params: {
    name: varHubNetworkSecurityGroupName
    location: parLocation
    tags: modTags.outputs.tags

    securityRules: parHubNetworkSecurityGroupRules

    diagnosticWorkspaceId: parLogAnalyticsWorkspaceResourceId
    diagnosticStorageAccountId: modHubLogStorage.outputs.resourceId

    diagnosticLogCategoriesToEnable: parHubNetworkSecurityGroupDiagnosticsLogs
    lock: parEnableResourceLocks ? 'CanNotDelete' : ''
  }
}

// HUB VNET - VDSS

module modHubVirtualNetwork '../../../Modules/Microsoft.Network/virtualNetworks/az.net.virtual.network.with.diagnostics.bicep' = {
  name: 'deploy-hub-vnet-${parLocation}-${parDeploymentNameSuffix}'
  scope: resourceGroup(parHubSubscriptionId, varHubResourceGroupName)
  params: {
    name: varHubVirtualNetworkName
    location: parLocation
    tags: modTags.outputs.tags

    addressPrefixes: [
      parHubVirtualNetworkAddressPrefix
    ]

    subnets: parHubSubnets

    diagnosticWorkspaceId: parLogAnalyticsWorkspaceResourceId
    diagnosticStorageAccountId: modHubLogStorage.outputs.resourceId

    diagnosticLogCategoriesToEnable: parHubVirtualNetworkDiagnosticsLogs
    diagnosticMetricsToEnable: parHubVirtualNetworkDiagnosticsMetrics
    ddosProtectionPlanEnabled: parDeployddosProtectionPlan
    ddosProtectionPlanId: hubddosName
    lock: parEnableResourceLocks ? 'CanNotDelete' : ''
  }
}

module modHubRouteTable '../../../Modules/Microsoft.Network/routeTable/az.net.route.table.bicep' = {
  name: 'deploy-hub-routeTable-${parLocation}-${parDeploymentNameSuffix}'
  scope: resourceGroup(parHubSubscriptionId, varHubResourceGroupName)
  params: {
    name: varRouteTableName
    location: parLocation
    tags: modTags.outputs.tags

    routes: [
      {
        name: 'default_route'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopIpAddress: modAzureFirewall.outputs.privateIp
          nextHopType: 'VirtualAppliance'
        }
      }
    ]
    disableBgpRoutePropagation: parDisableBgpRoutePropagation
    lock: parEnableResourceLocks ? 'CanNotDelete' : ''
  }
  dependsOn: [
    modHubResourceGroup
  ]
}

// HUB SUBNET - VDSS

module modHubSubnet '../../../Modules/Microsoft.Network/virtualNetworks/subnets/az.net.subnet.bicep' = {
  name: 'deploy-hub-subnet-${parLocation}-${parDeploymentNameSuffix}'
  scope: resourceGroup(parHubSubscriptionId, varHubResourceGroupName)
  params: {
    addressPrefix: parHubSubnetAddressPrefix
    networkSecurityGroupId: modHubNetworkSecurityGroup.outputs.resourceId
    name: varHubSubnetName
    routeTableId: modHubRouteTable.outputs.resourceId
    serviceEndpoints: parHubSubnetServiceEndpoints
    virtualNetworkName: modHubVirtualNetwork.outputs.name
    privateEndpointNetworkPolicies: 'Disabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
  dependsOn: [
    modHubVirtualNetwork
    modAzureFirewall
  ]
}

// HUB FW - CLIENT - VDSS

module modFirewallClientPublicIPAddress '../../../Modules/Microsoft.Network/publicIPAddress/az.net.public.ip.address.bicep' = {
  name: 'deploy-hub-FW-Client-PIP-${parLocation}-${parDeploymentNameSuffix}'
  scope: resourceGroup(parHubSubscriptionId, varHubResourceGroupName)
  params: {
    name: varFirewallClientPublicIPAddressName
    location: parLocation
    tags: modTags.outputs.tags

    skuName: varFirewallPublicIPAddressSkuName
    publicIPAllocationMethod: varFirewallPublicIpAllocationMethod
    zones: parFirewallClientPublicIPAddressAvailabilityZones

    diagnosticWorkspaceId: parLogAnalyticsWorkspaceResourceId
    diagnosticStorageAccountId: modHubLogStorage.outputs.resourceId

    diagnosticLogCategoriesToEnable: parPublicIPAddressDiagnosticsLogs
    diagnosticMetricsToEnable: parPublicIPAddressDiagnosticsMetrics
    publicIPAddressVersion: 'IPv4'
    skuTier: 'Regional'
    lock: parEnableResourceLocks ? 'CanNotDelete' : ''
  }
}

// HUB FW - MGMT - VDSS

module modFirewallManagementPublicIPAddress '../../../Modules/Microsoft.Network/publicIPAddress/az.net.public.ip.address.bicep' = {
  name: 'deploy-hub-FW-Mgmt-PIP-${parLocation}-${parDeploymentNameSuffix}'
  scope: resourceGroup(parHubSubscriptionId, varHubResourceGroupName)
  params: {
    name: varFirewallManagementPublicIPAddressName
    location: parLocation
    tags: modTags.outputs.tags

    skuName: varFirewallPublicIPAddressSkuName

    publicIPAllocationMethod: varFirewallPublicIpAllocationMethod
    zones: parFirewallManagementPublicIPAddressAvailabilityZones

    diagnosticWorkspaceId: parLogAnalyticsWorkspaceResourceId
    diagnosticStorageAccountId: modHubLogStorage.outputs.resourceId

    diagnosticLogCategoriesToEnable: parPublicIPAddressDiagnosticsLogs
    diagnosticMetricsToEnable: parPublicIPAddressDiagnosticsMetrics
    publicIPAddressVersion: 'IPv4'
    skuTier: 'Regional'
    lock: parEnableResourceLocks ? 'CanNotDelete' : ''
  }
}

// HUB FW - VDMS

module modAzureFirewall '../../../Modules/Microsoft.Network/firewalls/az.net.firewall.with.diagnostics.bicep' = if (parAzureFirewallEnabled) {
  name: 'deploy-hub-FW-${parLocation}-${parDeploymentNameSuffix}'
  scope: resourceGroup(parHubSubscriptionId, varHubResourceGroupName)
  params: {
    name: varFirewallName
    location: parLocation
    tags: modTags.outputs.tags

    azureSkuName: 'AZFW_VNet'
    azureSkuTier: parFirewallSkuTier
    isCreateDefaultPublicIP: false
    azureFirewallSubnetPublicIpId: modFirewallClientPublicIPAddress.outputs.resourceId
    azureFirewallMgmtSubnetPublicIpId: modFirewallManagementPublicIPAddress.outputs.resourceId

    firewallPolicyId: modAzureFirewallPolicy.outputs.resourceId
    threatIntelMode: parFirewallThreatIntelMode
    vNetId: modHubVirtualNetwork.outputs.resourceId
    diagnosticWorkspaceId: parLogAnalyticsWorkspaceResourceId
    diagnosticStorageAccountId: modHubLogStorage.outputs.resourceId

    diagnosticLogCategoriesToEnable: parFirewallDiagnosticsLogs
    diagnosticMetricsToEnable: parFirewallDiagnosticsMetrics
    zones:[]
    lock: parEnableResourceLocks ? 'CanNotDelete' : ''
  }
}

// HUB FW - Policy

module modAzureFirewallPolicy '../../../Modules/Microsoft.Network/firewallPolicies/az.net.firewall.policy.bicep' = if (parAzureFirewallEnabled) {
  name: 'deploy-hub-FW-Policy-${parLocation}-${parDeploymentNameSuffix}'
  scope: resourceGroup(parHubSubscriptionId, varHubResourceGroupName)
  params: {
    name: varFirewallPolicyName
    location: parLocation
    threatIntelMode: parFirewallThreatIntelMode
    mode: parFirewallIntrusionDetectionMode
    tier: parFirewallSkuTier
    ruleCollectionGroups: parFirewallPolicyRuleCollectionGroups
  }
  dependsOn: [
    modHubResourceGroup
  ]
}

// HUB PRIVATE DNS - VDSS

module azurePrivateDns '../privateDns/anoa.lz.private.dns.bicep' = if (contains(parSupportedClouds, environment().name) && parEnablePrivateDnsZones) {
  name: 'deploy-hub-prvt-dns-${parLocation}-${parDeploymentNameSuffix}'
  scope: resourceGroup(parHubSubscriptionId, varHubPDZResourceGroupName)
  params: {
    vnetResourceGroup: varHubResourceGroupName
    vnetSubscriptionId: parHubSubscriptionId
    tags: modTags.outputs.tags
    vnetName: modHubVirtualNetwork.outputs.name
  }
  dependsOn: [
    modHubSubnet
  ]
}

// HUB ACTIVITY LOGGING - VDSS

module hubSubscriptionActivityLogging '../../../Modules/Microsoft.Insights/diagnosticSettings/az.insights.diagnostic.setting.bicep' = {
  name: 'deploy-activity-logs-hub-${parLocation}-${parDeploymentNameSuffix}'
  scope: subscription(parHubSubscriptionId)
  params: {
    name: 'log-hub-sub-activity-to-${parLogAnalyticsWorkspaceName}'
    diagnosticWorkspaceId: parLogAnalyticsWorkspaceResourceId
    diagnosticLogCategoriesToEnable: [
      'Administrative'
      'Security'
      'ServiceHealth'
      'Alert'
      'Recommendation'
      'Policy'
      'Autoscale'
      'ResourceHealth'
    ]
  }
  dependsOn: [
    modHubVirtualNetwork
    modHubLogStorage
  ]
}

output resourceGroupName string = modHubResourceGroup.outputs.name
output resourceGroupResourceId string = modHubResourceGroup.outputs.resourceId
output virtualNetworkName string = modHubVirtualNetwork.outputs.name
output virtualNetworkResourceId string = modHubVirtualNetwork.outputs.resourceId
output subnetName string = modHubSubnet.outputs.name
output subnetResourceId string = modHubSubnet.outputs.resourceId
output subnetAddressPrefix string = modHubSubnet.outputs.subnetAddressPrefix
output networkSecurityGroupName string = modHubNetworkSecurityGroup.outputs.name
output networkSecurityGroupResourceId string = modHubNetworkSecurityGroup.outputs.resourceId
output firewallPrivateIPAddress string = modAzureFirewall.outputs.privateIp
output firewallPolicyName string = modAzureFirewallPolicy.outputs.name
output hubStorageAccountResourceId string = modHubLogStorage.outputs.resourceId
output hubRouteTableResourceName string = modHubRouteTable.outputs.name
output hubNetworkSecurityGroupResourceName string = modHubNetworkSecurityGroup.outputs.name
output azurePrivateDnsMonitoringId string = azurePrivateDns.outputs.monitorPrivateDnsZoneId
output azurePrivateDnsAgentsvcId string = azurePrivateDns.outputs.agentsvcPrivateDnsZoneId
output azurePrivateDnsOdsResourceId string = azurePrivateDns.outputs.odsPrivateDnsZoneId
output azurePrivateDnsOmsResourceId string = azurePrivateDns.outputs.omsPrivateDnsZoneId
output azurePrivateDnsStorageResourceId string = azurePrivateDns.outputs.storagePrivateDnsZoneId
