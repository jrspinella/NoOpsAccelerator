module "locks" {
  source = "../Microsoft.Authorization/locks"
  count  = var.enable_resource_lock ? 1 : 0

  scope_id   = azurerm_storage_account.stg.id
  lock_level = var.lock_level
}
