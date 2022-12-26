# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

module "diagnostics" {
  source = "../Microsoft.Insights/diagnosticSettings"
  count  = var.enable_diagnostic_settings == false ? 0 : 1

  name                       = var.diagnostics_name
  target_resource_id         = azurerm_key_vault.keyvault.id
  storage_account_id         = var.log_analytics_storage_resource_id
  resource_location          = var.location
  log_analytics_workspace_id = var.log_analytics_workspace_resource_id
  log_categories             = var.kv_log_categories
  metric_categories          = var.kv_metric_categories
}
