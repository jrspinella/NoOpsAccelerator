# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

variable "peering_name" {
  description = "The name of the virtual network peering."
  type        = string
}

variable "location" {
  description = "Specifies the supported Azure location where to create the resource. Changing this forces a new resource to be created."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group where to create the resource."
  type        = string
  default = ""
}

variable "virtual_network_name" {
  description = "The name of the virtual network where to create the resource."
  type        = string
  default = ""
}

variable "remote_virtual_network_id" {
  description = "The ID of the remote virtual network to peer with."
  type        = string
  default = ""
}

variable "allow_virtual_network_access" {
  description = "Allow access from the remote virtual network to use this virtual network's gateways. Defaults to false."
  type        = bool
  default = false
}

variable "allow_forwarded_traffic" {
  description = "Allow forwarded traffic from the remote virtual network. Defaults to false."
  type        = bool
  default = false
}

variable "allow_gateway_transit" {
  description = "Allow gateway transit from the remote virtual network. Defaults to false."
  type        = bool
  default = false
}

variable "use_remote_gateways" {
  description = "Use remote gateways from the remote virtual network. Defaults to false."
  type        = bool
  default = false
}


