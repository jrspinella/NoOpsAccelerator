
resource "azurerm_management_lock" "resource-level-lock" {
  name       = var.name
  scope      = var.scope_id
  lock_level = var.lock_level
  notes      = var.lock_level == "CanNotDelete" ? "Cannot delete resource or child resources." : "Cannot modify the resource or child resources."
}
