# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

/*
SUMMARY: Module Example to deploy an SCCA Compliant Hub/ 1 Spoke Mission Enclave with Azure Kubernetes Service (AKS) and Azure Firewall
DESCRIPTION: The following components will be options in this deployment
            * Mission Enclave - Management Groups and Subscriptions
              * Management Group
                * Org
                * Team
              * Subscription
                * Hub
                * Operations
            * Mission Enclave - Azure Policy via code
              * Azure Policy Initiative
                * Monitoring
                  * Deploy Diagnostic Settings
                * General
                * Network
                * Compute
              * Azure Policy Assignment
            * Mission Enclave - Roles
              * Azure Role Definations
              * Azure Role Assignment
                * Contributor
                * Virtual Machine Contributor
            * Mission Enclave - Hub/Spoke
              * Hub Virtual Network (VNet)
              * Operations Network Artifacts (Optional)
              * Bastion Host (Optional)
              * DDos Standard Plan (Optional)
              * Microsoft Defender for Cloud (Optional)
              * Automation Account (Optional)
              * Spokes
                * Operations (Tier 1)
              * Logging via Operations (Tier 1)
                * Azure Sentinel
                * Azure Log Analytics
                * Azure Log Analytics Solutions
              * Azure Firewall
              * Private DNS Zones - Details of all the Azure Private DNS zones can be found here --> [https://docs.microsoft.com/en-us/azure/private-link/private-endpoint-dns#azure-services-dns-zone-configuration](https://docs.microsoft.com/en-us/azure/private-link/private-endpoint-dns#azure-services-dns-zone-configuration)
            * Mission Enclave - Workloads
              * Azure Kubernetes Service (AKS)
AUTHOR/S: jspinella
*/

# Azure Provider
data "azurerm_subscription" "primary" {}
data "azurerm_client_config" "current" {}

# Org Management Group
data "azurerm_management_group" "org" {
  name = var.root_management_group_id
}

# Contributor role
data "azurerm_role_definition" "contributor" {
  name = "Contributor"
}

# Virtual Machine Contributor role
data "azurerm_role_definition" "vm_contributor" {
  name = "Virtual Machine Contributor"
}

################################################
### STAGE 0: Management Group Configuations  ###
################################################

module "management_group" {
  source            = "../../enclaveSupport/overlays/managementGroups"
  management_groups = var.management_groups
}

#################################################
### STAGE 1: Policy Definitions Configuations ###
#################################################

##################
# General     ####
##################
module "deny_resources_types" {
  source              = "../../enclaveSupport/modules/Microsoft.Authorization/policyDefinition"
  policy_name         = "deny_resources_types"
  display_name        = "Deny Azure Resource types"
  policy_category     = "General"
  management_group_id = data.azurerm_management_group.org.id
}

module "allow_regions" {
  source              = "../../enclaveSupport/modules/Microsoft.Authorization/policyDefinition"
  policy_name         = "allow_regions"
  display_name        = "Allow Azure Regions"
  policy_category     = "General"
  management_group_id = data.azurerm_management_group.org.id
}

#########################################
### STAGE 2: Hub/Spoke Configuations  ###
#########################################

module "hub_1_spoke" {
  provider = azurerm.hub1spoke
  source   = "../../enclaveSupport/platforms/hub1Spoke"

  // Global Settings
  org_prefix         = var.org_prefix
  location           = var.location
  deploy_environment = var.deploy_environment

  // Hub/Spoke Settings
  hub_vnetname                                   = var.hub_vnetname
  hub_vnet_address_space                         = var.hub_vnet_address_space
  hub_rgname                                     = var.hub_rgname
  hub_subid                                      = var.hub_subid
  hub_fw_client_address_space                    = var.hub_fw_client_address_space
  hub_fw_management_address_space                = var.hub_fw_management_address_space
  hub_virtual_network_diagnostics_logs           = var.hub_virtual_network_diagnostics_logs
  hub_network_security_group_diagnostics_metrics = var.hub_virtual_network_diagnostics_metrics
  hub_network_security_group_diagnostics_logs    = var.hub_network_security_group_diagnostics_logs
  hub_virtual_network_diagnostics_metrics        = var.hub_virtual_network_diagnostics_metrics
  hub_network_security_group_rules               = var.hub_network_security_group_rules
  hub_subnet_service_endpoints                   = var.hub_subnet_service_endpoints

