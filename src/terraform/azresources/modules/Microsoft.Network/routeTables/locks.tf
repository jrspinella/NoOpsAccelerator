module "locks" {
  source = "../../Microsoft.Authorization/locks"
  count  = var.enable_resource_lock ? 1 : 0
  name   = "${azurerm_route_table.routetable.name}-${var.lock_level}-lock"
  scope_id   = azurerm_route_table.routetable.id
  lock_level = var.lock_level
}
