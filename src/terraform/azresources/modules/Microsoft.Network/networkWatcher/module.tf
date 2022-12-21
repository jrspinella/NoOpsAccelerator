# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

resource "azurerm_network_watcher_flow_log" "nwfl" {
  depends_on = [azurerm_network_security_rule.nsgrules]

  name                 = var.name
  network_watcher_name = "NetworkWatcher_${replace(var.location, " ", "")}"
  resource_group_name  = "NetworkWatcherRG"

  network_security_group_id = var.nsg_id
  storage_account_id        = var.log_analytics_storage_id
  enabled                   = true
  version                   = 2

  retention_policy {
    enabled = true
    days    = var.flow_log_retention_in_days
  }

  traffic_analytics {
    enabled               = true
    workspace_id          = var.log_analytics_workspace_id
    workspace_region      = var.log_analytics_workspace_location
    workspace_resource_id = var.log_analytics_workspace_resource_id
    interval_in_minutes   = 10
  }
}
