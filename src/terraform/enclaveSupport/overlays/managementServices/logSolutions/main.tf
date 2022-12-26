# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

resource "azurerm_log_analytics_solution" "laws_solutions" {
  solution_name         = var.solution_name
  location              = var.location
  resource_group_name   = var.resource_group_name
  workspace_name        = var.workspace_name
  workspace_resource_id = var.workspace_resource_id

  plan {
    publisher = var.publisher
    product   = "OMSGallery/${var.product}"
  }
}
