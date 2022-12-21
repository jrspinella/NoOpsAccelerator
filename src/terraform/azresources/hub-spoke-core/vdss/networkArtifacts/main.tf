# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

/*
SUMMARY: Module to deploy a Network Artifacts for a VDSS
DESCRIPTION: The following components will be options in this deployment
               Storage Account
               Key Vault
AUTHOR/S: jspinella
*/

#################
### GLOBALS   ###
#################

resource "random_id" "uniqueString" {
  keepers = {
    # Generate a new id each time we change resourePrefix variable
    org_prefix = var.org_prefix
    subid      = var.netart_subid
  }
  byte_length = 8
}

###################
### VARIABLES   ###
###################

locals {
  resourceToken    = "resource_token"
  nameToken        = "name_token"
  namingConvention = "${lower(var.org_prefix)}-${var.location}-${lower(var.deploy_environment)}-${local.nameToken}-${local.resourceToken}"

  // RESOURCE NAME CONVENTIONS WITH ABBREVIATIONS
  resourceGroupNamingConvention  = replace(local.namingConvention, local.resourceToken, "rg")
  storageAccountNamingConvention = lower("${var.org_prefix}st${local.nameToken}unique_storage_token")
  keyVaultNamingConvention       = lower("${var.org_prefix}kv${local.nameToken}unique_storage_token")

  // netart NAMES
  netartName                        = "netart"
  netartShortName                   = "netart"
  netartResourceGroupName           = replace(local.resourceGroupNamingConvention, local.nameToken, local.netartName)
  netartLogStorageAccountShortName  = replace(local.storageAccountNamingConvention, local.nameToken, local.netartShortName)
  netartLogStorageAccountUniqueName = replace(local.netartLogStorageAccountShortName, "unique_storage_token", "${random_id.uniqueString.hex}")
  netartLogStorageAccountName       = format("%.24s", lower(replace(local.netartLogStorageAccountUniqueName, "/[[:^alnum:]]/", "")))
  netartKeyVaultShortName           = replace(local.keyVaultNamingConvention, local.nameToken, local.netartShortName)
  netartKeyVaultUniqueName          = replace(local.netartKeyVaultShortName, "unique_storage_token", "${random_id.uniqueString.hex}")
  netartKeyVaultName                = format("%.24s", lower(replace(local.netartKeyVaultUniqueName, "/[[:^alnum:]]/", "")))
}

################################
### STAGE 0: Scaffolding     ###
################################

module "mod_netart_resource_group" {
  source = "../../../modules/Microsoft.Resources/resourceGroups"
  //Global Settings
  global_settings = var.global_settings
  settings        = var.client_config
  location        = var.location

  // Resource Group Parameters
  name = local.netartResourceGroupName

  // Resource Group Tags
  tags = var.tags
}

############################################################
### STAGE 1: Build out network artifacts storage account ###
############################################################

module "mod_netart_logging_storage" {
  depends_on = [module.mod_netart_resource_group]
  source     = "../../../modules/Microsoft.Storage"

  //Global Settings
  global_settings = var.global_settings
  client_config   = var.client_config
  location        = var.location

  // Storage Account Parameters
  name                = local.netartLogStorageAccountName
  resource_group_name = module.mod_netart_resource_group.name
  storage_account     = var.netart_storage_account

  // Storage Account Resource Lock Parameters
  enable_resource_lock = true
  lock_level           = "CanNotDelete"

  // Storage Account Tags
  tags = var.tags
}

output "storage_accounts" {
  value     = module.mod_netart_logging_storage
  sensitive = true
}


#######################################################
### STAGE 2: Build out network artifacts key vault  ###
#######################################################

module "mod_netart_key_vault" {
  depends_on = [module.mod_netart_resource_group]
  source     = "../../../modules/Microsoft.KeyVault"

  //Global Settings
  global_settings = var.global_settings
  client_config   = var.client_config
  location        = var.location

  // Key Vault Parameters
  name                            = local.netartKeyVaultName
  resource_group_name             = module.mod_netart_resource_group.name
  tenant_id                       = var.client_config.tenant_id
  object_id                       = var.client_config.object_id
  sku_name                        = var.sku_name // standard or premium
  soft_delete_retention_days      = var.soft_delete_retention_days
  enabled_for_deployment          = var.enabled_for_deployment
  enabled_for_disk_encryption     = var.enabled_for_disk_encryption
  enabled_for_template_deployment = var.enabled_for_template_deployment
  purge_protection_enabled        = var.purge_protection_enabled
  enable_rbac_authorization       = var.enable_rbac_authorization

  // Key Vault Resource Lock Parameters
  enable_resource_lock = true
  lock_level           = "CanNotDelete"

  // Key Vault Tags
  tags = var.tags
}

output "key_vaults" {
  value     = module.mod_netart_key_vault
  sensitive = true
}
