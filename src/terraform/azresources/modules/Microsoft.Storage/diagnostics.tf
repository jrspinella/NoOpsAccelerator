module "diagnostics" {
  source = "../Microsoft.Insights/diagnostics"
   count  = var.enable_diagnostic_settings  ? 1 : 0

  name                       = var.diagnostics_name
  target_resource_id         = azurerm_storage_account.stg.id
  storage_account_id         = var.log_analytics_storage_id
  resource_location          = var.location
  log_analytics_workspace_id = var.log_analytics_workspace_id
  log_categories             = var.stg_log_categories
  metric_categories          = var.stg_metric_categories
}

