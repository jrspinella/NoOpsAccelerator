# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

data "azurerm_resource_group" "vm_resource_group" {
  name = var.resource_group_name
}

data "azurerm_subnet" "hub_vm_subnet" {
  name                 = var.subnet_name
  virtual_network_name = var.virtual_network_name
  resource_group_name  = var.resource_group_name
}

module "linux_vm_nic" {
  source = "../../../../azresources/modules/Microsoft.Network/networkInterfaces"

  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  network_interface_name = var.network_interface_name
  ip_configuration_name  = var.ip_configuration_name
  subnet_name            = var.subnet_name
}

