variable "global_settings" {
  description = "Global settings object (see module README.md)"
}
variable "client_config" {
  description = "Client configuration object (see module README.md)."
}
variable "storage_account" {}
variable "resource_group_name" {
  description = "(Required) The name of the resource group where to create the resource."
  type        = string
}
variable "name" {
  description = "Required. Name of the Storage Account."
  type        = string
}
variable "location" {
  description = "(Required) Specifies the supported Azure location where to create the resource. Changing this forces a new resource to be created."
  type        = string
}

variable "log_analytics_storage_id" {
  type        = string
  default = ""
}

variable "log_analytics_workspace_id" {
  type        = string
  default = ""
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

variable "stg_log_categories" {
  description = "List of Diagnostic Log Categories"
  type        = list(string)
  default = [  ]
}

variable "stg_metric_categories" {
  description = "List of Diagnostic Metric Categories"
  type        = list(string)
  default = [  ]
}

variable "enable_resource_lock" {
  description = "Enable resource locks"
  type        = bool
  default     = false
}

variable "lock_level" {
  description = "(Optional) id locks are enabled, Specifies the Level to be used for this Lock."
  type        = string
  default     = "CanNotDelete"
}


variable "vnets" {
  default = {}
}
variable "private_endpoints" {
  default = {}
}
variable "resource_groups" {
  default = {}
}
variable "tags" {
  default = {}
}
variable "recovery_vaults" {
  default = {}
}
variable "private_dns" {
  default = {}
}
variable "managed_identities" {
  default = {}
}
