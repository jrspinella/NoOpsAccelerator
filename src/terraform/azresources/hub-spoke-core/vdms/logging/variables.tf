# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#################################
# Global Configuration
#################################

variable "global_settings" {
  description = "Global settings object"
}
variable "client_config" {
  description = "Client configuration object"
}

variable "tags" {
  description = "A map of key value pairs to apply as tags to resources provisioned in this deployment"
  type        = map(string)
  default = {
    "DeploymentType" : "AzureNoOpsTF"
  }
}

variable "location" {
  description = "The location/region to keep all your network resources. To get the list of all locations with table format from azure cli, run 'az account list-locations -o table'"
  type        = string
}

variable "org_prefix" {
  description = "A name for the organization. It defaults to anoa."
  type        = string
  default     = "anoa"
}

variable "deploy_environment" {
  description = "The environment to deploy to. It defaults to dev."
  type        = string
  default     = "dev"
}

################################################
# Tier 1 - Operations - Logging Configuration ##
################################################

variable "ops_logging_subid" {
  description = "Subscription ID for the deployment"
  type        = string
  default     = ""
}

variable "ops_logging_rgname" {
  description = "Resource Group for the deployment"
  type        = string
  default     = "logging"
}

variable "ops_logging_log_analytics" {
  description = "Log Analytics Workspace variables for the deployment"
  default     = {}
}

variable "create_sentinel" {
  description = "Create an Azure Sentinel Log Analytics Workspace Solution"
  type        = bool
  default     = true
}

variable "logging_storage_account" {
  description = "Storage Account variables for the logging deployment"
  default = {
    access_tier              = "Hot"
    account_kind             = "StorageV2"
    account_replication_type = "LRS"
    account_tier             = "Standard"
    min_tls_version          = "TLS1_2"
    enable_locks             = true
    tags                     = {}
  }
}

#################################
# Logging Configuration
#################################

variable "log_analytics_resource_id" {
  description = "The name of the log analytics workspace resource id"
  type        = string
  default = ""
}

variable "log_analytics_workspace_id" {
  description = "The name of the log analytics workspace"
  type        = string
  default = ""
}

variable "log_analytics_storage_id" {
  description = "The name of the log analytics storage account"
  type        = string
  default = ""
}


