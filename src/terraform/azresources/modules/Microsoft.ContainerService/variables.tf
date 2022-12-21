# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

variable "settings" {}
variable "admin_group_object_ids" {}

variable "private_dns_zone_id" {
  default = null
}
variable "managed_identities" {
  default = {}
}
variable "application_gateway" {
  default = {}
}
