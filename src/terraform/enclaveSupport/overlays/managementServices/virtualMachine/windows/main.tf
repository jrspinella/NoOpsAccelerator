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

resource "random_integer" "windows-vm-password" {
  min = 6
  max = 72
}

resource "random_password" "windows-vm-password" {
  length      = random_integer.linux-vm-password.result
  upper       = true
  lower       = true
  numeric     = true
  special     = true
  min_upper   = 1
  min_lower   = 1
  min_numeric = 1
  min_special = 1
}

module "mod_virtual_machine" {
  source = "../../../../modules/Microsoft.Compute/windowsVirtualMachines"

  // Global Settings
  resource_group_name  = var.resource_group_name
  location             = var.location
  subnet_name          = data.azurerm_subnet.hub_vm_subnet.name
  virtual_network_name = var.virtual_network_name

  // VM Settings
  name                   = format("%s-%s-win-vm", var.name, var.location)
  size                   = var.size
  admin_username         = var.admin_username
  admin_password         = var.use_random_password ? random_password.windows-vm-password.result : var.admin_password
  network_interface_name = var.network_interface_name
  ip_configuration_name  = var.ip_configuration_name
  pip_id                 = var.pip_id

  // OS Settings
  offer         = var.offer
  sku           = var.sku
  image_version = var.image_version
  publisher     = var.publisher

  // key vault
  use_key_vault = false

  // Tags
  tags = merge(var.tags, {
    deployed-by = format("AzureNoOpsTF [%s]", terraform.workspace)
  })
}
