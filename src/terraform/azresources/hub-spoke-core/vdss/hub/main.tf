# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

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

#################
### GLOBALS   ###
#################

resource "random_id" "uniqueString" {
  keepers = {
    # Generate a new id each time we change resourePrefix variable
    org_prefix = var.org_prefix
    subid      = var.hub_subid
  }
  byte_length = 8
}

###################
### VARIABLES   ###
###################

locals {

  firewall_client_subnet_name     = "AzureFirewallSubnet"
  firewall_management_subnet_name = "AzureFirewallManagementSubnet"
  resourceToken                   = "resource_token"
  nameToken                       = "name_token"
  namingConvention                = "${lower(var.org_prefix)}-${var.location}-${lower(var.deploy_environment)}-${local.nameToken}-${local.resourceToken}"

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


  // hub NAMES
  hubName                        = "hub"
  hubShortName                   = "hub"
  hubResourceGroupName           = replace(local.resourceGroupNamingConvention, local.nameToken, local.hubName)
  hubLogStorageAccountShortName  = replace(local.storageAccountNamingConvention, local.nameToken, local.hubShortName)
  hubLogStorageAccountUniqueName = replace(local.hubLogStorageAccountShortName, "unique_storage_token", "${random_id.uniqueString.hex}")
  hubLogStorageAccountName       = format("%.24s", lower(replace(local.hubLogStorageAccountUniqueName, "/[[:^alnum:]]/", "")))
  hubVirtualNetworkName          = replace(local.virtualNetworkNamingConvention, local.nameToken, local.hubName)
  hubNetworkSecurityGroupName    = replace(local.networkSecurityGroupNamingConvention, local.nameToken, local.hubName)
  hubSubnetName                  = replace(local.subnetNamingConvention, local.nameToken, local.hubName)

  // FIREWALL NAMES

  firewallName                          = replace(local.firewallNamingConvention, local.nameToken, local.hubName)
  firewallPolicyName                    = replace(local.firewallPolicyNamingConvention, local.nameToken, local.hubName)
  firewallClientPublicIPAddressName     = replace(local.publicIpAddressNamingConvention, local.nameToken, "afw-client")
  firewallManagementPublicIPAddressName = replace(local.publicIpAddressNamingConvention, local.nameToken, "afw-mgmt")

  // FIREWALL VALUES

  firewallPublicIPAddressSkuName   = "Standard"
  firewallPublicIpAllocationMethod = "Static"

  // ROUTETABLE VALUES
  routeTableName = "${local.hubSubnetName}-routetable"
}


################################
### STAGE 0: Scaffolding     ###
################################

module "mod_hub_resource_group" {
  source = "../../../modules/Microsoft.Resources/resourceGroups"
  //Global Settings
  global_settings = var.global_settings
  settings        = var.client_config
  location        = var.location

  // Resource Group Parameters
  name = local.hubResourceGroupName

  // Resource Group Tags
  tags = var.tags
}

##############################################
### STAGE 1: Build out hub storage account ###
##############################################

module "mod_hub_logging_storage" {
  depends_on = [module.mod_hub_resource_group]
  source     = "../../../modules/Microsoft.Storage"

  //Global Settings
  global_settings = var.global_settings
  client_config   = var.client_config
  location        = var.location

  // Storage Account Parameters
  name                = local.hubLogStorageAccountName
  resource_group_name = module.mod_hub_resource_group.name
  storage_account     = var.hub_logging_storage_account
}

output "storage_accounts" {
  value     = module.mod_hub_logging_storage
  sensitive = true
}

##########################################
### STAGE 2: Build out Hub Networking  ###
##########################################

#
#
# Virtual network
#
#
module "mod_hub_network" {
  depends_on = [module.mod_hub_resource_group, module.mod_hub_logging_storage]
  source     = "../../../modules/Microsoft.Network/virtualNetworks"

  // Global Settings
  global_settings = var.global_settings
  client_config   = var.client_config
  location        = var.location

  // VNET Parameters
  vnet_name           = local.hubVirtualNetworkName
  vnet_address_space  = var.hub_vnet_address_space
  resource_group_name = module.mod_hub_resource_group.name

  // VNET Resource Lock Parameters
  enable_resource_lock = var.enable_resource_locks
  lock_level           = "CanNotDelete"

  // DDOS
  ddos_id = try(var.ddos_id, "ddos_id", "")

