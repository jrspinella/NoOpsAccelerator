# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

output "management_group_id" {
  value = azurerm_management_group.mg.id
}

output "management_group_name" {
  value = azurerm_management_group.mg.name
}

output "parent_management_group_id" {
  value = azurerm_management_group.mg.parent_management_group_id
}
