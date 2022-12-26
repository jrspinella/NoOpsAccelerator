# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

variable "resource_group_name" {
  description = "The name of the resource group the Bastion Host resides in"
  type        = string
}

variable "location" {
  description = "The location/region to keep all your network resources. To get the list of all locations with table format from azure cli, run 'az account list-locations -o table'"
  type        = string
}

variable "virtual_network_name" {
  description = "The name of the virtual network the Bastion Host resides in"
  type        = string
}

variable "subnet_id" {
  description = "The ID of the subnet the bastion resides in"
  type        = string
  default = ""
}

variable "enable_resource_lock" {
  description = "Enable resource locks"
  type        = bool
  default = false
}

variable "lock_level" {
  description = "(Optional) id locks are enabled, Specifies the Level to be used for this Lock."
  type        = string
  default = "CanNotDelete"
}

variable "enable_diagnostic_settings" {
  description = "Create a bastion host and jumpbox VM?"
  type        = bool
  default = false
}

variable "diagnostics_name" {
  description = "diagnostic settings name on this resource."
  type        = string
  default = ""
}

variable "fw_log_categories" {
  description = "List of Diagnostic Log Categories"
  type        = list(string)
  default = [  ]
}

variable "fw_metric_categories" {
  description = "List of Diagnostic Metric Categories"
  type        = list(string)
  default = [  ]
}

variable "flow_log_retention_in_days" {
  description = "The number of days to retain flow log data"
  default     = "7"
  type        = number
}

variable "log_analytics_storage_resource_id" {
  description = "The id of the storage account that stores log analytics diagnostic logs"
  type        = string
  default = ""
}

variable "log_analytics_workspace_resource_id" {
  description = "The id of the log analytics workspace"
  type        = string
  default = ""
}

variable "bastion_host_name" {
  description = "The name of the Bastion Host"
  type        = string
}

variable "bastion_host_sku_name" {
  description = "(Optional) The SKU name of the Bastion Host. Possible values are: Standard and PerGB2018. Defaults to Standard."
  type        = string
  default = "Standard"
}

variable "public_ip_address_sku_name" {
  description = "(Optional) The SKU name of the public IP address. Possible values are: Basic and Standard. Defaults to Standard."
  type        = string
  default = "Standard"
}

variable "public_ip_address_allocation" {
  description = "(Optional) The allocation method of the public IP address. Possible values are: Dynamic and Static. Defaults to Dynamic."
  type        = string
  default = "Dynamic"
}

variable "public_ip_address_name" {
  description = "The name of the Bastion Host public IP address resource"
  type        = string
}

variable "ipconfig_name" {
  description = "The name of the Bastion Host IP configuration resource"
  type        = string
}

variable "tags" {
  description = "A mapping of tags which should be assigned to the resource."
  type        = map(string)
}
