# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

resource "tls_private_key" "ssh" {
  for_each = local.create_sshkeys ? var.settings.virtual_machine_settings : {}

  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_linux_virtual_machine" "linux_vm" {
  admin_password                  = var.disable_password_authentication == false ? var.admin_password : null
  admin_username                  = var.admin_username
  allow_extension_operations      = try(var.allow_extension_operations, null)
  availability_set_id             = can(var.availability_set_key) || can(var.availability_set.key) ? var.availability_sets[try(var.client_config.landingzone_key, each.value.availability_set.lz_key)][try(each.value.availability_set_key, each.value.availability_set.key)].id : try(each.value.availability_set.id, each.value.availability_set_id, null)
  computer_name                   = var.linux_computer_name
  disable_password_authentication = try(var.disable_password_authentication, true)
  encryption_at_host_enabled      = try(var.encryption_at_host_enabled, null)
  eviction_policy                 = try(var.eviction_policy, null)
  license_type                    = try(var.license_type, null)
  location                        = var.location
  name                            = var.linux_vm_name
  network_interface_ids           = var.nic_ids
  priority                        = try(var.priority, null)
  resource_group_name             = var.resource_group_name
  size                            = var.size
  zone                            = try(var.zone, null)
  tags                            = var.tags

  # Create local ssh key
  dynamic "admin_ssh_key" {
    for_each = lookup(var.disable_password_authentication, true) == true && local.create_sshkeys ? [1] : []

    content {
      username   = each.value.admin_username
      public_key = local.create_sshkeys ? tls_private_key.ssh[each.key].public_key_openssh : file(var.settings.public_key_pem_file)
    }
  }

  # by ssh_public_key_id
  dynamic "admin_ssh_key" {
    for_each = {
      for key, value in try(each.value.admin_ssh_keys, {}) : key => value if can(value.ssh_public_key_id)
    }

    content {
      # "Destination path for SSH public keys is currently limited to its default value /home/adminuser/.ssh/authorized_keys  due to a known issue in Linux provisioning agent."
      # username   = try(admin_ssh_key.value.username, each.value.admin_username)
      username   = each.value.admin_username
      public_key = replace(data.external.ssh_public_key_id[admin_ssh_key.key].result.public_ssh_key, "\r\n", "")
    }
  }

  os_disk {
    caching                   = try(each.value.os_disk.caching, null)
    disk_size_gb              = try(each.value.os_disk.disk_size_gb, null)
    name                      = try(azurecaf_name.os_disk_linux[each.key].result, null)
    storage_account_type      = try(each.value.os_disk.storage_account_type, null)
    write_accelerator_enabled = try(each.value.os_disk.write_accelerator_enabled, false)
    disk_encryption_set_id    = try(each.value.os_disk.disk_encryption_set_key, null) == null ? null : try(var.disk_encryption_sets[var.client_config.landingzone_key][each.value.os_disk.disk_encryption_set_key].id, var.disk_encryption_sets[each.value.os_disk.lz_key][each.value.os_disk.disk_encryption_set_key].id, null)

    dynamic "diff_disk_settings" {
      for_each = try(var.diff_disk_settings, false) == false ? [] : [1]

      content {
        option = each.value.diff_disk_settings.option
      }
    }
  }

  dynamic "source_image_reference" {
    for_each = try(each.value.source_image_reference, null) != null ? [1] : []

    content {
      publisher = try(each.value.source_image_reference.publisher, null)
      offer     = try(each.value.source_image_reference.offer, null)
      sku       = try(each.value.source_image_reference.sku, null)
      version   = try(each.value.source_image_reference.version, null)
    }
  }

  lifecycle {
    ignore_changes = [
      os_disk[0].name, #for ASR disk restores
      admin_ssh_key
    ]
  }
}

