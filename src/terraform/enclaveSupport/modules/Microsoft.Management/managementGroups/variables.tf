# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

variable "management_group_name" {
  type        = string
  description = "The name of the management group."
}

variable "display_name" {
  type        = string
  description = "The display name of the management group."
}

variable "parent_management_group_id" {
  type        = string
  description = "The ID of the parent management group."
}

variable "subscription_ids" {
  type        = list(string)
  description = "The list of subscription IDs to be associated with the management group."
}

variable "tags" {
  type        = map(string)
  description = "The tags of the management group."
}

