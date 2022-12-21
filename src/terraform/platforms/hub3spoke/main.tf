# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

/*
SUMMARY: Module Example to deploy an SCCA Compliant Platform Hub/Spoke Landing Zone
DESCRIPTION: The following components will be options in this deployment
              * Hub Virtual Network (VNet)
              * Virual Network Gateway (Optional)
              * Operations Artifacts (Optional)
              * Bastion Host (Optional)
              * DDos Standard Plan (Optional)
              * Microsoft Defender for Cloud (Optional)
              * Automation Account (Optional)
            * Spokes
              * Identity (Tier 0)
              * Operations (Tier 1)
              * Shared Services (Tier 2)
            * Logging
              * Azure Sentinel
              * Azure Log Analytics
            * Azure Firewall
            * Private DNS Zones - Details of all the Azure Private DNS zones can be found here --> [https://docs.microsoft.com/en-us/azure/private-link/private-endpoint-dns#azure-services-dns-zone-configuration](https://docs.microsoft.com/en-us/azure/private-link/private-endpoint-dns#azure-services-dns-zone-configuration)
AUTHOR/S: jspinella

IMPORTANT: This module is not intended to be used as a standalone module. It is intended to be used as a module within a Misson Enclave deployment. Please see the Mission Enclave documentation for more information.
*/


terraform {
  # It is recommended to use remote state instead of local
  # If you are using Terraform Cloud, You can update these values in order to configure your remote state.
  /*  backend "remote" {
    organization = "{{ORGANIZATION_NAME}}"
    workspaces {
      name = "{{WORKSPACE_NAME}}"
    }
  }
  */

  backend "local" {}

  required_version = ">= 1.2.9"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "= 3.23.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "= 3.4.3"
    }
    time = {
      source  = "hashicorp/time"
      version = "0.8.0"
    }
  }
}

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

