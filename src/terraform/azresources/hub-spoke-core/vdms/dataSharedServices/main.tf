# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

/*
SUMMARY: Module to deploy the Data Shared Services Network and it's components based on the Azure Mission Landing Zone conceptual architecture
DESCRIPTION: The following components will be options in this deployment
              Operations Virtual Network (Vnet)
              Subnets
              Route Table
              Network Security Group
              Log Storage
              Activity Logging
              Private DNS Zones - Details of all the Azure Private DNS zones can be found here --> https://docs.microsoft.com/en-us/azure/private-link/private-endpoint-dns#azure-services-dns-zone-configuration
AUTHOR/S: jspinella
*/

#################
### GLOBALS   ###
#################

resource "random_id" "uniqueString" {
  keepers = {
    # Generate a new id each time we change resourePrefix variable
    org_prefix = var.org_prefix
    subid      = var.datasvcs_subid
  }
  byte_length = 8
}

###################
### VARIABLES   ###
###################

locals {
  resourceToken    = "resource_token"
  nameToken        = "name_token"
  namingConvention = "${lower(var.org_prefix)}-${var.location}-${lower(var.deploy_environment)}-${local.nameToken}-${local.resourceToken}"

  /*
    NAMING CONVENTION
    Here we define a naming conventions for resources.

    First, we take `var.org_prefix`, `var.location`, and `var.deploy_environment` by variables.
    Then, using string interpolation "${}", we insert those values into a naming convention.
    Finally, we use the replace() function to replace the tokens with the actual resource name.

    For example, if we have a resource named "hub", we will replace the token "name_token" with "hub".
    Then, we will replace the token "resource_token" with "rg" to get the resource group name.
  */

  // RESOURCE NAME CONVENTIONS WITH ABBREVIATIONS
  resourceGroupNamingConvention        = replace(local.namingConvention, local.resourceToken, "rg")
  storageAccountNamingConvention       = lower("${var.org_prefix}st${local.nameToken}unique_storage_token")
  subnetNamingConvention               = replace(local.namingConvention, local.resourceToken, "snet")
  virtualNetworkNamingConvention       = replace(local.namingConvention, local.resourceToken, "vnet")
  networkSecurityGroupNamingConvention = replace(local.namingConvention, local.resourceToken, "nsg")
  firewallNamingConvention             = replace(local.namingConvention, local.resourceToken, "afw")
  firewallPolicyNamingConvention       = replace(local.namingConvention, local.resourceToken, "afwp")
  publicIpAddressNamingConvention      = replace(local.namingConvention, local.resourceToken, "pip")

  // Ops NAMES
  datasvcsName                        = "dataSharedSevices"
  datasvcsShortName                   = "datadatasvcs"
  datasvcsResourceGroupName           = replace(local.resourceGroupNamingConvention, local.nameToken, local.datasvcsName)
  datasvcsLogStorageAccountShortName  = replace(local.storageAccountNamingConvention, local.nameToken, local.datasvcsShortName)
  datasvcsLogStorageAccountUniqueName = replace(local.datasvcsLogStorageAccountShortName, "unique_storage_token", "${random_id.uniqueString.hex}")
  datasvcsLogStorageAccountName       = format("%.24s", lower(replace(local.datasvcsLogStorageAccountUniqueName, "/[[:^alnum:]]/", "")))
  datasvcsVirtualNetworkName          = replace(local.virtualNetworkNamingConvention, local.nameToken, local.datasvcsName)
  datasvcsNetworkSecurityGroupName    = replace(local.networkSecurityGroupNamingConvention, local.nameToken, local.datasvcsName)
  datasvcsSubnetName                  = replace(local.subnetNamingConvention, local.nameToken, local.datasvcsName)
}

################################
### STAGE 0: Scaffolding     ###
################################

module "mod_datasvcs_resource_group" {
  source = "../../../modules/Microsoft.Resources/resourceGroups"
  //Global Settings
  global_settings = var.global_settings
  settings        = var.client_config

  // Resource Group Parameters
  name = local.datasvcsResourceGroupName

  // Resource Group Tags
  tags = var.tags
}

##############################################
### STAGE 1: Build out datasvcs storage account ###
##############################################

module "mod_datasvcs_logging_storage" {
  depends_on = [module.mod_datasvcs_resource_group]
  source     = "../../../modules/Microsoft.Storage"

  //Global Settings
  global_settings = var.global_settings
  client_config   = var.client_config
  location        = var.global_settings.default_region

  // Storage Account Parameters
  name                = local.datasvcsLogStorageAccountName
  resource_group_name = module.mod_datasvcs_resource_group.name
  storage_account     = var.datasvcs_logging_storage_account