  // VNET Tags
  tags = var.tags
}

#
#
# Subnet FW Client
#
#
module "hub_fw_client" {
  depends_on = [module.mod_hub_resource_group, module.mod_hub_network]
  source     = "../../../modules/Microsoft.Network/subnets"

  // Global Settings
  location = var.location

  // Subnet Parameters
  name                                          = local.firewall_client_subnet_name
  resource_group_name                           = module.mod_hub_resource_group.name
  virtual_network_name                          = module.mod_hub_network.virtual_network_name
  address_prefixes                              = [cidrsubnet(var.hub_fw_client_address_space, 0, 0)]
  service_endpoints                             = var.firewall_client_subnet_service_endpoints
  private_endpoint_network_policies_enabled     = false
  private_link_service_network_policies_enabled = false

  // Subnet Tags
  tags = var.tags
}

#
#
# Subnet FW Management
#
#
module "hub_fw_management" {
  depends_on = [module.mod_hub_resource_group, module.mod_hub_network]
  source     = "../../../modules/Microsoft.Network/subnets"

  // Global Settings
  location = var.location

  // Subnet Parameters
  name                                          = local.firewall_management_subnet_name
  resource_group_name                           = module.mod_hub_resource_group.name
  virtual_network_name                          = module.mod_hub_network.virtual_network_name
  address_prefixes                              = [cidrsubnet(var.hub_fw_management_address_space, 0, 0)]
  service_endpoints                             = var.firewall_management_subnet_service_endpoints
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
module "hub_routetable" {
  depends_on = [module.mod_hub_resource_group]
  source     = "../../../modules/Microsoft.Network/routeTables"

  // Global Settings
  location = var.location

  // Route Table Parameters
  name                          = local.routeTableName
  resource_group_name           = module.mod_hub_resource_group.name
  disable_bgp_route_propagation = true

  // Routetable Resource Lock Parameters
  enable_resource_lock = var.enable_resource_locks
  lock_level           = "CanNotDelete"

  // Routetable Tags
  tags = var.tags

}

#
#
# Route Table
#
#
module "hub_default_route" {
  source = "../../../modules/Microsoft.Network/routeTables/route"

  // Route Table Route Parameters
  name                   = "default_route"
  resource_group_name    = module.mod_hub_resource_group.name
  location               = var.location
  routetable_name        = module.hub_routetable.name
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = module.mod_hub_firewall.firewall_private_ip
}

resource "time_sleep" "wait_30_seconds" {
  depends_on = [
    module.hub_default_route
  ]

  create_duration = "30s"
}

#
#
# Route Table to Subnet Association
#
#
resource "azurerm_subnet_route_table_association" "routetable" {
  depends_on = [
    module.hub_default_route,
    time_sleep.wait_30_seconds
  ]

  subnet_id      = module.hub_subnet.id
  route_table_id = module.hub_routetable.id
}

#
#
# FW Client PIP
#
#
module "mod_firewall_client_publicIP_address" {
  depends_on = [module.mod_hub_resource_group]
  source     = "../../../modules/Microsoft.Network/publicIPAddress"

  // Global Settings
  location = var.location

  // PIP Client Parameters
  client_publicip_name = local.firewallClientPublicIPAddressName
  resource_group_name  = module.mod_hub_resource_group.name

  // PIP Client Tags
  tags = var.tags
}

#
#
# FW Management PIP
#
#
module "mod_firewall_management_publicIP_address" {
  depends_on = [module.mod_hub_resource_group]
  source     = "../../../modules/Microsoft.Network/publicIPAddress"

  // Global Settings
  location = var.location

  // PIP Management Parameters
  client_publicip_name = local.firewallManagementPublicIPAddressName
  resource_group_name  = module.mod_hub_resource_group.name

  // PIP Management Tags
  tags = var.tags
}

#
#
# Firewall Policy
#
#
module "mod_hub_firewall_policy" {
  depends_on = [module.mod_hub_resource_group]
  source     = "../../../modules/Microsoft.Network/firewallPolicies"

  // Global Settings
  location = var.location

  //
  resource_group_name                   = module.mod_hub_resource_group.name
  firewall_policy_collection_group_name = local.firewallPolicyName
  firewall_policy_name                  = local.firewallPolicyName
  firewall_sku                          = var.firewall_sku_tier

