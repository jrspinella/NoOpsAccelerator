# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

output "laws_name" {
  description = "LAWS Name"
  value       = azurerm_log_analytics_workspace.laws.name
}

output "laws_rgname" {
  description = "Resource Group for Laws"
  value       = azurerm_log_analytics_workspace.laws.resource_group_name
}

output "laws_StorageAccount_Id" {
  description = "StorageAccount Respurce Id for Laws"
  value       = module.mod_logging_storage.id
}

output "laws_workspace_id" {
  description = "LAWS Workspace Id"
  value       = azurerm_log_analytics_workspace.laws.workspace_id
}

output "laws_resource_id" {
  description = "LAWS Resource Id"
  value       = azurerm_log_analytics_workspace.laws.id
}
