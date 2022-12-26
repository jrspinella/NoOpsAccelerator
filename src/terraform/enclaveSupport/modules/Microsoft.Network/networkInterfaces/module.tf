# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

data "azurerm_subnet" "subnet" {
  name                 = var.subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name
}

resource "azurerm_network_interface" "nic" {
  name                          = var.network_interface_name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  enable_accelerated_networking = var.enable_accelerated_networking

  ip_configuration {
    name                          = var.ip_configuration_name
    subnet_id                     = data.azurerm_subnet.subnet.id
    public_ip_address_id          = var.public_ip_address_id
    private_ip_address_allocation = "Dynamic"
  }

  tags = merge(var.tags, {
    deployed-by = format("AzureNoOpsTF [%s]", terraform.workspace)
  })
}
