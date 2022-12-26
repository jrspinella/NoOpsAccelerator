# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

output "id" {
  description = "The ID of the deployed Log Analytics Solution."
  value       = azurerm_log_analytics_solution.solution.id
}

output "name" {
  description = "The name of the deployed Log Analytics Solution."
  value       = azurerm_log_analytics_solution.solution.solution_name
}

output "resource_group_name" {
  description = "The name of the resource group in which the Log Analytics Solution is deployed."
  value       = azurerm_log_analytics_solution.solution.resource_group_name
}

output "workspace_id" {
  description = "The ID of the Log Analytics Workspace in which the Log Analytics Solution is deployed."
  value       = azurerm_log_analytics_solution.solution.workspace_resource_id
}

output "workspace_name" {
  description = "The name of the Log Analytics Workspace in which the Log Analytics Solution is deployed."
  value       = azurerm_log_analytics_solution.solution.workspace_name
}

output "plan" {
  description = "The plan of the deployed Log Analytics Solution."
  value       = azurerm_log_analytics_solution.solution.plan
}

