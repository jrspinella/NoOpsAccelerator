# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

data "azurerm_key_vault_secret" "pwd_key" {
  count        = var.use_key_vault ? 1 : 0
  name         = var.pwd_key_name
  key_vault_id = var.key_vault_id
}

data "azurerm_resource_group" "vm_resource_group" {
  name = var.resource_group_name
}

data "azurerm_subnet" "vm_subnet" {
  name                 = var.subnet_name
  virtual_network_name = var.virtual_network_name
  resource_group_name  = var.resource_group_name
}

module "mod_virtual_machine_nsg" {
  count               = length(var.nsg_id) == 0 ? 1 : 0
  source              = "../../Microsoft.Network/networkSecurityGroups"
  name                = format("%s-%s-vm-nsg", var.name, var.location)
  resource_group_name = var.resource_group_name
  location            = var.location
  subnet_id           = data.azurerm_subnet.vm_subnet.id
  nsg_rules           = var.network_security_group_rules
  tags                = var.tags
}

module "mod_virtual_machine_ssh_rule" {
  count                      = length(var.nsg_id) == 0 ? 1 : 0
  source                     = "../../Microsoft.Network/networkSecurityGroups/rule"
  name                       = format("%s-%s-vm-nsg-rule", var.name, var.location)
  location                   = var.location
  resource_group_name        = var.resource_group_name
  nsg_id                     = can(var.nsg_id) ? var.nsg_id : module.mod_virtual_machine_nsg.azurerm_network_security_group_name
  priority                   = 100
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "Tcp"
  source_port_range          = "*"
  destination_port_range     = "22"
  source_address_prefix      = "*"
  destination_address_prefix = "*"
}

module "mod_virtual_machine_nic" {
  source                 = "../../Microsoft.Network/networkInterfaces"
  network_interface_name = var.network_interface_name
  resource_group_name    = var.resource_group_name
  virtual_network_name   = var.virtual_network_name
  location               = var.location
  ip_configuration_name  = var.ip_configuration_name
  subnet_name            = data.azurerm_subnet.vm_subnet.name
  public_ip_address_id   = var.pip_id

  tags = merge(var.tags, {
    deployed-by = format("AzureNoOpsTF [%s]", terraform.workspace)
  })
}

resource "azurerm_windows_virtual_machine" "vm" {
  name                = var.name
  computer_name       = substr(var.name, 0, 14) # computer_name can only be 15 characters maximum
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.size
  admin_username      = var.admin_username
  admin_password      = var.use_key_vault ? data.azurerm_key_vault_secret.pwd_key.value : "${var.admin_password}"

  network_interface_ids = [
    azurerm_network_interface.vm_nic.id,
  ]

  os_disk {
    caching              = var.os_disk_caching
    storage_account_type = var.os_disk_storage_account_type
  }

  source_image_reference {
    publisher = var.publisher
    offer     = var.offer
    sku       = var.sku
    version   = var.image_version
  }

  identity {
    type = "SystemAssigned"
  }

  tags = merge(var.tags, {
    deployed-by = format("AzureNoOpsTF [%s]", terraform.workspace)
  })

  lifecycle {
    ignore_changes = [
      # Ignore changes to tags, e.g. because a management agent
      # updates these based on some ruleset managed elsewhere.
      admin_username,
      admin_password,
      identity,
      license_type,
      os_disk, # Prevent restored OS disks from causinf terraform to attempt to re-create the original os disk name and break the restores OS
      custom_data,
      additional_capabilities,
    ]
  }
}

resource "azurerm_managed_disk" "vm_data_disk" {
  for_each             = var.data_disks
  name                 = format("%s-%s-vm-disk-%s", var.name, var.location, each.key)
  location             = var.location
  create_option        = each.value
  disk_size_gb         = each.value
  resource_group_name  = var.resource_group_name
  storage_account_type = each.value
}

resource "azurerm_virtual_machine_data_disk_attachment" "data" {
  for_each           = var.data_disks
  virtual_machine_id = azurerm_windows_virtual_machine.vm.id
  managed_disk_id    = azurerm_managed_disk.vm_data_disk[each.key].id
  lun                = each.key
  caching            = each.value
}