  // Storage Account Diagnostic Settings Parameters
  enable_diagnostic_settings = false
}

output "storage_accounts" {
  value     = module.mod_datasvcs_logging_storage
  sensitive = true
}

#################################################
### STAGE 2: Build out Operations Networking  ###
#################################################

#
#
# Network Security Group
#
#
module "mod_datasvcs_network_nsg" {
  depends_on = [module.mod_datasvcs_resource_group]
  source     = "../../../modules/Microsoft.Network/networkSecurityGroups"

  // Global Settings
  location = var.global_settings.default_region

  // NSG Parameters
  name                = local.datasvcsNetworkSecurityGroupName
  resource_group_name = module.mod_datasvcs_resource_group.name
  subnet_id           = module.mod_datasvcs_subnet.id

  // NSG Rules Parameters
  nsg_rules = var.datasvcs_network_security_group_rules

  // NSG Diagnostic Settings Parameters
  enable_diagnostic_settings = true
  log_analytics_storage_id   = module.mod_datasvcs_logging_storage.id
  log_analytics_workspace_id = var.log_analytics_resource_id
  diagnostics_name           = "nsg"
  nsg_log_categories         = var.datasvcs_network_security_group_diagnostics_logs
  nsg_metric_categories      = var.datasvcs_network_security_group_diagnostics_metrics

  // NSG Resource Lock Parameters
  enable_resource_lock = true
  lock_level           = "CanNotDelete"

  // NSG Tags
  tags = var.tags
}


#
#
# Operations Virtual network
#
#
module "mod_datasvcs_network" {
  depends_on = [module.mod_datasvcs_resource_group]
  source     = "../../../modules/Microsoft.Network/virtualNetworks"

  // Global Settings
  global_settings = var.global_settings
  client_config   = var.client_config
  location        = var.global_settings.default_region

  // VNET Parameters
  vnet_name           = local.datasvcsVirtualNetworkName
  vnet_address_space  = var.datasvcs_vnet_address_space
  resource_group_name = module.mod_datasvcs_resource_group.name

  // VNET Diagnostic Settings Parameters
  enable_diagnostic_settings = false

  // VNET Resource Lock Parameters
  enable_resource_lock = true
  lock_level           = "CanNotDelete"

  // DDOS
  ddos_id = ""

  // VNET Tags
  tags = var.tags
}

#
#
# Operations Subnet
#
#
module "mod_datasvcs_subnet" {
  depends_on = [module.mod_datasvcs_network]
  source     = "../../../modules/Microsoft.Network/subnets"

  // Global Settings
  location = var.location

  // Subnet Parameters
  name                                          = local.datasvcsSubnetName
  resource_group_name                           = module.mod_datasvcs_resource_group.name
  virtual_network_name                          = module.mod_datasvcs_network.virtual_network_name
  address_prefixes                              = [cidrsubnet(var.datasvcs_vnet_subnet_address_space, 0, 0)]
  service_endpoints                             = var.datasvcs_subnet_service_endpoints
  private_endpoint_network_policies_enabled     = false
  private_link_service_network_policies_enabled = false

  // Subnet Tags
  tags = var.tags
}

#
#
# Route Table
#
#
module "mod_datasvcs_routetable" {
  depends_on = [module.mod_datasvcs_resource_group]
  source     = "../../../modules/Microsoft.Network/routeTables"

  // Global Settings
  location = var.location

  // Route Table Parameters
  name                          = "datasvcs-routetable"
  resource_group_name           = module.mod_datasvcs_resource_group.name
  disable_bgp_route_propagation = true

  // Routetable Diagnostic Settings Parameters
  enable_diagnostic_settings = false

  // Routetable Resource Lock Parameters
  enable_resource_lock = true
  lock_level           = "CanNotDelete"

  // Routetable Tags
  tags = var.tags

}

#
#
# Route Table
#
#
module "mod_datasvcs_default_route" {
  source = "../../../modules/Microsoft.Network/routeTables/route"

  // Route Table Route Parameters
  name                   = "default_datasvcs_route"
  resource_group_name    = module.mod_datasvcs_resource_group.name
  location               = var.location
  routetable_name        = module.mod_datasvcs_routetable.name
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = var.firewall_private_ip
}

resource "time_sleep" "wait_30_seconds" {
  depends_on = [
    module.mod_datasvcs_default_route
  ]

  create_duration = "30s"
}

resource "azurerm_subnet_route_table_association" "routetable" {
  depends_on = [
    module.mod_datasvcs_routetable,
    time_sleep.wait_30_seconds
  ]

  subnet_id      = module.mod_datasvcs_subnet.id
  route_table_id = module.mod_datasvcs_routetable.id
}
