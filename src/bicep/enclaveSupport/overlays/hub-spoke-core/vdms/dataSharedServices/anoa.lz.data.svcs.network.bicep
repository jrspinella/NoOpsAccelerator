/*
SUMMARY: Module to deploy the Data Shared Services Network and it's components based on the Azure Tactical Mission Network (TMN) conceptual architecture
DESCRIPTION: The following components will be options in this deployment
              Data Shared Services Virtual Network (Vnet)
              Subnets
              Route Table
              Network Security Group
              Log Storage
              Activity Logging
              Private DNS Zones - Details of all the Azure Private DNS zones can be found here --> https://docs.microsoft.com/en-us/azure/private-link/private-endpoint-dns#azure-services-dns-zone-configuration
AUTHOR/S: jspinella

*/

/*
Copyright (c) Microsoft Corporation. Licensed under the MIT license.
*/

targetScope = 'subscription'

// REQUIRED PARAMETERS

@description('Prefix value which will be prepended to all resource names. Default: org')
param parOrgPrefix string = 'org'

@description('The subscription ID for the Hub Network and resources. It defaults to the deployment subscription.')
param parDataSharedServicesSubscriptionId string = subscription().subscriptionId

@description('The region to deploy resources into. It defaults to the deployment location.')
param parLocation string = deployment().location

@description('Tags')
param parTags object

@minLength(3)
@maxLength(15)
@description('A suffix, 3 to 15 characters in length, to append to resource names (e.g. "dev", "test", "prod"). ')
param parDeployEnvironment string

// RESOURCE NAMING PARAMETERS

@description('A suffix to use for naming deployments uniquely. It defaults to the Bicep resolution of the "utcNow()" function.')
param parDeploymentNameSuffix string = utcNow()

//DDOS PARAMETERS

@description('Switch which allows DDOS deployment to be disabled. Default: false')
param parDeployddosProtectionPlan bool = false

@description('Use this parameter if you are deploying seperatly from the full network deploy. If deploying full network, switch to false. It defaults to "true".')
param parResourceGroupModuleCreate bool = true

// NETWORK ADDRESS SPACE PARAMETERS
@description('The CIDR Virtual Network Address Prefix for the Shared Services Virtual Network.')
param parDataSharedServicesVirtualNetworkAddressPrefix string = '10.0.130.0/26'

@description('The CIDR Subnet Address Prefix for the default Shared Services subnet. It must be in the Shared Services Virtual Network space.')
param parDataSharedServicesSubnetAddressPrefix string = '10.0.130.0/27'

@description('Array of Subnet Address Prefix for the default Shared Services network. These will be Spoke Subnet Address Prefixes, if exists.')
param parDataSharedServicesSourceAddressPrefixes array = []

// SHARED SERVICES NETWORK PARAMETERS

@description('An array of Network Diagnostic Logs to enable for the SharedServices Virtual Network. See https://docs.microsoft.com/en-us/azure/azure-monitor/essentials/diagnostic-settings?tabs=CMD#logs for valid settings.')
param parDataSharedServicesVirtualNetworkDiagnosticsLogs array = []

@description('An array of Network Diagnostic Metrics to enable for the SharedServices Virtual Network. See https://docs.microsoft.com/en-us/azure/azure-monitor/essentials/diagnostic-settings?tabs=CMD#metrics for valid settings.')
param parDataSharedServicesVirtualNetworkDiagnosticsMetrics array = []

@description('An array of Network Security Group rules to apply to the SharedServices Virtual Network. See https://docs.microsoft.com/en-us/azure/templates/microsoft.network/networksecuritygroups/securityrules?tabs=bicep#securityrulepropertiesformat for valid settings.')
param parDataSharedServicesNetworkSecurityGroupRules array = [
  {
    name: 'Allow-Traffic-From-Spokes'
    properties: {
      access: 'Allow'
      description: 'Allow traffic from spokes'
      destinationAddressPrefix: parDataSharedServicesVirtualNetworkAddressPrefix
      destinationPortRanges: [
        '22'
        '80'
        '443'
        '3389'
      ]
      direction: 'Inbound'
      priority: 200
      protocol: '*'
      sourceAddressPrefixes: parDataSharedServicesSourceAddressPrefixes
      sourcePortRange: '*'
    }
    type: 'string'
  }
]

@description('An array of Network Security Group diagnostic logs to apply to the SharedServices Virtual Network. See https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-nsg-manage-log#log-categories for valid settings.')
param parDataSharedServicesNetworkSecurityGroupDiagnosticsLogs array = [
  'NetworkSecurityGroupEvent'
  'NetworkSecurityGroupRuleCounter'
]

