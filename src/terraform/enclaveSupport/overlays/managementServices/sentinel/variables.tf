variable "subscription_id" {
  type = string
  description = "The subscription that contains the Log Analytics Workspace and to deploy the Sentinel solution into"
}

variable location {
  type = string
  description = "The Azure region to deploy the Sentinel solution"
}

variable "resource_group_name" {
  type = string
  description = "The name of the resource group that will contain the Sentinel solution"
}

variable "workspace_name" {
  type = string
  description = "The name of the Log Analytics Workspace that will link to the Sentinel solution"
}

variable "workspace_resource_id" {
  type = string
  description = "The resource id of the Log Analytics Workspace that will link to the Sentinel solution"
}
