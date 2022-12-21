# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

variable "location" {
  description = "The location/region to keep all your network resources. To get the list of all locations with table format from azure cli, run 'az account list-locations -o table'"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the subnet's resource group"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
}

variable "network_interface_name" {
  description = "The name of the network interface the virtual machine resides in"
  type        = string
}

variable "ip_configuration_name" {
  description = "The name of the ip configuration the virtual machine resides in"
  type        = string
}

variable "subnet_name" {
  description = "The name of the subnet"
  type        = string
}

