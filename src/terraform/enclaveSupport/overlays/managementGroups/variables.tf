# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

variable "management_groups" {
  type = list(object({
    management_group_name      = string
    display_name               = string
    parent_management_group_id = string
    subscription_ids           = list(string)
  }))
  description = "The list of management groups to be created."
  default = [{
    display_name               = ""
    management_group_name      = ""
    parent_management_group_id = ""
    subscription_ids           = [""]
    }
  ]
}

variable "tags" {
  type        = map(string)
  description = "The tags of the management group."
  default     = {}
}
