# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

variable "name" {
  description = "Required. The name of the network security rule."
  type        = string
}

variable "location" {
  description = "(Required) Specifies the supported Azure location where to create the resource. Changing this forces a new resource to be created."
  type        = string
}

variable "resource_group_name" {
  description = "(Required) The name of the resource group where to create the resource."
  type        = string
  default     = ""
}

variable "nsg_id" {
  description = "(Required) The name of the network security group where to create the rule."
  type        = string
  default     = ""
}

variable "priority" {
  description = "(Required) The priority of the rule. The value can be between 100 and 4096. The priority number must be unique for each rule in the collection. The lower the priority number, the higher the priority of the rule."
  type        = number
  default     = 100
}

variable "direction" {
  description = "(Optional) The direction of network traffic this rule applies to. Possible values are 'Inbound' and 'Outbound'."
  type        = string
  default     = ""
}

variable "access" {
  description = "(Optional) The network traffic is allowed or denied. Possible values are 'Allow' and 'Deny'."
  type        = string
  default     = ""
}

variable "protocol" {
  description = "(Optional) The network protocol this rule applies to. Possible values are 'Tcp', 'Udp', and '*'."
  type        = string
  default     = ""
}

variable "source_port_range" {
  description = "(Optional) The source port or range. Integer or range between 0 and 65535. Asterix '*' can also be used to match all ports."
  type        = string
  default     = ""
}

variable "destination_port_range" {
  description = "(Optional) The destination port or range. Integer or range between 0 and 65535. Asterix '*' can also be used to match all ports."
  type        = string
  default     = ""
}

variable "source_address_prefix" {
  description = "(Optional) The CIDR or source IP range or * to match any IP. This field cannot be used with the source_application_security_group_ids field."
  type        = string
  default     = ""
}

variable "destination_address_prefix" {
  description = "(Optional) The destination address prefix. CIDR or destination IP range or * to match any IP. This field cannot be used with the destination_application_security_group_ids field."
  type        = string
  default     = ""
}



