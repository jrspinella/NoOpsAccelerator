resource "azurerm_management_group" "mg" {
   name        = var.managementGroupName
   display_name = var.displayName
   parent_management_group_id = var.parentManagementGroupId
   subscription_ids = var.subscriptionIds
   tags = var.tags
}
