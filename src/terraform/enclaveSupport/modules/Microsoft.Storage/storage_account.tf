# Tested with :  AzureRM version 2.61.0
# Ref : https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account

resource "azurerm_storage_account" "stg" {
  access_tier                       = try(var.storage_account.access_tier, "Hot")
  account_kind                      = try(var.storage_account.account_kind, "StorageV2")
  account_replication_type          = try(var.storage_account.account_replication_type, "LRS")
  account_tier                      = try(var.storage_account.account_tier, "Standard")
  enable_https_traffic_only         = try(var.storage_account.enable_https_traffic_only, true)
  infrastructure_encryption_enabled = try(var.storage_account.infrastructure_encryption_enabled, null)
  is_hns_enabled                    = try(var.storage_account.is_hns_enabled, false)
  large_file_share_enabled          = try(var.storage_account.large_file_share_enabled, null)
  location                          = var.location
  min_tls_version                   = try(var.storage_account.min_tls_version, "TLS1_2")
  name                              = var.name
  nfsv3_enabled                     = try(var.storage_account.nfsv3_enabled, false)
  queue_encryption_key_type         = try(var.storage_account.queue_encryption_key_type, null)
  resource_group_name               = var.resource_group_name
  table_encryption_key_type         = try(var.storage_account.table_encryption_key_type, null)
  tags = merge(var.tags, {
    deployed-by = format("AzureNoOpsTF [%s]", terraform.workspace)
  })

  lifecycle {
    ignore_changes = [
      location, resource_group_name
    ]
  }
}

module "queue" {
  source   = "./queue"
  for_each = try(var.storage_account.queues, {})

  storage_account_name = azurerm_storage_account.stg.name
  settings             = each.value
}

module "container" {
  source   = "./container"
  for_each = try(var.storage_account.containers, {})

  storage_account_name = azurerm_storage_account.stg.name
  settings             = each.value
}

module "data_lake_filesystem" {
  source   = "./data_lake_filesystem"
  for_each = try(var.storage_account.data_lake_filesystems, {})

  storage_account_id = azurerm_storage_account.stg.id
  settings           = each.value
}

module "file_share" {
  source   = "./file_share"
  for_each = try(var.storage_account.file_shares, {})

  storage_account_name = azurerm_storage_account.stg.name
  storage_account_id   = azurerm_storage_account.stg.id
  settings             = each.value
  resource_group_name  = var.resource_group_name
}

module "management_policy" {
  source             = "./management_policy"
  for_each           = try(var.storage_account.management_policies, {})
  storage_account_id = azurerm_storage_account.stg.id
  settings           = try(var.storage_account.management_policies, {})
}

resource "azurerm_management_lock" "rg" {
  name       = "${azurerm_storage_account.stg.name}-ReadOnly"
  scope      = azurerm_storage_account.stg.id
  lock_level = "ReadOnly"
  notes      = "This Storage Account is Read-Only"
  count      = try(var.storage_account.enable_locks, false) ? 1 : 0
}
