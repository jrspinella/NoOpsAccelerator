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

resource "azurerm_network_interface" "vm_nic" {
  name                = var.network_interface_name
  resource_group_name = var.resource_group_name
  location            = var.location

  ip_configuration {
    name                          = var.ip_configuration_name
    subnet_id                     = data.azurerm_subnet.hub_vm_subnet.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = var.tags
}

resource "azurerm_virtual_machine" "vm" {
  name                = var.name
  computer_name       = substr(var.name, 0, 14) # computer_name can only be 15 characters maximum
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.size
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.vm_nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = var.publisher
    offer     = var.offer
    sku       = var.sku
    version   = var.image_version
  }

  tags = var.tags
}
