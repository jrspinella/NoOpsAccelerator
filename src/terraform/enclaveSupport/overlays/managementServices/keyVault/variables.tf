# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

variable "subscription_id" {
  type = string
  description = "The subscription that key vault will be deployed into"
}

variable "resource_group_name" {
  description = "The name of the resource group the jumpbox resides in"
  type        = string
}

variable "location" {
  description = "The region to deploy the jumpbox resides into"
  type        = string
}

variable "keyvault_name" {
  description = "The name of the keyvault to store jumpbox credentials in"
  type        = string
}

variable "key_vault" {
  description = "Key vault configuration object"
  type = object({
    sku_name = string
    soft_delete_retention_days = number
    access_policies = list(object({
      tenant_id          = string
      object_id          = string
      key_permissions    = list(string)
      secret_permissions = list(string)
    }))
    secrets = list(object({
      name  = string
      value = string
    }))
  })
  default = {
    sku_name = "standard"
    soft_delete_retention_days = 90
    access_policies = [
      {
        tenant_id = ""
        object_id = ""
        key_permissions = [
          "Create",
          "Get",
        ]
        secret_permissions = [
          "Set",
          "Get",
          "Delete",
          "Purge",
          "Recover"
        ]
      }
    ]
    secrets = [
      {
        name  = ""
        value = ""
      }
    ]
  }
}