  // Rules Collections
  application_rule_collection = [{
    name     = "AzureAuth"
    priority = 300
    action   = "Allow"
    rule = [{
      name = "msftauth"
      protocols = [{
        type = "Https"
        port = 443
      }]
      source_addresses      = ["*"]
      destination_fqdns     = ["aadcdn.msftauth.net", "aadcdn.msauth.net"]
      destination_fqdn_tags = []
      source_ip_groups      = []
    }]
  }]

  network_rule_collection = [{
    action   = "Allow"
    name     = "AzureCloud"
    priority = 100
    rule = [{
      destination_address   = null
      destination_addresses = ["AzureCloud"]
      destination_fqdns     = []
      destination_ports     = ["*"]
      destination_ip_groups = []
      name                  = "AllowAzureCloud"
      protocols             = ["Any"]
      source_addresses      = ["*"]
      source_ip_groups      = []
      translated_address    = null
      translated_port       = null
    }]
    },
    {
      action   = "Allow"
      name     = "AllSpokeTraffic"
      priority = 200
      rule = [{
        destination_address   = null
        destination_ports     = ["*"]
        destination_addresses = ["*"]
        destination_fqdns     = []
        destination_ip_groups = []
        name                  = "AllowTrafficBetweenSpokes"
        protocols             = ["Any"]
        source_addresses      = ["${module.mod_hub_firewall.firewall_private_ip}"]
        source_ip_groups      = []
        translated_address    = null
        translated_port       = null
      }]
  }]
}

#
#
# Firewall
#
#
module "mod_hub_firewall" {
  depends_on = [module.mod_hub_resource_group, module.mod_firewall_client_publicIP_address, module.mod_firewall_management_publicIP_address]
  source     = "../../../modules/Microsoft.Network/firewalls"

  // Global Settings
  location = var.location

  // Firewall Parameters
  sub_id              = var.hub_subid
  resource_group_name = module.mod_hub_resource_group.name

  vnet_name            = module.mod_hub_network.virtual_network_name
  vnet_address_space   = module.mod_hub_network.virtual_network_address_space
  client_address_space = var.hub_fw_client_address_space

  firewall_name                   = local.firewallName
  firewall_sku_name               = var.firewall_sku_name
  firewall_sku                    = var.firewall_sku_tier
  firewall_client_subnet_name     = module.hub_fw_client.name
  firewall_management_subnet_name = module.hub_fw_management.name
  firewall_policy_name            = module.mod_hub_firewall_policy.azurerm_firewall_policy_name

  client_pip_name      = module.mod_firewall_client_publicIP_address.public_ip_name
  client_ipconfig_name = var.client_ipconfig_name

  mgmt_pip_name            = module.mod_firewall_management_publicIP_address.public_ip_name
  management_ipconfig_name = var.management_ipconfig_name

  // Firewall Tags
  tags = var.tags
}

#
#
# Hub Subnet
#
#
module "hub_subnet" {
  depends_on = [module.mod_hub_network, module.mod_hub_firewall]
  source     = "../../../modules/Microsoft.Network/subnets"

  // Global Settings
  location = var.location

  // Subnet Parameters
  name                                          = local.hubSubnetName
  resource_group_name                           = module.mod_hub_resource_group.name
  virtual_network_name                          = module.mod_hub_network.virtual_network_name
  address_prefixes                              = [cidrsubnet(var.hub_vnet_subnet_address_space, 0, 0)]
  service_endpoints                             = var.hub_subnet_service_endpoints
  private_endpoint_network_policies_enabled     = false
  private_link_service_network_policies_enabled = false

  // Subnet Tags
  tags = var.tags
}

#
#
# Network Security Group
#
#
module "mod_hub_network_nsg" {
  depends_on = [module.mod_hub_resource_group, module.hub_subnet]
  source     = "../../../modules/Microsoft.Network/networkSecurityGroups"

  // Global Settings
  location = var.location

  // NSG Parameters
  name                = local.hubNetworkSecurityGroupName
  resource_group_name = module.mod_hub_resource_group.name
  subnet_id           = module.hub_subnet.id

  // NSG Rules Parameters
  nsg_rules = var.hub_network_security_group_rules

  // NSG Resource Lock Parameters
  enable_resource_lock = var.enable_resource_locks
  lock_level           = "CanNotDelete"

  // NSG Tags
  tags = var.tags
}

