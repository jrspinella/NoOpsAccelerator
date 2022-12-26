# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

resource "azurerm_key_vault" "keyvault" {

  name                            = var.name
  location                        = var.location
  resource_group_name             = var.resource_group_name
  tenant_id                       = var.tenant_id
  soft_delete_retention_days      = 90
  sku_name                        = var.sku_name

  enabled_for_deployment          = try(var.enabled_for_deployment, false)
  enabled_for_disk_encryption     = try(var.enabled_for_disk_encryption, false)
  enabled_for_template_deployment = try(var.enabled_for_template_deployment, false)
  purge_protection_enabled        = try(var.purge_protection_enabled, false)
  enable_rbac_authorization       = try(var.enable_rbac_authorization, false)

  access_policy {
    tenant_id = var.tenant_id
    object_id = var.object_id

    key_permissions = [
      "Create",
      "Get",
    ]

    secret_permissions = [
      "Set",
      "Get",
      "Delete",
      "Purge",
      "Recover"
    ]
  }

  tags                            = var.tags
  timeouts {
    delete = "60m"

  }

  lifecycle {
    ignore_changes = [
      resource_group_name, location
    ]
  }
}