@description('An array of Service Endpoints to enable for the SharedServices subnet. See https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-service-endpoints-overview for valid settings.')
param parDataSharedServicesSubnetServiceEndpoints array = [
  {
    service: 'Microsoft.Storage'
  }
]

// ROUTE TABLE

@description(' An Array of Routes to be established within the hub route table.')
param parRouteTableRoutes array = [
  {
    name: 'svcs-routetable'
    properties: {
      addressPrefix: '0.0.0.0/0'
      nextHopIpAddress: parFirewallPrivateIPAddress
      nextHopType: 'VirtualAppliance'
    }
  }
]

@description('Firewall private IP address within the hub route table.')
param parFirewallPrivateIPAddress string

param parDisableBgpRoutePropagation bool

// LOGGING PARAMETERS

@description('The Storage Account SKU to use for log storage. It defaults to "Standard_GRS". See https://docs.microsoft.com/en-us/rest/api/storagerp/srp_sku_types for valid settings.')
param parLogStorageSkuName string = 'Standard_GRS'

@description('Log Analytics Workspace Resource Id Needed for NSG, VNet and Activity Logging')
param parLogAnalyticsWorkspaceResourceId string

@description('Log Analytics Workspace Name Needed Activity Logging')
param parLogAnalyticsWorkspaceName string

@description('Enable this setting if this network is on a different subscriptiom as the Hub. Will give conflict errors if on same sub as the Hub')
param enableActivityLogging bool = false

// STORAGE ACCOUNTS RBAC
@description('Account for access to Storage')
param parStorageAccountAccess object

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
var varResourceGroupNamingConvention = replace(varNamingConvention, varResourceToken, 'rg')
var varStorageAccountNamingConvention = toLower('${parOrgPrefix}st${varNameToken}unique_storage_token')
var varSubnetNamingConvention = replace(varNamingConvention, varResourceToken, 'snet')
var varVirtualNetworkNamingConvention = replace(varNamingConvention, varResourceToken, 'vnet')
var varDdosNamingConvention = replace(varNamingConvention, varResourceToken, 'ddos')

// SHARED SERVICES NAMES

var varDataSharedServicesName = 'datasharedservices'
var varDataSharedServicesShortName = 'datasvcs'
var varDataSharedServicesResourceGroupName = replace(varResourceGroupNamingConvention, varNameToken, varDataSharedServicesName)
var varDataSharedServicesLogStorageAccountShortName = replace(varStorageAccountNamingConvention, varNameToken, varDataSharedServicesShortName)
var varDataSharedServicesLogStorageAccountUniqueName = replace(varDataSharedServicesLogStorageAccountShortName, 'unique_storage_token', uniqueString(parDataSharedServicesSubscriptionId, parLocation, parDeployEnvironment, parOrgPrefix))
var varDataSharedServicesLogStorageAccountName = take(varDataSharedServicesLogStorageAccountUniqueName, 23)
var varDataSharedServicesVirtualNetworkName = replace(varVirtualNetworkNamingConvention, varNameToken, varDataSharedServicesName)
var varDataSharedServicesNetworkSecurityGroupName = replace(varNetworkSecurityGroupNamingConvention, varNameToken, varDataSharedServicesName)
var varDataSharedServicesSubnetName = replace(varSubnetNamingConvention, varNameToken, varDataSharedServicesName)
var svcsddosName = replace(varDdosNamingConvention, varNameToken, varDataSharedServicesName)

// ROUTETABLE VALUES
var varRouteTableName = '${varDataSharedServicesSubnetName}-routetable'

// TAGS

@description('Resource group tags')
module modTags '../../../../Modules/Microsoft.Resources/tags/az.resources.tags.bicep' = {
  name: 'deploy-${varDataSharedServicesShortName}-tags-${parLocation}-${parDeploymentNameSuffix}'
  params: {
    tags: parTags
  }
}

// RESOURCE GROUPS

module modDataServicesResourceGroup '../../../../Modules/Microsoft.Resources/resourceGroups/az.resource.groups.bicep' = if(parResourceGroupModuleCreate) {
  name: 'deploy-${varDataSharedServicesShortName}-rg-${parLocation}-${parDeploymentNameSuffix}'
  scope: subscription(parDataSharedServicesSubscriptionId)
  params: {
    name: varDataSharedServicesResourceGroupName
    location: parLocation
    tags: modTags.outputs.tags
  }
}

module modSvcsLogStorage '../../../../Modules/Microsoft.Storage/storageAccounts/az.data.storage.bicep' = {
  name: 'deploy-${varDataSharedServicesShortName}-logStorage-${parLocation}-${parDeploymentNameSuffix}'
  scope: resourceGroup(varDataSharedServicesResourceGroupName)
  params: {
    name: varDataSharedServicesLogStorageAccountName
    location: parLocation
    storageAccountSku: parLogStorageSkuName
    tags: modTags.outputs.tags
    roleAssignments: (parStorageAccountAccess.enableRoleAssignmentForStorageAccount) ? [
      {
        principalIds: parStorageAccountAccess.principalIds
        roleDefinitionIdOrName: parStorageAccountAccess.roleDefinitionIdOrName
      }
    ] : []
    lock: 'CanNotDelete'
  }
  dependsOn: [
    modDataServicesResourceGroup
  ]
}

