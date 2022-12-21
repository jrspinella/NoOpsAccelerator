variable "global_settings" {
  description = "Global settings object (see module README.md)"
}
variable "client_config" {
  description = "Client configuration object (see module README.md)."
}

variable "location" {
  description = "The location/region to keep all your network resources. To get the list of all locations with table format from azure cli, run 'az account list-locations -o table'"
  type        = string
}

variable "resource_group_name" {
  description = "A container that holds related resources for an Azure solution"
  type        = string
}

variable "name" {
  description = "The name of the keyvault to store credentials in"
  type        = string
}

variable "sku_name" {
  description = "The name of the SKU used for this key vault. Possible values are standard and premium."
  type        = string
  default     = "standard"
}

variable "soft_delete_retention_days" {
  description = "The number of days that soft-deleted keys should be retained. Must be between 7 and 90."
  type        = number
  default     = 90
}

variable "purge_protection_enabled" {
  description = "Enable purge protection on this key vault"
  type        = bool
  default     = false
}

variable "enable_access_policy" {
  description = "Enable access policy on this key vault"
  type        = bool
  default     = false
}

variable "enabled_for_deployment" {
  description = "Enable deployment on this key vault"
  type        = bool
  default     = false
}

variable "enabled_for_disk_encryption" {
  description = "Enable disk encryption on this key vault"
  type        = bool
  default     = false
}

variable "enabled_for_template_deployment" {
  description = "Enable template deployment on this key vault"
  type        = bool
  default     = false
}

variable "enable_rbac_authorization" {
  description = "Enable RBAC authorization on this key vault"
  type        = bool
  default     = false
}


variable "tenant_id" {
  description = "The tenant ID of the keyvault to store jumpbox credentials in"
  type        = string
}

variable "object_id" {
  description = "The object ID with access the keyvault to store and retrieve jumpbox credentials"
  type        = string
}

variable "log_analytics_workspace_resource_id" {
  description = "The resource id of the Log Analytics Workspace"
  type        = string
  default     = ""
}

variable "log_analytics_storage_resource_id" {
  description = "The resource id of the Log Analytics Workspace Storage Account"
  type        = string
  default     = ""
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

variable "enable_diagnostic_settings" {
  description = "Enable diagnostic settings on this resource"
  type        = bool
  default     = false
}

variable "diagnostics_name" {
  description = "diagnostic settings name on this resource."
  type        = string
  default     = ""
}

variable "kv_log_categories" {
  description = "List of Diagnostic Log Categories"
  type        = list(string)
  default     = []
}

variable "kv_metric_categories" {
  description = "List of Diagnostic Metric Categories"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Base tags for the resource to be inherited from the resource group."
  type        = map(any)
}

