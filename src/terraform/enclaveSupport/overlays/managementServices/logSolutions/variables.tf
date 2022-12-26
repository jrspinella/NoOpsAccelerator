# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

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

variable "solution_name" {
  type = string
  description = "The solution name to deploy the solution into the Log Analytics Workspace"
}

variable "product" {
  type = string
  description = "The solution name to deploy the solution into the Log Analytics Workspace product"
}

variable "publisher" {
  type = string
  description = "The name of the Log Analytics Workspace publisher that will link to the solutions"
}

variable "workspace_name" {
  type = string
  description = "The name of the Log Analytics Workspace that will link to the solution"
}

variable "workspace_resource_id" {
  type = string
  description = "The resource id of the Log Analytics Workspace that will link to the solutions"
}