provider "azurerm" {
  alias           = "hub"
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

provider "azurerm" {
  alias           = "logging"
  environment     = var.environment
  metadata_host   = var.metadata_host
  subscription_id = coalesce(var.ops_subid, var.hub_subid)

  features {
    log_analytics_workspace {
      permanently_delete_on_destroy = true
    }
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}

provider "azurerm" {
  alias           = "operations"
  environment     = var.environment
  metadata_host   = var.metadata_host
  subscription_id = coalesce(var.ops_subid, var.hub_subid)

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

data "azurerm_client_config" "current_client" {
}

################################
### GLOBAL VARIABLES         ###
################################

locals {
  firewall_premium_environments = ["public", "usgovernment"] # terraform azurerm environments where Azure Firewall Premium is supported
}

################################
### STAGE 0: Scaffolding     ###
################################


################################
### STAGE 1: Logging         ###
################################

module "mod_logging" {
  providers = { azurerm = azurerm.logging }
  source    = "../../azresources/hub-spoke-core/vdms/logging"

  // Global Settings
  global_settings = var.global_settings
  client_config   = var.client_config
  location        = var.location

  // Logging Settings
  ops_logging_subid         = var.ops_subid
  ops_logging_rgname        = var.ops_logging_rgname
  ops_logging_log_analytics = var.logging_log_analytics
  create_sentinel           = var.create_sentinel
  logging_storage_account   = var.logging_storage_account

  // Tags
  tags = var.tags
}

###################################
## STAGE 2: Hub Networking      ###
###################################

module "mod_networking_hub" {
  providers = { azurerm = azurerm.hub }
  depends_on = [
    module.mod_logging
  ]
  source = "../../azresources/hub-spoke-core/vdss/hub"

  // Global Settings
  global_settings    = var.global_settings
  client_config      = var.client_config
  org_prefix         = var.org_prefix
  location           = var.location
  deploy_environment = var.deploy_environment

  // Logging Settings
  log_analytics_resource_id  = module.mod_logging.laws_resource_id
  log_analytics_workspace_id = module.mod_logging.laws_workspace_id
  log_analytics_storage_id   = module.mod_logging.laws_StorageAccount_Id

  // Hub Networking Settings
  hub_vnetname                                   = var.hub_vnetname
  hub_vnet_address_space                         = var.hub_vnet_address_space
  hub_rgname                                     = var.hub_rgname
  hub_subid                                      = var.hub_subid
  hub_fw_client_address_space                    = var.hub_fw_client_address_space
  hub_fw_management_address_space                = var.hub_fw_management_address_space
  hub_virtual_network_diagnostics_logs           = var.hub_virtual_network_diagnostics_logs
  hub_network_security_group_diagnostics_metrics = var.hub_virtual_network_diagnostics_metrics
  hub_network_security_group_diagnostics_logs    = var.hub_network_security_group_diagnostics_logs
  hub_virtual_network_diagnostics_metrics        = var.hub_virtual_network_diagnostics_metrics
  hub_network_security_group_rules               = var.hub_network_security_group_rules
  hub_subnet_service_endpoints                   = var.hub_subnet_service_endpoints

  // Hub Firewall Settings
  firewall_name                                           = var.firewall_name
  firewall_sku_name                                       = var.firewall_sku_name
  firewall_sku_tier                                       = var.firewall_sku_tier
  firewall_diagnostics_logs                               = var.firewall_diagnostics_logs
  firewall_diagnostics_metrics                            = var.firewall_diagnostics_metrics
  firewall_client_publicIP_address_availability_zones     = var.firewall_client_publicIP_address_availability_zones
  firewall_management_publicIP_address_availability_zones = var.firewall_management_publicIP_address_availability_zones
  firewall_client_subnet_service_endpoints                = var.firewall_client_subnet_service_endpoints
  firewall_management_subnet_service_endpoints            = var.firewall_management_subnet_service_endpoints
  firewall_threat_detection_mode                          = var.firewall_threat_detection_mode
  firewall_threat_intel_mode                              = var.firewall_threat_intel_mode

  // Hub Resource Locks
  enable_resource_locks = var.enable_resource_locks

  // Tags
  tags = var.tags # Tags to be applied to all resources

}


######################################
### STAGE 2.1: Network Artifacts   ###
######################################

##############################################################################
### This stage is optional based on the value of `create_network_artifacts` ##
##############################################################################

module "mod_network_artifacts" {
  providers = { azurerm = azurerm.hub }
  depends_on = [
    module.mod_networking_hub
  ]
  source = "../../azresources/hub-spoke-core/vdss/networkArtifacts"
  count  = var.create_network_artifacts ? 1 : 0

  // Global Settings
  global_settings    = var.global_settings
  client_config      = var.client_config
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
  tags = var.tags # Tags to be applied to all resources
}

##########################################
## STAGE 3: Operations Networking      ###
##########################################

module "mod_networking_operations" {
  providers = { azurerm = azurerm.operations }
  depends_on = [
    module.mod_logging
  ]
  source = "../../azresources/hub-spoke-core/vdms/operations"

  // Global Settings
  global_settings    = var.global_settings
  client_config      = var.client_config
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
  tags = var.tags # Tags to be applied to all resources
}

######################################
## STAGE 4: Identity Networking    ###
######################################

module "mod_networking_operations" {
  providers = { azurerm = azurerm.operations }
  depends_on = [
    module.mod_logging
  ]
  source = "../../azresources/hub-spoke-core/vdms/operations"

  // Global Settings
  global_settings    = var.global_settings
  client_config      = var.client_config
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
  tags = var.tags # Tags to be applied to all resources
}

###########################################
## STAGE 5: Shared Services Networking  ###
###########################################

module "mod_networking_operations" {
  providers = { azurerm = azurerm.operations }
  depends_on = [
    module.mod_logging
  ]
  source = "../../azresources/hub-spoke-core/vdms/operations"

  // Global Settings
  global_settings    = var.global_settings
  client_config      = var.client_config
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
  tags = var.tags # Tags to be applied to all resources
}

####################################
## STAGE 6: Networking Peering   ###
####################################

module "mod_hub_to_ops_networking_peering" {
  providers = { azurerm = azurerm.hub }
  depends_on = [
    module.mod_networking_hub,
    module.mod_networking_operations
  ]
  source = "../../azresources/hub-spoke-core/peering"

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
  providers = { azurerm = azurerm.operations }
  depends_on = [
    module.mod_networking_hub,
    module.mod_networking_operations
  ]
  source = "../../azresources/hub-spoke-core/peering"

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

module "mod_hub_to_id_networking_peering" {
  providers = { azurerm = azurerm.hub }
  depends_on = [
    module.mod_networking_hub,
    module.mod_networking_operations
  ]
  source = "../../azresources/hub-spoke-core/peering"

  count = var.peer_to_hub_virtual_network == false ? 0 : 1

  // Global Settings
  location            = var.location
  resource_group_name = module.mod_networking_hub.resource_group_name

  // Hub Networking Peering Settings
  peering_name              = "${module.mod_networking_hub.virtual_network_name}-to-${module.mod_networking_operations.virtual_network_name}"
  virtual_network_name      = module.mod_networking_hub.virtual_network_name
  remote_virtual_network_id = module.mod_networking_operations.virtual_network_id
}

module "mod_id_to_hub_networking_peering" {
  providers = { azurerm = azurerm.operations }
  depends_on = [
    module.mod_networking_hub,
    module.mod_networking_operations
  ]
  source = "../../azresources/hub-spoke-core/peering"

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

module "mod_hub_to_svcs_networking_peering" {
  providers = { azurerm = azurerm.hub }
  depends_on = [
    module.mod_networking_hub,
    module.mod_networking_operations
  ]
  source = "../../azresources/hub-spoke-core/peering"

  count = var.peer_to_hub_virtual_network == false ? 0 : 1

  // Global Settings
  location            = var.location
  resource_group_name = module.mod_networking_hub.resource_group_name

  // Hub Networking Peering Settings
  peering_name              = "${module.mod_networking_hub.virtual_network_name}-to-${module.mod_networking_operations.virtual_network_name}"
  virtual_network_name      = module.mod_networking_hub.virtual_network_name
  remote_virtual_network_id = module.mod_networking_operations.virtual_network_id
}

module "mod_svcs_to_hub_networking_peering" {
  providers = { azurerm = azurerm.operations }
  depends_on = [
    module.mod_networking_hub,
    module.mod_networking_operations
  ]
  source = "../../azresources/hub-spoke-core/peering"

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
### STAGE 7: Remote Access   ###
################################

#########################################################################
### This stage is optional based on the value of `create_bastion_jumpbox`
#########################################################################



#####################################
### STAGE 8: Defender for Cloud   ###
#####################################


############################################
### STAGE 9: Policy Compliance example   ###
############################################
