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

resource "random_integer" "linux-vm-password" {
  min = 6
  max = 72
}

resource "random_password" "linux-vm-password" {
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
  source = "../../../../modules/Microsoft.Compute/linuxVirtualMachines"

  // Global Settings
  resource_group_name  = var.resource_group_name
  location             = var.location
  subnet_name          = data.azurerm_subnet.hub_vm_subnet.name
  virtual_network_name = var.virtual_network_name

  // VM Settings
  name                            = format("%s-linux-vm", var.location)
  size                            = var.size
  admin_username                  = var.admin_username
  admin_password                  = var.use_random_password ? random_password.linux-vm-password.result : var.admin_password
  disable_password_authentication = var.disable_password_authentication
  network_interface_name          = var.network_interface_name
  ip_configuration_name           = var.ip_configuration_name
  public_ip_address_id            = var.public_ip_address_id

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





