# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

/*
SUMMARY: Module to deploy the firewall to the Hub Network and it's components based on the Azure Mission Landing Zone conceptual architecture
DESCRIPTION: The following components will be options in this deployment
              Subnets
              Azure Firewall
              Public IPs
PREREQS: Hub
AUTHOR/S: jspinella
*/

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
  resourceGroupNamingConvention   = replace(local.namingConvention, local.resourceToken, "rg")
  subnetNamingConvention          = replace(local.namingConvention, local.resourceToken, "snet")
  firewallNamingConvention        = replace(local.namingConvention, local.resourceToken, "afw")
  firewallPolicyNamingConvention  = replace(local.namingConvention, local.resourceToken, "afwp")
  publicIpAddressNamingConvention = replace(local.namingConvention, local.resourceToken, "pip")


  // hub NAMES
  hubName      = "hub"
  hubShortName = "hub"

  // FIREWALL NAMES

  firewallName                          = replace(local.firewallNamingConvention, local.nameToken, local.hubName)
  firewallPolicyName                    = replace(local.firewallPolicyNamingConvention, local.nameToken, local.hubName)
  firewallClientPublicIPAddressName     = replace(local.publicIpAddressNamingConvention, local.nameToken, "afw-client")
  firewallManagementPublicIPAddressName = replace(local.publicIpAddressNamingConvention, local.nameToken, "afw-mgmt")

  // FIREWALL VALUES

  firewallPublicIPAddressSkuName   = "Standard"
  firewallPublicIpAllocationMethod = "Static"
}

#
#
# Subnet FW Client
#
#
module "hub_fw_client" {
  source = "../../../../modules/Microsoft.Network/subnets"

  // Global Settings
  location = var.location

  // Subnet Parameters
  name                                          = local.firewall_client_subnet_name
  resource_group_name                           = var.resource_group_name
  virtual_network_name                          = var.virtual_network_name
  address_prefixes                              = [cidrsubnet(var.hub_fw_client_address_space, 0, 0)]
  service_endpoints                             = var.firewall_client_subnet_service_endpoints
  private_endpoint_network_policies_enabled     = false
  private_link_service_network_policies_enabled = false

  // Subnet Tags
  tags = merge(var.tags, {
    deployed-by = format("AzureNoOpsTF [%s]", terraform.workspace)
  })
}

#
#
# Subnet FW Management
#
#
module "hub_fw_management" {
  source = "../../../../modules/Microsoft.Network/subnets"

  // Global Settings
  location = var.location

  // Subnet Parameters
  name                                          = local.firewall_management_subnet_name
  resource_group_name                           = var.resource_group_name
  virtual_network_name                          = var.virtual_network_name
  address_prefixes                              = [cidrsubnet(var.hub_fw_management_address_space, 0, 0)]
  service_endpoints                             = var.firewall_management_subnet_service_endpoints
  private_endpoint_network_policies_enabled     = false
  private_link_service_network_policies_enabled = false

  // Subnet Tags
  tags = merge(var.tags, {
    deployed-by = format("AzureNoOpsTF [%s]", terraform.workspace)
  })
}

#
#
# FW Client PIP
#
#
module "mod_firewall_client_publicIP_address" {
  source = "../../../../modules/Microsoft.Network/publicIPAddress"

  // Global Settings
  location = var.location

  // PIP Client Parameters
  public_ip_address_name = local.firewallClientPublicIPAddressName
  resource_group_name    = var.resource_group_name

  // PIP Client Tags
  tags = merge(var.tags, {
    deployed-by = format("AzureNoOpsTF [%s]", terraform.workspace)
  })
}

#
#
# FW Management PIP
#
#
module "mod_firewall_management_publicIP_address" {
  source = "../../../../modules/Microsoft.Network/publicIPAddress"

  // Global Settings
  location = var.location

  // PIP Management Parameters
  public_ip_address_name = local.firewallManagementPublicIPAddressName
  resource_group_name    = var.resource_group_name


  // PIP Management Tags
  tags = merge(var.tags, {
    deployed-by = format("AzureNoOpsTF [%s]", terraform.workspace)
  })
}

#
#
# Firewall Policy
#
#
module "mod_hub_firewall_policy" {
  source = "../../../../modules/Microsoft.Network/firewallPolicies"

  // Global Settings
  location = var.location

  //
  resource_group_name                   = var.resource_group_name
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
  depends_on = [module.mod_firewall_client_publicIP_address, module.mod_firewall_management_publicIP_address]
  source     = "../../../../modules/Microsoft.Network/firewalls"

  // Global Settings
  location = var.location

  // Firewall Parameters
  sub_id              = var.firewall_subid
  resource_group_name = var.resource_group_name

  vnet_name            = var.virtual_network_name
  vnet_address_space   = var.hub_vnet_address_space
  client_address_space = var.hub_fw_client_address_space

  firewall_name                   = local.firewallName
  firewall_sku_name               = var.firewall_sku_name         // "AZFW_VNet"
  firewall_sku                    = var.firewall_sku_tier         // "Premium"
  firewall_client_subnet_name     = module.hub_fw_client.name     // "AzureFirewallSubnet"
  firewall_management_subnet_name = module.hub_fw_management.name // "AzureFirewallManagementSubnet"
  firewall_policy_name            = module.mod_hub_firewall_policy.azurerm_firewall_policy_name

  client_pip_name      = module.mod_firewall_client_publicIP_address.ip_address
  client_ipconfig_name = var.client_ipconfig_name

  mgmt_pip_name            = module.mod_firewall_management_publicIP_address.ip_address
  management_ipconfig_name = var.management_ipconfig_name

  // Firewall Tags
  tags = merge(var.tags, {
    deployed-by = format("AzureNoOpsTF [%s]", terraform.workspace)
  })
}

module "log_analytics_firewall" {
  count  = var.enable_diagnostics ? 1 : 0
  source = "../../../../modules/Microsoft.Insights/diagnosticSettings"

  // Log Analytics Parameters
  name                       = format("%s-diagnostics", local.firewallName)
  target_resource_id         = module.mod_hub_firewall.firewall_id
  storage_account_id         = var.log_analytics_storage_id
  log_analytics_workspace_id = var.log_analytics_resource_id
  resource_location          = var.location

  // Log Analytics Categories
  log_categories = var.firewall_diagnostics_logs

  // Log Analytics Metrics
  metric_categories = var.firewall_diagnostics_metrics

}
