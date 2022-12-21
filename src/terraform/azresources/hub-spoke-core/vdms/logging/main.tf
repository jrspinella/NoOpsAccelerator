# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

/*
SUMMARY: Module to deploy the Logging based on the Azure Mission Landing Zone conceptual architecture
DESCRIPTION: The following components will be options in this deployment
              Log Analytics Workspace
              Log Storage
              Diagnostic Logging
AUTHOR/S: jrspinella
*/

################################
### GLOBAL VARIABLES         ###
################################


resource "random_id" "uniqueString" {
  keepers = {
    # Generate a new id each time we change resourePrefix variable
    org_prefix = var.org_prefix
    subid      = var.ops_logging_subid
  }
  byte_length = 8
}

locals {
  resourceToken    = "resource_token"
  nameToken        = "name_token"
  namingConvention = "${lower(var.org_prefix)}-${var.location}-${lower(var.deploy_environment)}-${local.nameToken}-${local.resourceToken}"

  /*
    NAMING CONVENTION
    Here we define a naming conventions for resources.

    First, we take `var.org_prefix`, `var.location`, and `var.deploy_environment` by variables.
    Then, using string interpolation "${}", we insert those values into a naming convention.
    Finally, we use the replace() function to replace the tokens with the actual resource name.

    For example, if we have a resource named "hub", we will replace the token "name_token" with "hub".
    Then, we will replace the token "resource_token" with "rg" to get the resource group name.
  */

  // RESOURCE NAME CONVENTIONS WITH ABBREVIATIONS
  logAnalyticsWorkspaceNamingConvention = replace(local.namingConvention, local.resourceToken, "log")
  resourceGroupNamingConvention         = replace(local.namingConvention, local.resourceToken, "rg")
  storageAccountNamingConvention        = lower("${var.org_prefix}st${local.nameToken}unique_storage_token")

  // LOGGING NAMES
  loggingName                        = "logging"
  loggingShortName                   = "log"
  loggingResourceGroupName           = replace(local.resourceGroupNamingConvention, local.nameToken, local.loggingName)
  loggingLogStorageAccountShortName  = replace(local.storageAccountNamingConvention, local.nameToken, local.loggingShortName)
  loggingLogStorageAccountUniqueName = replace(local.loggingLogStorageAccountShortName, "unique_storage_token", "${random_id.uniqueString.hex}")
  loggingLogStorageAccountName       = format("%.24s", lower(replace(local.loggingLogStorageAccountUniqueName, "/[[:^alnum:]]/", "")))

  // LOG ANALYTICS NAMES

  logAnalyticsWorkspaceName = replace(local.logAnalyticsWorkspaceNamingConvention, local.nameToken, local.loggingName)
}

variable "solutions" {
  description = "Map of project names to configuration."
  type = list(object({
    name          = string
    product       = string
    publisher     = string
    promotionCode = string
  }))
  default = [{
    name : "AzureActivity"
    product : "OMSGallery/AzureActivity"
    publisher : "Microsoft"
    promotionCode : ""
    },
    {
      name : "VMInsights"
      product : "OMSGallery/VMInsights"
      publisher : "Microsoft"
      promotionCode : ""
    },
    {
      name : "Security"
      product : "OMSGallery/Security"
      publisher : "Microsoft"
      promotionCode : ""
    },
    {
      name : "ServiceMap"
      publisher : "Microsoft"
      product : "OMSGallery/ServiceMap"
      promotionCode : ""
    },
    {
      name : "ContainerInsights"
      publisher : "Microsoft"
      product : "OMSGallery/ContainerInsights"
      promotionCode : ""
    },
    {
      name : "KeyVaultAnalytics"
      publisher : "Microsoft"
      product : "OMSGallery/KeyVaultAnalytics"
      promotionCode : ""
    },
    {
      name : "ChangeTracking"
      publisher : "Microsoft"
      product : "OMSGallery/ChangeTracking"
      promotionCode : ""
    },
    {
      name : "SQLAssessment"
      publisher : "Microsoft"
      product : "OMSGallery/SQLAssessment"
      promotionCode : ""
    },
    {
      name : "Updates"
      publisher : "Microsoft"
      product : "Updates"
      promotionCode : ""
  }]
}

################################
### STAGE 0: Scaffolding     ###
################################

module "mod_logging_resource_group" {
  source = "../../../modules/Microsoft.Resources/resourceGroups"

  //Global Settings
  global_settings = var.global_settings
  settings        = var.client_config
  location        = var.location

  // Resource Group Parameters
  name = local.loggingResourceGroupName

  // Resource Group Tags
  tags = var.tags
}

###################################
### STAGE 1: Build out Logging  ###
###################################

module "mod_logging_storage" {
  depends_on = [module.mod_logging_resource_group]
  source     = "../../../modules/Microsoft.Storage"

  //Global Settings
  global_settings = var.global_settings
  client_config   = var.client_config
  location        = var.location

  // Storage Account Parameters
  name                = local.loggingLogStorageAccountName
  resource_group_name = module.mod_logging_resource_group.name
  storage_account     = var.logging_storage_account

  // Storage Account Diagnostic Settings Parameters
  enable_diagnostic_settings = false
}

output "storage_accounts" {
  value     = module.mod_logging_storage
  sensitive = true
}

resource "azurerm_log_analytics_workspace" "laws" {
  depends_on = [module.mod_logging_resource_group]

  //Global Settings
  location = module.mod_logging_resource_group.location

  // Log Analytics Workspace Parameters
  name                = local.logAnalyticsWorkspaceName
  resource_group_name = module.mod_logging_resource_group.name
  sku                 = lookup(var.ops_logging_log_analytics, "sku", "PerGB2018")
  retention_in_days   = lookup(var.ops_logging_log_analytics, "retention_in_days", 30)

  // Log Analytics Workspace Tags
  tags = var.tags
}

module "mod_law_solutions" {
  depends_on = [azurerm_log_analytics_workspace.laws]
  source   = "../../../../overlays/managementServices/logSolutions"
  for_each = { for i, v in var.solutions : i => v }

  //Global Settings
  subscription_id = var.ops_logging_subid
  location        = module.mod_logging_resource_group.location

  // Log Analytics Solutions Parameters
  resource_group_name   = module.mod_logging_resource_group.name
  solution_name         = each.value.name
  product               = each.value.product
  publisher             = each.value.publisher
  workspace_resource_id = azurerm_log_analytics_workspace.laws.id
  workspace_name        = azurerm_log_analytics_workspace.laws.name
}

module "mod_law_sentinel" {
  depends_on = [azurerm_log_analytics_workspace.laws]
  source = "../../../../overlays/managementServices/sentinel"
  count  = var.create_sentinel ? 1 : 0

  //Global Settings
  subscription_id = var.ops_logging_subid
  location        = module.mod_logging_resource_group.location

  // Log Analytics Sentinel Parameters
  resource_group_name   = module.mod_logging_resource_group.name
  workspace_resource_id = azurerm_log_analytics_workspace.laws.id
  workspace_name        = azurerm_log_analytics_workspace.laws.name
}

