# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.
data "azurerm_resource_group" "hub" {
  name = var.resource_group_name
}

data "azurerm_virtual_network" "hub_bastion_host_vnet" {
  name                = var.virtual_network_name
  resource_group_name = data.azurerm_resource_group.hub.name
}

module "bastion_subnet" { # Bastion Subnet
  source = "../subnets"

  // Global Settings
  location = var.location

  // Subnet Parameters
  name                                          = "AzureBastionSubnet" # the name of the subnet must be 'AzureBastionSubnet'
  resource_group_name                           = data.azurerm_resource_group.hub.name
  virtual_network_name                          = data.azurerm_virtual_network.hub_bastion_host_vnet.name
  address_prefixes                              = [cidrsubnet(var.subnet_address_prefix, 0, 0)]
  service_endpoints                             = var.bastion_subnet_service_endpoints
  private_endpoint_network_policies_enabled     = false
  private_link_service_network_policies_enabled = false

  // Subnet Tags
  tags = var.tags
}

module "bastion_host_pip" { # Public IP for Bastion Host
  source = "../publicIPAddress"
  count = var.is_create_default_public_ip ? 1 : 0

  // Global Settings
  location = var.location

  // Public IP Parameters
  client_publicip_name = "${var.public_ip_name}-bastion-pip"
  resource_group_name  = data.azurerm_resource_group.hub.name
  sku_name = "Regional"

  // Public IP Tags
  tags = var.tags

}

resource "azurerm_bastion_host" "bastion_host" { # Bastion Host
  name                = var.bastion_host_name
  location            = var.location
  resource_group_name = data.azurerm_resource_group.hub.name
  sku                 = var.sku_name

  ip_configuration {
    name                 = "IpConfAzureBastionSubnet"
    subnet_id            = module.bastion_subnet.id
    public_ip_address_id = var.existing_bastion_public_ip_address_id != "" ? var.existing_bastion_public_ip_address_id : module.bastion_host_pip.public_ip
  }

  tags = var.tags
}
