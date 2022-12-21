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

data "azurerm_virtual_network" "hub_vnetname" {
  name = var.resource_group_name
}

locals {
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

  // BASTION NAMES
  bastionHostName                            = replace(local.bastionHostNamingConvention, local.nameToken, "hub")
  bastionHostPublicIPAddressName             = replace(local.publicIpAddressNamingConvention, local.nameToken, "bas")
  linuxNetworkInterfaceName                  = replace(local.networkInterfaceNamingConvention, local.nameToken, "linux")
  linuxNetworkInterfaceIpConfigurationName   = replace(local.IpConfigurationNamingConvention, local.nameToken, "linux")
  windowsNetworkInterfaceName                = replace(local.networkInterfaceNamingConvention, local.nameToken, "windows")
  windowsNetworkInterfaceIpConfigurationName = replace(local.IpConfigurationNamingConvention, local.nameToken, "windows")
  bastionHostNetworkSecurityGroupName        = replace(local.networkSecurityGroupNamingConvention, local.nameToken, "bas")

  // BASTION VALUES
  bastionHostPublicIPAddressSkuName          = "Standard"
  bastionHostPublicIPAddressAllocationMethod = "Static"
}

module "mod_bastion_host" {
  depends_on = [data.azurerm_resource_group.hub]
  source     = "../../../azresources/modules/Microsoft.Network/bastionHost"

  // Global Settings
  resource_group_name  = data.azurerm_resource_group.hub.name
  location             = data.azurerm_resource_group.hub.location
  virtual_network_name = data.azurerm_virtual_network.hub_vnetname.name

  // Bastion Host Settings
  bastion_host_name           = local.bastionHostName
  subnet_address_prefix       = var.bastion_address_space
  public_ip_name              = local.bastionHostPublicIPAddressName
  ipconfig_name               = var.bastion_ipconfig_name
  is_create_default_public_ip = var.is_create_default_public_ip

  // Tags
  tags = var.tags
}

#
#
# Bastion Network Security Group
#
#
module "mod_bastion_network_nsg" {
  depends_on = [data.azurerm_resource_group, module.mod_bastion_host]
  source     = "../../../modules/Microsoft.Network/networkSecurityGroups"

  // Global Settings
  location = var.location

  // NSG Parameters
  name                = local.bastionHostNetworkSecurityGroupName
  resource_group_name = data.azurerm_resource_group.hub.name
  subnet_id           = module.mod_bastion_host.subnet_id

  // NSG Rules Parameters
  nsg_rules = {
    "allow_https_inbound" = {
      name                       = "allow_https_inbound"
      priority                   = "120"
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "22"
      destination_port_range     = "443"
      source_address_prefix      = "Internet"
      destination_address_prefix = "*"
    },
    "allow_gateway_manager_inbound" = {
      name                       = "allow_gateway_manager_inbound"
      priority                   = "130"
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "22"
      destination_port_range     = "443"
      source_address_prefix      = "GatewayManager"
      destination_address_prefix = "*"
    },
    "allow_ssh_rdp_outbound" = {
      name                       = "allow_ssh_rdp_outbound"
      priority                   = "100"
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "22,3389"
      source_address_prefix      = "*"
      destination_address_prefix = "VirtualNetwork"
    },
    "allow_azure_cloud_outbound" = {
      name                       = "allow_azure_cloud_outbound"
      priority                   = "110"
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "TCP"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "*"
      destination_address_prefix = "AzureCloud"
    }
  }

  // NSG Tags
  tags = var.tags
}

module "mod_linux_jumpbox" {
  count = var.create_bastion_linux_jumpbox ? 1 : 0

  depends_on = [module.mod_networking_hub, module.mod_bastion_host]
  source     = "../virtualMachine"

  // Global Settings
  resource_group_name  = module.mod_networking_hub.hub_rgname
  location             = var.location
  virtual_network_name = var.hub_vnetname

  // Jumpbox Settings
  name        = var.jumpbox_linux_vm_name
  subnet_name = var.jumpbox_subnet_name

  // NIC Settings
  network_interface_name = local.linuxNetworkInterfaceName
  ip_configuration_name  = local.linuxNetworkInterfaceIpConfigurationName

  // OS Settings
  offer          = var.jumpbox_linux_vm_offer
  sku            = var.jumpbox_linux_vm_sku
  size           = var.jumpbox_linux_vm_size
  image_version  = var.jumpbox_linux_vm_version
  publisher      = var.jumpbox_linux_vm_publisher
  admin_username = var.jumpbox_admin_username
  admin_password = var.jumpbox_admin_password

  // Tags
  tags = var.tags
}

module "mod_windows_jumpbox" {
  count = var.create_bastion_windows_jumpbox ? 1 : 0

  depends_on = [azurerm_resource_group.hub, module.mod_networking_hub, module.mod_bastion_host]
  source     = "../virtualMachine"

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
  tags = var.tags
}
