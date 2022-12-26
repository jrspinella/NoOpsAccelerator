# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

/*
SUMMARY: Module Example to deploy an SCCA Compliant Platform Hub/ 1 Spoke Landing Zone
DESCRIPTION: The following components will be options in this deployment
              * Hub Virtual Network (VNet)
              * Operations Network Artifacts (Optional)
              * Bastion Host (Optional)
              * DDos Standard Plan (Optional)
              * Microsoft Defender for Cloud (Optional)
              * Automation Account (Optional)
            * Spokes
              * Operations (Tier 1)
            * Logging
              * Azure Sentinel
              * Azure Log Analytics
            * Azure Firewall
            * Private DNS Zones - Details of all the Azure Private DNS zones can be found here --> [https://docs.microsoft.com/en-us/azure/private-link/private-endpoint-dns#azure-services-dns-zone-configuration](https://docs.microsoft.com/en-us/azure/private-link/private-endpoint-dns#azure-services-dns-zone-configuration)
AUTHOR/S: jspinella

IMPORTANT: This module is not intended to be used as a standalone module. It is intended to be used as a module within a Misson Enclave deployment. Please see the Mission Enclave documentation for more information.
*/

provider "azurerm" {
  environment     = var.environment
  metadata_host   = var.metadata_host
  subscription_id = var.hub_subid

  features {
    log_analytics_workspace {
      permanently_delete_on_destroy = true
    }
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}

provider "random" {
}

provider "time" {
}

data "azurerm_subscription" "primary" {}
data "azurerm_client_config" "current_client" {
}

################################
### STAGE 1: Logging         ###
################################

module "mod_logging" {
  source = "../../../enclaveSupport/overlays/hub-spoke-core/vdms/logging"

  // Global Settings
  location = var.location

  // Logging Settings
  ops_logging_subid         = var.ops_subid
  ops_logging_rgname        = var.ops_logging_rgname
  ops_logging_log_analytics = var.logging_log_analytics
  create_sentinel           = var.create_sentinel
  logging_storage_account   = var.logging_storage_account

  // Tags
  tags = merge(var.tags, {
    deployed-by = format("AzureNoOpsTF [%s]", terraform.workspace)
  })
}

###################################
## STAGE 2: Hub Networking      ###
###################################

module "mod_networking_hub" {
  depends_on = [
    module.mod_logging
  ]
  source = "../../../enclaveSupport/overlays/hub-spoke-core/vdss/hub"

  // Global Settings

  org_prefix         = var.required.org_prefix
  location           = var.location
  deploy_environment = var.deploy_environment

  // Logging Settings
  log_analytics_resource_id  = module.mod_logging.laws_resource_id
  log_analytics_workspace_id = module.mod_logging.laws_workspace_id
  log_analytics_storage_id   = module.mod_logging.laws_StorageAccount_Id

  // Hub Networking Settings
  hub_subid                                      = var.hub_subid
  hub_vnet_address_space                         = var.hub_vnet_address_space
  hub_virtual_network_diagnostics_logs           = var.hub_virtual_network_diagnostics_logs
  hub_network_security_group_diagnostics_metrics = var.hub_virtual_network_diagnostics_metrics
  hub_network_security_group_diagnostics_logs    = var.hub_network_security_group_diagnostics_logs
  hub_virtual_network_diagnostics_metrics        = var.hub_virtual_network_diagnostics_metrics
  hub_network_security_group_rules               = var.hub_network_security_group_rules
  hub_subnet_service_endpoints                   = var.hub_subnet_service_endpoints

  // Hub Resource Locks
  enable_resource_locks = var.enable_services.enable_resource_locks

  // Tags
  tags = merge(var.tags, {
    deployed-by = format("AzureNoOpsTF [%s]", terraform.workspace)
  }) # Tags to be applied to all resources

}


######################################
### STAGE 2.1: Network Artifacts   ###
######################################

##############################################################################
### This stage is optional based on the value of `create_network_artifacts` ##
##############################################################################

module "mod_network_artifacts" {
  depends_on = [
    module.mod_networking_hub
  ]
  source = "../../../enclaveSupport/overlays/hub-spoke-core/vdss/networkArtifacts"
  count  = var.enable_services.ops_network_artifacts ? 1 : 0

  // Global Settings

  location           = var.location
  org_prefix         = var.org_prefix
  tenant_id          = data.azurerm_client_config.current_client.tenant_id
  object_id          = data.azurerm_client_config.current_client.object_id
  deploy_environment = var.deploy_environment

  // Network Artifacts Settings
  netart_subid = var.ops_subid

  // Network Artifacts storage account
  netart_storage_account = var.network_artifacts_storage_account

  // Network Artifacts Key Vault
  sku_name                        = var.kv_sku_name
  soft_delete_retention_days      = var.kv_soft_delete_retention_days
  purge_protection_enabled        = var.kv_purge_protection_enabled
  enabled_for_deployment          = var.kv_enabled_for_deployment
  enabled_for_disk_encryption     = var.kv_enabled_for_disk_encryption
  enabled_for_template_deployment = var.kv_enabled_for_template_deployment
  enable_rbac_authorization       = var.kv_enable_rbac_authorization


  // Logging Settings
  log_analytics_resource_id  = var.enable_network_artifacts_diagnostics ? module.mod_logging.laws_resource_id : null
  log_analytics_workspace_id = var.enable_network_artifacts_diagnostics ? module.mod_logging.laws_workspace_id : null
  log_analytics_storage_id   = var.enable_network_artifacts_diagnostics ? module.mod_logging.laws_StorageAccount_Id : null

  // Tags
  tags = merge(var.tags, {
    deployed-by = format("AzureNoOpsTF [%s]", terraform.workspace)
  }) # Tags to be applied to all resources
}

##########################################
## STAGE 3: Operations Networking      ###
##########################################

module "mod_networking_operations" {
  depends_on = [
    module.mod_logging
  ]
  source = "../../../enclaveSupport/overlays/hub-spoke-core/vdms/operations"

  // Global Settings

  org_prefix         = var.org_prefix
  location           = var.location
  deploy_environment = var.deploy_environment

  // Logging Settings
  log_analytics_resource_id  = module.mod_logging.laws_resource_id
  log_analytics_workspace_id = module.mod_logging.laws_workspace_id
  log_analytics_storage_id   = module.mod_logging.laws_StorageAccount_Id

  // Operations Networking Settings
  ops_subid              = var.ops_subid
  ops_vnetname           = var.ops_vnetname
  ops_vnet_address_space = var.ops_vnet_address_space
  ops_rgname             = var.ops_rgname
  firewall_private_ip    = module.mod_networking_hub.firewall_private_ip

  // Tags
  tags = merge(var.tags, {
    deployed-by = format("AzureNoOpsTF [%s]", terraform.workspace)
  }) # Tags to be applied to all resources
}

####################################
## STAGE 4: Networking Peering   ###
####################################

module "mod_hub_to_ops_networking_peering" {
  depends_on = [
    module.mod_networking_hub,
    module.mod_networking_operations
  ]
  source = "../../../enclaveSupport/overlays/hub-spoke-core/peering"

  count = var.peer_to_hub_virtual_network == false ? 0 : 1

  // Global Settings
  location            = var.location
  resource_group_name = module.mod_networking_hub.resource_group_name

  // Hub Networking Peering Settings
  peering_name              = "${module.mod_networking_hub.virtual_network_name}-to-${module.mod_networking_operations.virtual_network_name}"
  virtual_network_name      = module.mod_networking_hub.virtual_network_name
  remote_virtual_network_id = module.mod_networking_operations.virtual_network_id
}

module "mod_ops_to_hub_networking_peering" {
  depends_on = [
    module.mod_networking_hub,
    module.mod_networking_operations
  ]
  source = "../../../enclaveSupport/overlays/hub-spoke-core/peering"

  // Global Settings
  location            = var.location
  resource_group_name = module.mod_networking_operations.resource_group_name

  // Operations Networking Peering Settings
  peering_name                 = "${module.mod_networking_operations.virtual_network_name}-to-${module.mod_networking_hub.virtual_network_name}"
  virtual_network_name         = module.mod_networking_operations.virtual_network_name
  remote_virtual_network_id    = module.mod_networking_hub.virtual_network_id
  allow_virtual_network_access = var.allow_virtual_network_access
  use_remote_gateways          = var.use_remote_gateways
}


################################
### STAGE 5: Remote Access   ###
################################

#########################################################################
### This stage is optional based on the value of `create_bastion_host`
#########################################################################

module "mod_bastion_host" {
  count      = var.enable_services.bastion_hosts ? 1 : 0
  depends_on = [module.mod_networking_hub]
  source     = "../../../enclaveSupport/overlays/managementServices/bastion"

  // Global Settings
  org_prefix          = var.org_prefix
  resource_group_name = module.mod_networking_hub.resource_group_name
  vnet_name           = module.mod_networking_hub.virtual_network_name
  location            = var.location

  // Bastion Host Settings
  virtual_network_name             = module.mod_networking_hub.virtual_network_name
  bastion_host_name                = var.bastion_host_name
  bastion_address_space            = var.bastion_address_space
  bastion_subnet_service_endpoints = var.bastion_subnet_service_endpoints

  // Jumpbox Settings
  admin_username      = var.jumpbox_admin_username
  use_random_password = var.use_random_password

  // Linux Jumpbox Settings
  create_bastion_linux_jumpbox = var.enable_services.bastion_linux_virtual_machines
  size_linux_jumpbox           = var.size_linux_jumpbox
  sku_linux_jumpbox            = var.sku_linux_jumpbox
  publisher_linux_jumpbox      = var.publisher_linux_jumpbox
  offer_linux_jumpbox          = var.offer_linux_jumpbox
  image_version_linux_jumpbox  = var.image_version_linux_jumpbox

  // Windows Jumpbox Settings
  create_bastion_windows_jumpbox = var.enable_services.bastion_windows_virtual_machines
  size_windows_jumpbox           = var.size_windows_jumpbox
  sku_windows_jumpbox            = var.sku_windows_jumpbox
  publisher_windows_jumpbox      = var.publisher_windows_jumpbox
  offer_windows_jumpbox          = var.offer_windows_jumpbox
  image_version_windows_jumpbox  = var.image_version_windows_jumpbox

  // Tags
  tags = merge(var.tags, {
    deployed-by = format("AzureNoOpsTF [%s]", terraform.workspace)
  })
}


#####################################
### STAGE 6: Defender for Cloud   ###
#####################################
