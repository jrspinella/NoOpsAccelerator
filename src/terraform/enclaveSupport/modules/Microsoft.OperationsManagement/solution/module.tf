# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

locals {
  solutionName = var.publisher == "Microsoft" ? "${var.name}(${logAnalyticsWorkspace.name})" : var.name

  solutionProduct = var.publisher == "Microsoft" ? "OMSGallery/${var.name}" : var.product
}

data "log_analytics_workspace" "logAnalyticsWorkspace" {
  name                = var.log_analytics_workspace_name
  resource_group_name = var.resource_group_name
}

resource "azurerm_log_analytics_solution" "solution" {
  solution_name         = local.solutionName
  location              = var.location
  resource_group_name   = var.resource_group_name
  workspace_resource_id = data.log_analytics_workspace.logAnalyticsWorkspace.id
  workspace_name        = data.log_analytics_workspace.logAnalyticsWorkspace.name

  plan {
    publisher = var.publisher
    product   = local.solutionProduct
  }
}