  // Hub Firewall Settings
  firewall_name                                           = var.firewall_name
  firewall_sku_name                                       = var.firewall_sku_name
  firewall_sku_tier                                       = var.firewall_sku_tier
  firewall_diagnostics_logs                               = var.firewall_diagnostics_logs
  firewall_diagnostics_metrics                            = var.firewall_diagnostics_metrics
  firewall_client_publicIP_address_availability_zones     = var.firewall_client_publicIP_address_availability_zones
  firewall_management_publicIP_address_availability_zones = var.firewall_management_publicIP_address_availability_zones
  firewall_client_subnet_service_endpoints                = var.firewall_client_subnet_service_endpoints
  firewall_management_subnet_service_endpoints            = var.firewall_management_subnet_service_endpoints
  firewall_threat_detection_mode                          = var.firewall_threat_detection_mode
  firewall_threat_intel_mode                              = var.firewall_threat_intel_mode

  // Hub Resource Locks
  enable_resource_locks = var.enable_resource_locks

  // Operations Settings
  ops_subid              = var.ops_subid
  ops_vnetname           = var.ops_vnetname
  ops_vnet_address_space = var.ops_vnet_address_space
  ops_rgname             = var.ops_rgname
  firewall_private_ip    = module.hub_1_spoke.firewall_private_ip

  // Tags
  tags = merge(var.tags, {
    deployed-by = format("AzureNoOpsTF [%s]", terraform.workspace)
  }) # Tags to be applied to all resources
}


################################################
### STAGE 3: Policy Assignment Configuations ###
################################################

##################
# General     ####
##################
module "org_mg_allow_regions" {
  source            = "../../enclaveSupport/modules/Microsoft.Authorization/policySetAssignment"
  definition        = module.allow_regions.definition
  assignment_scope  = data.azurerm_management_group.org.id
  assignment_effect = "Deny"

  assignment_parameters = {
    "listOfRegionsAllowed" = [
      "East US",
      "Wast US",
      "Global"
    ]
  }

  assignment_metadata = {
    version   = "1.0.0"
    category  = "Batch"
    propertyA = "A"
    propertyB = "B"
  }
}

###################
# Monitoring   ####
###################

module "org_mg_platform_diagnostics_initiative" {
  source               = ".../../enclaveSupport/modules/Microsoft.Authorization/policySetAssignment"
  initiative           = module.platform_diagnostics_initiative.initiative
  assignment_scope     = data.azurerm_management_group.org.id
  skip_remediation     = true
  skip_role_assignment = false

  role_definition_ids = [
    data.azurerm_role_definition.contributor.id # using explicit roles
  ]

  non_compliance_messages = {
    null                                        = "The Default non-compliance message for all member definitions"
    "DeployApplicationGatewayDiagnosticSetting" = "The non-compliance message for the deploy_application_gateway_diagnostic_setting definition"
  }

  assignment_parameters = {
    workspaceId                                        = module.hub_1_spoke.laws_workspace_id
    storageAccountId                                   = module.hub_1_spoke.laws_storage_account_id
    eventHubName                                       = ""
    eventHubAuthorizationRuleId                        = ""
    metricsEnabled                                     = "True"
    logsEnabled                                        = "True"
    effect_DeployApplicationGatewayDiagnosticSetting   = "DeployIfNotExists"
    effect_DeployEventhubDiagnosticSetting             = "DeployIfNotExists"
    effect_DeployFirewallDiagnosticSetting             = "DeployIfNotExists"
    effect_DeployKeyvaultDiagnosticSetting             = "AuditIfNotExists"
    effect_DeployLoadbalancerDiagnosticSetting         = "AuditIfNotExists"
    effect_DeployNetworkInterfaceDiagnosticSetting     = "AuditIfNotExists"
    effect_DeployNetworkSecurityGroupDiagnosticSetting = "AuditIfNotExists"
    effect_DeployPublicIpDiagnosticSetting             = "AuditIfNotExists"
    effect_DeployStorageAccountDiagnosticSetting       = "DeployIfNotExists"
    effect_DeploySubscriptionDiagnosticSetting         = "DeployIfNotExists"
    effect_DeployVnetDiagnosticSetting                 = "AuditIfNotExists"
    effect_DeployVnetGatewayDiagnosticSetting          = "AuditIfNotExists"
  }
}


##################
# Storage     ####
##################
module "org_mg_storage_enforce_https" {
  source            = "../../enclaveSupport/modules/Microsoft.Authorization/policyDefAssignment"
  definition        = module.storage_enforce_https.definition
  assignment_scope  = data.azurerm_management_group.org.id
  assignment_effect = "Deny"
}

module "org_mg_storage_enforce_minimum_tls1_2" {
  source            = "../../enclaveSupport/modules/Microsoft.Authorization/policyDefAssignment"
  definition        = module.storage_enforce_minimum_tls1_2.definition
  assignment_scope  = data.azurerm_management_group.org.id
  assignment_effect = "Deny"
}
