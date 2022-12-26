resource "azurerm_monitor_diagnostic_setting" "diagnostics" {

  name                       = var.name
  target_resource_id         = var.target_resource_id
  storage_account_id         = var.storage_account_id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  dynamic "log" {
    for_each = try(var.log_categories, {})
    content {
      category = log.value
      enabled  = true

      retention_policy {
        days    = 0
        enabled = false
      }
    }
  }

  dynamic "metric" {
    for_each = try(var.metric_categories, {})
    content {
      category = metric.value
      enabled  = true

      retention_policy {
        days    = 7
        enabled = true
      }
    }
  }
}

