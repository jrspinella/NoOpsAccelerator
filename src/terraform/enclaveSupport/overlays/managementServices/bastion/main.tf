# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

/*
SUMMARY: Module to deploy a Bastion Host with Windows/Linux Jump Boxes to the Hub Network
DESCRIPTION: The following components will be options in this deployment
              Bastion Host
              Windows VM
              Lunix VM
AUTHOR/S: jspinella
*/

data "azurerm_resource_group" "hub" {
  name = var.resource_group_name
}

data "azurerm_virtual_network" "hub_bastion_host_vnet" {
  name                = var.vnet_name
  resource_group_name = data.azurerm_resource_group.hub.name
}

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
  networkSecurityGroupNamingConvention = replace(local.namingConvention, local.resourceToken, "nsg")
  publicIpAddressNamingConvention      = replace(local.namingConvention, local.resourceToken, "pip")
  bastionHostNamingConvention          = replace(local.namingConvention, local.resourceToken, "bas")
  networkInterfaceNamingConvention     = replace(local.namingConvention, local.resourceToken, "nic")
  IpConfigurationNamingConvention      = replace(local.namingConvention, local.resourceToken, "ipconfig")

  // BASTION NAMES
  bastionHostName                            = replace(local.bastionHostNamingConvention, local.nameToken, "hub")
  bastionHostPublicIPAddressName             = replace(local.publicIpAddressNamingConvention, local.nameToken, "bas")
  bastionNetworkInterfaceIpConfigurationName = replace(local.IpConfigurationNamingConvention, local.nameToken, "bas")
  linuxNetworkInterfaceName                  = replace(local.networkInterfaceNamingConvention, local.nameToken, "linux")
  linuxNetworkInterfaceIpConfigurationName   = replace(local.IpConfigurationNamingConvention, local.nameToken, "linux")
  windowsNetworkInterfaceName                = replace(local.networkInterfaceNamingConvention, local.nameToken, "windows")
  windowsNetworkInterfaceIpConfigurationName = replace(local.IpConfigurationNamingConvention, local.nameToken, "windows")
  bastionHostNetworkSecurityGroupName        = replace(local.networkSecurityGroupNamingConvention, local.nameToken, "bas")

  // BASTION VALUES
  bastionHostPublicIPAddressSkuName          = "Standard"
  bastionHostPublicIPAddressAllocationMethod = "Static"
}

module "bastion_subnet" { # Bastion Subnet
  source = "../../../modules/Microsoft.Network/subnets"

  // Global Settings
  location = var.location

  // Subnet Parameters
  name                                          = "AzureBastionSubnet" # the name of the subnet must be 'AzureBastionSubnet'
  resource_group_name                           = data.azurerm_resource_group.hub.name
  virtual_network_name                          = data.azurerm_virtual_network.hub_bastion_host_vnet.name
  address_prefixes                              = [cidrsubnet(var.bastion_address_space, 0, 0)]
  service_endpoints                             = var.bastion_subnet_service_endpoints
  private_endpoint_network_policies_enabled     = false
  private_link_service_network_policies_enabled = false

  // Subnet Tags
  tags = merge(var.tags, {
    deployed-by = format("AzureNoOpsTF [%s]", terraform.workspace)
  })
}

module "mod_bastion_host" {
  depends_on = [data.azurerm_resource_group.hub]
  source     = "../../../modules/Microsoft.Network/bastionHost"

  // Global Settings
  resource_group_name  = data.azurerm_resource_group.hub.name
  location             = data.azurerm_resource_group.hub.location
  virtual_network_name = data.azurerm_virtual_network.hub_bastion_host_vnet.name

  // Bastion Host Settings
  bastion_host_name            = local.bastionHostName
  bastion_host_sku_name        = "Standard"
  public_ip_address_name       = local.bastionHostPublicIPAddressName
  public_ip_address_sku_name   = local.bastionHostPublicIPAddressSkuName
  public_ip_address_allocation = local.bastionHostPublicIPAddressAllocationMethod
  ipconfig_name                = local.bastionNetworkInterfaceIpConfigurationName
  subnet_id                    = module.bastion_subnet.id

  // Bastion Resource Lock
  enable_resource_lock = var.enable_resource_lock
  lock_level           = var.lock_level

  // Tags
  tags = merge(var.tags, {
    deployed-by = format("AzureNoOpsTF [%s]", terraform.workspace)
  })
}

