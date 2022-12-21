# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

module "diagnostics" {
  source = "../../Microsoft.Insights/diagnostics"
  count  = var.enable_diagnostic_settings  ? 1 : 0

  name                       = var.diagnostics_name
  target_resource_id         = azurerm_bastion_host.bastion_host.id
  storage_account_id         = var.log_analytics_storage_resource_id
  resource_location          = var.location
  log_analytics_workspace_id = var.log_analytics_workspace_resource_id
  log_categories             = var.fw_log_categories
  metric_categories          = var.fw_metric_categories
}
