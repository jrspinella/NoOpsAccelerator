# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

variable "name" {}
variable "resource_group_name" {
  description = "(Required) The name of the resource group where to create the resource."
  type        = string
}
variable "location" {
  description = "(Required) Specifies the supported Azure location where to create the resource. Changing this forces a new resource to be created."
  type        = string
}
variable "routetable_name" {
  type        = string
}
variable "address_prefix" {
  description = "The subnet address prefixes"
  type        = string
}
variable "next_hop_type" {
  type        = string
}
variable "next_hop_in_ip_address_fw" {
  default = null
}
variable "next_hop_in_ip_address_vm" {
  default = null
}
variable "next_hop_in_ip_address" {
  default = null
}
