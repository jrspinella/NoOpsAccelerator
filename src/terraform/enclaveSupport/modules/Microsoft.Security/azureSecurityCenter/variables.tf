variable "managementGroupName" {
  type        = string
  description = "The name of the management group."
}

variable "displayName" {
  type        = string
  description = "The display name of the management group."
}

variable "parentManagementGroupId" {
  type        = string
  description = "The ID of the parent management group."
}

variable "subscriptionIds" {
  type        = list(string)
  description = "The list of subscription IDs to be associated with the management group."
}

variable "tags" {
  type        = map(string)
  description = "The tags of the management group."
}

