variable "global_settings" {
  description = "Global settings object (see module README.md)"
}

variable "tags" {
  description = "(Required) Map of tags to be applied to the resource"
  type        = map(any)
}

variable "settings" {}

variable "name" {
  description = "(Required) The name of the resource group where to create the resource."
  type        = string
}

variable "location" {
  description = "(Required) The location/region where to create the resource. To get the list of all locations with table format from azure cli, run 'az account list-locations -o table'"
  type        = string
}
