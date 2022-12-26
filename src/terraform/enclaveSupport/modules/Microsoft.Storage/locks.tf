module "locks" {
  source = "../Microsoft.Authorization/locks"
  count  = var.enable_resource_lock ? 1 : 0

  name   = "${azurerm_storage_account.stg.name}-${var.lock_level}-lock"
  scope_id   = azurerm_storage_account.stg.id
  lock_level = var.lock_level
}
