# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.


resource "azurerm_log_analytics_solution" "laws_sentinel" {
  solution_name         = "SecurityInsights"
  location              = var.location
  resource_group_name   = var.resource_group_name
  workspace_name        = var.workspace_name
  workspace_resource_id = var.workspace_resource_id

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/SecurityInsights"
  }
}