module modDataServicesNetworkSecurityGroup '../../../../Modules/Microsoft.Network/networkSecurityGroups/az.net.network.security.group.with.diagnostics.bicep' = {
  name: 'deploy-${varDataSharedServicesShortName}-nsg-${parLocation}-${parDeploymentNameSuffix}'
  scope: resourceGroup(varDataSharedServicesResourceGroupName)
  params: {
    name: varDataSharedServicesNetworkSecurityGroupName
    location: parLocation
    tags: modTags.outputs.tags

    securityRules: parDataSharedServicesNetworkSecurityGroupRules

    diagnosticWorkspaceId: parLogAnalyticsWorkspaceResourceId
    diagnosticStorageAccountId: modSvcsLogStorage.outputs.resourceId

    diagnosticLogCategoriesToEnable: parDataSharedServicesNetworkSecurityGroupDiagnosticsLogs
  }
}

module modDataServicesRouteTable '../../../../Modules/Microsoft.Network/routeTable/az.net.route.table.bicep' = {
  name: 'deploy-${varDataSharedServicesShortName}-routeTable-${parLocation}-${parDeploymentNameSuffix}'
  scope: resourceGroup(varDataSharedServicesResourceGroupName)
  params: {
    name: varRouteTableName
    location: parLocation
    tags: modTags.outputs.tags

    routes: parRouteTableRoutes
    disableBgpRoutePropagation: parDisableBgpRoutePropagation
  }
  dependsOn: [
    modDataServicesResourceGroup
  ]
}

module modDataServicesVirtualNetwork '../../../../Modules/Microsoft.Network/virtualNetworks/az.net.virtual.network.with.diagnostics.bicep' = {
  name: 'deploy-${varDataSharedServicesShortName}-virtualNetwork-${parLocation}-${parDeploymentNameSuffix}'
  scope: resourceGroup(varDataSharedServicesResourceGroupName)
  params: {
    name: varDataSharedServicesVirtualNetworkName
    location: parLocation
    tags: modTags.outputs.tags

    addressPrefixes: [
      parDataSharedServicesVirtualNetworkAddressPrefix
    ]

    subnets: [
      {
        addressPrefix: parDataSharedServicesSubnetAddressPrefix
        name: varDataSharedServicesSubnetName
        networkSecurityGroupId: modDataServicesNetworkSecurityGroup.outputs.resourceId
        routeTableId: modDataServicesRouteTable.outputs.resourceId
        serviceEndpoints: parDataSharedServicesSubnetServiceEndpoints
      }
    ]

    diagnosticWorkspaceId: parLogAnalyticsWorkspaceResourceId
    diagnosticStorageAccountId: modSvcsLogStorage.outputs.resourceId

    diagnosticLogCategoriesToEnable: parDataSharedServicesVirtualNetworkDiagnosticsLogs
    diagnosticMetricsToEnable: parDataSharedServicesVirtualNetworkDiagnosticsMetrics
    ddosProtectionPlanEnabled: parDeployddosProtectionPlan
    ddosProtectionPlanId: svcsddosName
  }
}

module spokeDataServicesSubscriptionActivityLogging '../../../../Modules/Microsoft.Insights/diagnosticSettings/az.insights.diagnostic.setting.bicep' = if (enableActivityLogging) {
  name: 'deploy-activity-logs-${varDataSharedServicesShortName}-${parLocation}-${parDeploymentNameSuffix}'
  params: {
    diagnosticEventHubName: 'log-dataservices-sub-activity-to-${parLogAnalyticsWorkspaceName}'
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
      'Audit'
    ]
    diagnosticMetricCategoriesToEnable: []
  }
  dependsOn: [
    modDataServicesVirtualNetwork
    modSvcsLogStorage
  ]
}

output virtualNetworkName string = modDataServicesVirtualNetwork.outputs.name
output virtualNetworkResourceId string = modDataServicesVirtualNetwork.outputs.resourceId
output subnetNames array = modDataServicesVirtualNetwork.outputs.subnetNames
output subnetResourceIds array = modDataServicesVirtualNetwork.outputs.subnetResourceIds
output networkSecurityGroupName string = modDataServicesNetworkSecurityGroup.outputs.name
output networkSecurityGroupResourceId string =  modDataServicesNetworkSecurityGroup.outputs.resourceId
