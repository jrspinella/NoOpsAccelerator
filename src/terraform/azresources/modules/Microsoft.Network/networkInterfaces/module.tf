# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

data "azurerm_subnet" "subnet" {
  name = var.subnet_name
}

resource "azurerm_network_interface" "nic" {
  name                = var.network_interface_name
  resource_group_name = var.resource_group_name
  location            = var.location

  ip_configuration {
    name                          = var.ip_configuration_name
    subnet_id                     = data.azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = var.tags
}
