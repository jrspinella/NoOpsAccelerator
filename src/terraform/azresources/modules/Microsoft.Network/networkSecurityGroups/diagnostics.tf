module "diagnostics" {
  source = "../../Microsoft.Insights/diagnostics"
  count  = var.enable_diagnostic_settings  ? 1 : 0

  name                       = var.diagnostics_name
  target_resource_id         = azurerm_network_security_group.nsg.id
  storage_account_id         = var.log_analytics_storage_id
  resource_location          = var.location
  log_analytics_workspace_id = var.log_analytics_workspace_id
  log_categories             = var.nsg_log_categories
  metric_categories          = var.nsg_metric_categories
}
