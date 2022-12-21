variable "name" {
  description = "The name of the setting"
  type        = string
}

variable "target_resource_id" {
  description = "(Required) Fully qualified Azure resource identifier for which you enable diagnostics."
}

variable "resource_location" {
  description = "(Required) location of the resource"
}

variable "storage_account_id" {
  description = "The id of the storage account that stores log analytics diagnostic logs"
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "The id of the log analytics workspace that stores log analytics diagnostic logs"
  type        = string
}

variable "log_categories" {
  description = "List of Diagnostic Log Categories"
  type        = list(string)
}

variable "metric_categories" {
  description = "List of Diagnostic Metric Categories"
  type        = list(string)
}

variable "global_settings" {
  default = {}
}
