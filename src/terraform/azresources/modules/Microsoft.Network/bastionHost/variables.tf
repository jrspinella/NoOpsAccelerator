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

variable "enable_resource_lock" {
  description = "Enable resource locks"
  type        = bool
}

variable "lock_level" {
  description = "(Optional) id locks are enabled, Specifies the Level to be used for this Lock."
  type        = string
}

variable "is_create_default_public_ip" {
  description = "(Optional) Specifies if a public ip should be created by default if one is not provided."
  type        = bool
}

variable "existing_bastion_public_ip_address_id" {
  description = "(Optional) The public ip resource ID to associate to the azureBastionSubnet. If empty, then the public ip that is created as part of this module will be applied to the azureBastionSubnet."
  type        = string
  default = ""
}

variable "bastion_host_name" {
  description = "The name of the Bastion Host"
  type        = string
}

variable "sku_name" {
  description = "(Optional) The SKU of this Bastion Host."
  type        = string
  default = "basic"
}

variable "subnet_address_prefix" {
  description = "The address prefix for the Bastion Host (must be a /27 or larger)"
  type        = string
}

variable "public_ip_name" {
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