#
#
# Bastion Network Security Group
#
#
module "mod_bastion_network_nsg" {
  depends_on = [data.azurerm_resource_group.hub, module.mod_bastion_host]
  source     = "../../../modules/Microsoft.Network/networkSecurityGroups"

  // Global Settings
  location = var.location

  // NSG Parameters
  name                = local.bastionHostNetworkSecurityGroupName
  resource_group_name = data.azurerm_resource_group.hub.name
  subnet_id           = module.bastion_subnet.id

  // NSG Rules Parameters
  nsg_rules = var.bastion_nsg_rules

  enable_resource_lock = false
  lock_level           = var.lock_level

  // NSG Tags
  tags = merge(var.tags, {
    deployed-by = format("AzureNoOpsTF [%s]", terraform.workspace)
  })
}

module "mod_linux_jumpbox" {
  count = var.create_bastion_linux_jumpbox ? 1 : 0

  depends_on = [data.azurerm_resource_group.hub, module.mod_bastion_host]
  source     = "../virtualMachine/linux"

  // Global Settings
  resource_group_name  = data.azurerm_resource_group.hub.name
  location             = var.location
  virtual_network_name = data.azurerm_virtual_network.hub_bastion_host_vnet.name

  // Jumpbox Settings
  subnet_name            = module.bastion_subnet.name
  network_interface_name = local.bastionNetworkInterfaceIpConfigurationName
  ip_configuration_name  = "linux-ipconfig01"
  public_ip_address_id   = module.mod_bastion_host.bastion_public_ip_address_id

  // OS Settings
  size           = var.size_linux_jumpbox
  admin_username = var.admin_username
  admin_password = var.use_random_password ? null : var.admin_password

  // OS Image Settings
  publisher     = var.publisher_linux_jumpbox
  offer         = var.offer_linux_jumpbox
  sku           = var.sku_linux_jumpbox
  image_version = var.image_version_linux_jumpbox

  // key vault
  use_key_vault = var.use_key_vault

  // Tags
  tags = merge(var.tags, {
    deployed-by = format("AzureNoOpsTF [%s]", terraform.workspace)
    description = format("Linux VM for Azure Bastion %s", local.bastionHostName)
  })
}

module "vm_windows_jumpbox_nic" { # Windows VM NIC
  source = "../../../modules/Microsoft.Network/networkInterfaces"

  // Global Settings
  location = var.location

  // NIC Parameters
  network_interface_name = local.windowsNetworkInterfaceName
  resource_group_name    = data.azurerm_resource_group.hub.name
  virtual_network_name   = data.azurerm_virtual_network.hub_bastion_host_vnet.name
  subnet_name            = module.bastion_subnet.name
  ip_configuration_name  = local.windowsNetworkInterfaceIpConfigurationName
  public_ip_address_id   = module.mod_bastion_host.bastion_public_ip_address_id

  // NIC Tags
  tags = merge(var.tags, {
    deployed-by = format("AzureNoOpsTF [%s]", terraform.workspace)
    description = format("Windows VM NIC for Azure Bastion %s", local.bastionHostName)
  })

}

/* module "mod_windows_jumpbox" {
  count = var.create_bastion_windows_jumpbox ? 1 : 0

  depends_on = [azurerm_resource_group.hub, module.mod_networking_hub, module.mod_bastion_host]
  source     = "./virtualMachine/linux"

  // Global Settings
  resource_group_name  = module.mod_networking_hub.hub_rgname
  location             = var.location
  virtual_network_name = var.hub_vnetname

  // Jumpbox Settings
  name        = var.jumpbox_windows_vm_name
  subnet_name = var.jumpbox_subnet_name

  // NIC Settings
  network_interface_name = local.windowsNetworkInterfaceName
  ip_configuration_name  = local.windowsNetworkInterfaceIpConfigurationName

  // OS Settings
  offer          = var.jumpbox_windows_vm_offer
  sku            = var.jumpbox_windows_vm_sku
  size           = var.jumpbox_windows_vm_size
  image_version  = var.jumpbox_windows_vm_version
  publisher      = var.jumpbox_windows_vm_publisher
  admin_username = var.jumpbox_admin_username
  admin_password = var.jumpbox_admin_password

  // Tags
  tags = merge(var.tags, {
    deployed-by = format("AzureNoOpsTF [%s]", terraform.workspace)
  })
}
 */
