# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

variable "name" {
  description = "The name of the availability set."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group the virtual machine resides in"
  type        = string
}

variable "location" {
  description = "The location/region to keep all your network resources. To get the list of all locations with table format from azure cli, run 'az account list-locations -o table'"
  type        = string
}

variable "tags" {
  type = map(string)
  default = {}
  description = "A mapping of tags to assign to the resource."
}

variable "ppg_id" {
  type = string
  default = ""
  description = "The ID of the proximity placement group to use. Defaults to an empty string."
}
variable "proximity_placement_groups" {
  type = list(object({
    name = string
    id   = string
  }))
  default = []
  description = "A list of proximity placement groups to use. Defaults to an empty list."
}
variable "platform_fault_domain_count" {
  default = 3
  type = number
  description = "The number of fault domains to use. Defaults to 3."
}
variable "platform_update_domain_count" {
  default = 5
  type = number
  description = "The number of update domains to use. Defaults to 5."
}
variable "managed" {
  default = true
  type = bool
  description = "Whether the availability set should be managed or not. Defaults to true."
}
