
module "diagnostics" {
  source = "../Microsoft.Insights/diagnosticSettings"
  count  = var.enable_diagnostic_settings  ? 1 : 0

  name                       = var.diagnostics_name
  target_resource_id         = azurerm_kubernetes_cluster.aks.id
  storage_account_id         = var.log_analytics_storage_resource_id
  resource_location          = var.location
  log_analytics_workspace_id = var.log_analytics_workspace_resource_id
  log_categories             = var.fw_log_categories
  metric_categories          = var.fw_metric_categories
}
