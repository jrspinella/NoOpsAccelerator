variable "client_config" {}
variable "vnet_name" {
  description = "The name of the virtual network"
  type        = string
}
variable "vnet_address_space" {
  description = "The address space to be used for the virtual network"
  type        = list(string)
}
variable "resource_group_name" {
  description = "(Required) Name of the resource group where to create the resource. Changing this forces a new resource to be created. "
  type        = string
}

variable "log_analytics_storage_id" {
  description = "The id of the storage account that stores log analytics diagnostic logs"
  type        = string
  default = ""
}

variable "log_analytics_workspace_id" {
  description = "The id of the log analytics workspace"
  type        = string
  default = ""
}

variable "location" {
  description = "(Required) Specifies the Azure location to deploy the resource. Changing this forces a new resource to be created."
  type        = string
}

variable "ddos_id" {
  description = "(Optional) ID of the DDoS protection plan if exists"
  type        = string
}

variable "enable_resource_lock" {
  description = "Enable resource locks"
  type        = bool
}

variable "lock_level" {
  description = "(Optional) id locks are enabled, Specifies the Level to be used for this Lock."
  type        = string
}

variable "enable_diagnostic_settings" {
  description = "Enable diagnostic settings on this resource"
  type        = bool
  default = false
}

variable "diagnostics_name" {
  description = "diagnostic settings name on this resource."
  type        = string
  default = ""
}

variable "vnet_log_categories" {
  description = "List of Diagnostic Log Categories"
  type        = list(string)
  default = [  ]
}

variable "vnet_metric_categories" {
  description = "List of Diagnostic Metric Categories"
  type        = list(string)
  default = [  ]
}

variable "global_settings" {
  description = "Global settings object (see module README.md)"
}
variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}



