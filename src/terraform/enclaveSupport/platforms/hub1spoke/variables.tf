# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

/*
  PARAMETERS
  Here are all the variables a user can override.
*/

#################################
# Global Configuration
#################################

variable "required" {
  description = "Map of services defined in the configuration file you want to disable during a deployment."
  default = {
    org_prefix         = "anoa"
    deploy_environment = "dev"
  }
}

variable "tags" {
  description = "A map of key value pairs to apply as tags to resources provisioned in this deployment"
  type        = map(string)
  default = {
    "Organization" : "anoa",
    "Region" : "eastus",
    "DeployEnvironment" : "dev"
  }
}

variable "enable_services" {
  description = "Map of services defined in the configuration file you want to disable during a deployment."
  default = {
    bastion_hosts                    = true // true to create a bastion host
    bastion_linux_virtual_machines   = true // true to create a linux bastion host
    bastion_windows_virtual_machines = true // true to create a windows bastion host
    ops_network_artifacts            = false // true to create a network artifacts for operations
    enable_resource_locks            = false // true to enable resource locks
  }
}

variable "environment" {
  description = "The Terraform backend environment e.g. public or usgovernment"
  type        = string
  default     = "public"
}

variable "metadata_host" {
  description = "The metadata host for the Azure Cloud e.g. management.azure.com or management.usgovcloudapi.net."
  type        = string
  default     = "management.azure.com"
}

variable "location" {
  description = "The Azure region for most Platform LZ resources. e.g. for government usgovvirginia"
  type        = string
  default     = "eastus"
}

variable "org_prefix" {
  description = "A name for the organization. It defaults to anoa."
  type        = string
  default     = "anoa"
}

variable "deploy_environment" {
  description = "The Terraform backend environment e.g. public or usgovernment"
  type        = string
  default     = "dev"
}

variable "subscriptions" {
  description = "Configuration object - Subscriptions resources."
  default     = {}
}

variable "transport_subscription_id" {
  description = "Transport subscription id"
  default     = null
}

#######################################
# Operations - Logging Configuration ##
#######################################

variable "ops_logging_rgname" {
  description = "Resource Group for the deployment"
  type        = string
  default     = "logging"
}

variable "create_sentinel" {
  description = "Create a Sentinel Workspace for the deployment"
  type        = bool
  default     = true
}

variable "logging_storage_account" {
  description = "Storage Account variables for the logging deployment"
  default = {
    access_tier              = "Hot"
    account_kind             = "StorageV2"
    account_replication_type = "LRS"
    account_tier             = "Standard"
    min_tls_version          = "TLS1_2"
    enable_locks             = true
    tags                     = {}
  }
}

variable "logging_log_analytics" {
  description = "Log Analytics Workspace variables for the deployment"
  default = {
    sku               = "PerGB2018"
    retention_in_days = 30
  }
}

#################################
# Hub Configuration
#################################

variable "hub_subid" {
  description = "Subscription ID for the Hub deployment"
  type        = string
  default     = "896f5276-df9a-4317-a791-469396bef7fa"

  validation {
    condition     = can(regex("^[a-z0-9-]{36}$", var.hub_subid)) || var.hub_subid == ""
    error_message = "Value must be a valid Subscription ID (GUID)."
  }
}

variable "hub_vnet_address_space" {
  description = "The CIDR Virtual Network Address Prefix for the Hub Virtual Network."
  type        = list(string)
  default     = ["10.0.100.0/24"]
}

variable "hub_vnet_subnet_address_space" {
  description = "The CIDR Subnet Address Prefix for the default Hub subnet. It must be in the Hub Virtual Network space.'"
  type        = string
  default     = "10.0.100.128/27"
}

variable "hub_virtual_network_diagnostics_logs" {
  description = "An array of Network Diagnostic Logs to enable for the Hub Virtual Network. See https://docs.microsoft.com/en-us/azure/azure-monitor/essentials/diagnostic-settings?tabs=CMD#logs for valid settings."
  type        = list(string)
  default     = []
}

variable "hub_virtual_network_diagnostics_metrics" {
  description = "An array of Network Diagnostic Metrics to enable for the Hub Virtual Network. See https://docs.microsoft.com/en-us/azure/azure-monitor/essentials/diagnostic-settings?tabs=CMD#metrics for valid settings."
  type        = list(string)
  default     = ["AllMetrics"]
}

variable "hub_network_security_group_rules" {
  description = "An array of Network Security Group Rules to apply to the Hub Virtual Network. See https://docs.microsoft.com/en-us/azure/templates/microsoft.network/networksecuritygroups/securityrules?tabs=bicep#securityrulepropertiesformat for valid settings."
  type = map(object({
    name                       = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
  }))
  default = {}
}

variable "hub_network_security_group_diagnostics_logs" {
  description = "An array of Network Security Group diagnostic logs to apply to the Identity Virtual Network. See https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-nsg-manage-log#log-categories for valid settings."
  type        = list(string)
  default     = ["NetworkSecurityGroupEvent", "NetworkSecurityGroupRuleCounter"]
}

variable "hub_network_security_group_diagnostics_metrics" {
  description = "An array of Network Security Group Metrics to apply to enable for the Identity Virtual Network. See https://docs.microsoft.com/en-us/azure/azure-monitor/essentials/diagnostic-settings?tabs=CMD#metrics for valid settings."
  type        = list(string)
  default     = []
}

variable "hub_subnet_service_endpoints" {
  description = "An array of Service Endpoints to enable for the Hub subnet. See https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-service-endpoints-overview for valid settings."
  type        = list(string)
  default     = ["Microsoft.Storage"]
}

variable "enable_ddos_protection" {
  description = "Flag to enable DDoS protection plan for the virtual network"
  type        = bool
  default     = false
}

variable "ddos_protection_plan_id" {
  description = "DDOS id for the virtual network"
  type        = string
  default     = ""
}

variable "hub_logging_storage_account" {
  description = "Storage Account variables for the hub deployment"
  default = {
    access_tier              = "Hot"
    account_kind             = "StorageV2"
    account_replication_type = "LRS"
    account_tier             = "Standard"
    min_tls_version          = "TLS1_2"
    enable_locks             = true
    tags                     = {}
  }
}

####################################
# Network Artifacts Configuration ##
####################################

variable "enable_network_artifacts_diagnostics" {
  description = "Flag to enable diagnostics for the network artifacts"
  type        = bool
  default     = false
}

variable "network_artifacts_storage_account" {
  description = "Storage account configuration object"
  type = object({
    sku_name = string
    kind     = string
  })
  default = {
    sku_name = "Standard_LRS"
    kind     = "StorageV2"
  }
}

variable "kv_sku_name" {
  description = "The name of the SKU used for this key vault. Possible values are standard and premium."
  type        = string
  default     = "standard"
}

variable "kv_soft_delete_retention_days" {
  description = "The number of days that soft-deleted keys should be retained. Must be between 7 and 90."
  type        = number
  default     = 90
}

variable "kv_purge_protection_enabled" {
  description = "Enable purge protection on this key vault"
  type        = bool
  default     = false
}

variable "kv_enable_access_policy" {
  description = "Enable access policy on this key vault"
  type        = bool
  default     = false
}

variable "kv_enabled_for_deployment" {
  description = "Enable deployment on this key vault"
  type        = bool
  default     = false
}

variable "kv_enabled_for_disk_encryption" {
  description = "Enable disk encryption on this key vault"
  type        = bool
  default     = false
}

variable "kv_enabled_for_template_deployment" {
  description = "Enable template deployment on this key vault"
  type        = bool
  default     = false
}

variable "kv_enable_rbac_authorization" {
  description = "Enable RBAC authorization on this key vault"
  type        = bool
  default     = false
}

#################################
# Firewall configuration section
#################################

variable "hub_fw_client_address_space" {
  description = "The CIDR Subnet Address Prefix for the Azure Firewall Subnet. It must be in the Hub Virtual Network space. It must be /26."
  type        = string
  default     = "10.0.100.0/26"
}

variable "hub_fw_management_address_space" {
  description = "The CIDR Subnet Address Prefix for the Azure Firewall Management Subnet. It must be in the Hub Virtual Network space. It must be /26."
  type        = string
  default     = "10.0.100.64/26"
}

variable "firewall_sku_tier" {
  description = "[Standard/Premium] The SKU for Azure Firewall. It defaults to Premium."
  type        = string
  default     = "Premium"
}

variable "firewall_sku_name" {
  description = "SKU name of the Firewall. Possible values are AZFW_Hub and AZFW_VNet."
  type        = string
  default     = "AZFW_VNet"
}

variable "firewall_threat_intel_mode" {
  description = "[Alert/Deny/Off] The Azure Firewall Threat Intelligence Rule triggered logging behavior. Valid values are 'Alert', 'Deny', or 'Off'. The default value is 'Alert'"
  type        = string
  default     = "Alert"
}

variable "firewall_threat_detection_mode" {
  description = "[Alert/Deny/Off] The Azure Firewall Intrusion Detection mode. Valid values are 'Alert', 'Deny', or 'Off'. The default value is 'Alert'"
  type        = string
  default     = "Alert"
}

variable "firewall_diagnostics_logs" {
  description = "An array of Firewall Diagnostic Logs categories to collect. See 'https://docs.microsoft.com/en-us/azure/firewall/firewall-diagnostics#enable-diagnostic-logging-through-the-azure-portal' for valid values."
  type        = list(string)
  default     = ["AzureFirewallApplicationRule", "AzureFirewallNetworkRule", "AzureFirewallDnsProxy"]
}

variable "firewall_diagnostics_metrics" {
  description = "An array of Firewall Diagnostic Metrics categories to collect. See 'https://docs.microsoft.com/en-us/azure/firewall/firewall-diagnostics#enable-diagnostic-logging-through-the-azure-portal' for valid values."
  type        = list(string)
  default     = ["AllMetrics"]
}

variable "firewall_client_subnet_service_endpoints" {
  description = "An array of Service Endpoints to enable for the Azure Firewall Client Subnet. See https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-service-endpoints-overview for valid settings."
  type        = list(string)
  default     = []
}

variable "firewall_client_publicIP_address_availability_zones" {
  description = "An array of Azure Firewall Public IP Address Availability Zones. It defaults to empty, or 'No-Zone', because Availability Zones are not available in every cloud. See https://docs.microsoft.com/en-us/azure/virtual-network/ip-services/public-ip-addresses#sku for valid settings."
  type        = list(string)
  default     = []
}

variable "firewall_management_subnet_service_endpoints" {
  description = "An array of Service Endpoints to enable for the Azure Firewall Management Subnet. See https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-service-endpoints-overview for valid settings."
  type        = list(string)
  default     = []
}

variable "firewall_management_publicIP_address_availability_zones" {
  description = "An array of Azure Firewall Public IP Address Availability Zones. It defaults to empty, or 'No-Zone', because Availability Zones are not available in every cloud. See https://docs.microsoft.com/en-us/azure/virtual-network/ip-services/public-ip-addresses#sku for valid settings."
  type        = list(string)
  default     = []
}

variable "firewall_supernet_IP_address" {
  description = "The IP address range that is used to allow traffic from the Azure Firewall to the Internet. It must be in the Hub Virtual Network space. It must be /19."
  type        = string
  default     = "10.0.96.0/19"
}

variable "publicIP_address_diagnostics_logs" {
  description = "An array of Public IP Address Diagnostic Logs for the Azure Firewall. See https://docs.microsoft.com/en-us/azure/ddos-protection/diagnostic-logging?tabs=DDoSProtectionNotifications#configure-ddos-diagnostic-logs for valid settings."
  type        = list(string)
  default     = ["DDoSProtectionNotifications", "DDoSMitigationFlowLogs", "DDoSMitigationReports"]
}

variable "publicIP_address_diagnostics_metrics" {
  description = "An array of Public IP Address Diagnostic Metrics for the Azure Firewall. See https://docs.microsoft.com/en-us/azure/ddos-protection/diagnostic-logging?tabs=DDoSProtectionNotifications#configure-ddos-diagnostic-logs for valid settings."
  type        = list(string)
  default     = ["AllMetrics"]
}

variable "client_ipconfig_name" {
  description = "The name of the Firewall Client IP Configuration"
  type        = string
  default     = "firewall-client-ip-config"
}

variable "management_ipconfig_name" {
  description = "The name of the Firewall Management IP Configuration"
  type        = string
  default     = "firewall-management-ip-config"
}

#################################
# Bastion Host Configuration
#################################

variable "bastion_host_name" {
  description = "The name of the Bastion Host"
  type        = string
  default     = "bastionHost"
}

variable "bastion_address_space" {
  description = "The address space to be used for the Bastion Host subnet (must be /27 or larger)."
  type        = string
  default     = "10.0.100.160/27"
}

variable "bastion_public_ip_name" {
  description = "The name of the Bastion Host Public IP"
  type        = string
  default     = "bastionHostPublicIPAddress"
}

variable "bastion_subnet_service_endpoints" {
  description = "An array of Service Endpoints to enable for the Bastion Host Subnet. See https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-service-endpoints-overview for valid settings."
  type        = list(string)
  default     = []
}

variable "bastion_nsg_rules" {
  description = "A list of maps containing the following keys: name, description, access, priority, protocol, direction, source_port_ranges, source_address_prefix, destination_port_ranges, destination_address_prefix"
  type        = list(map(string))
  default     = []
  }

variable "is_create_default_public_ip" {
  description = "(Optional) Specifies if a public ip should be created by default if one is not provided."
  type        = bool
  default     = true
}

#################################
# Jumpbox VM Configuration    ###
#################################

variable "jumpbox_admin_username" {
  description = "The username of the Jumpbox VM admin account"
  type        = string
  default     = "azureadmin"
}

variable "use_random_password" {
  description = "Set this to true to use a random password for the VMs. If set to false, the password will be stored in the terraform state file."
  type        = bool
  default     = true
}

#######################################
# Jumpbox Linux VM Configuration    ###
#######################################

variable "size_linux_jumpbox" {
  description = "The size of the linux Jumpbox VM"
  type        = string
  default     = "Standard_B1s"
}

variable "publisher_linux_jumpbox" {
  description = "The publisher of the linux Jumpbox VM OS image"
  type        = string
  default     = "Canonical"
}

variable "offer_linux_jumpbox" {
  description = "The offer of the linux Jumpbox VM OS image"
  type        = string
  default     = "UbuntuServer"
}

variable "sku_linux_jumpbox" {
  description = "The SKU of the linux Jumpbox VM OS image"
  type        = string
  default     = "18.04-LTS"
}

variable "image_version_linux_jumpbox" {
  description = "The version of the linux Jumpbox VM OS image"
  type        = string
  default     = "latest"
}

#########################################
# Jumpbox Windows VM Configuration    ###
#########################################

variable "size_windows_jumpbox" {
  description = "The size of the windows Jumpbox VM"
  type        = string
  default     = "Standard_B1s"
}


variable "publisher_windows_jumpbox" {
  description = "The publisher of the windows Jumpbox VM OS image"
  type        = string
  default     = "Canonical"
}

variable "offer_windows_jumpbox" {
  description = "The offer of the windows Jumpbox VM OS image"
  type        = string
  default     = "UbuntuServer"
}

variable "sku_windows_jumpbox" {
  description = "The SKU of the windows Jumpbox VM OS image"
  type        = string
  default     = "18.04-LTS"
}

variable "image_version_windows_jumpbox" {
  description = "The version of the windows Jumpbox VM OS image"
  type        = string
  default     = "latest"
}



######################################
# Tier 1 - Operations Configuration ##
######################################

variable "ops_subid" {
  description = "Subscription ID for the deployment"
  type        = string
  default     = "896f5276-df9a-4317-a791-469396bef7fa"

  validation {
    condition     = can(regex("^[a-z0-9-]{36}$", var.ops_subid)) || var.ops_subid == ""
    error_message = "Value must be a valid Subscription ID (GUID)."
  }
}

variable "ops_rgname" {
  description = "Resource Group for the deployment"
  type        = string
  default     = "operations"
}

variable "ops_vnetname" {
  description = "Virtual Network Name for the deployment"
  type        = string
  default     = "operations-vnet"
}

variable "ops_vnet_address_space" {
  description = "The CIDR Virtual Network Address Prefix for the ops Virtual Network."
  type        = list(string)
  default     = ["10.0.115.0/26"]
}

variable "ops_vnet_subnet_address_space" {
  description = "The CIDR Subnet Address Prefix for the default ops subnet. It must be in the ops Virtual Network space.'"
  type        = string
  default     = "10.0.115.0/27"
}

variable "ops_virtual_network_diagnostics_logs" {
  description = "An array of Network Diagnostic Logs to enable for the ops Virtual Network. See https://docs.microsoft.com/en-us/azure/azure-monitor/essentials/diagnostic-settings?tabs=CMD#logs for valid settings."
  type        = list(string)
  default     = []
}

variable "ops_virtual_network_diagnostics_metrics" {
  description = "An array of Network Diagnostic Metrics to enable for the ops Virtual Network. See https://docs.microsoft.com/en-us/azure/azure-monitor/essentials/diagnostic-settings?tabs=CMD#metrics for valid settings."
  type        = list(string)
  default     = ["AllMetrics"]
}

variable "ops_network_security_group_rules" {
  description = "An array of Network Security Group Rules to apply to the ops Virtual Network. See https://docs.microsoft.com/en-us/azure/templates/microsoft.network/networksecuritygroups/securityrules?tabs=bicep#securityrulepropertiesformat for valid settings."
  type = map(object({
    name                       = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = list(string)
    source_address_prefix      = list(string)
    destination_address_prefix = list(string)
  }))
  default = {}
}

variable "ops_network_security_group_diagnostics_logs" {
  description = "An array of Network Security Group diagnostic logs to apply to the Identity Virtual Network. See https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-nsg-manage-log#log-categories for valid settings."
  type        = list(string)
  default     = ["NetworkSecurityGroupEvent", "NetworkSecurityGroupRuleCounter"]
}

variable "ops_network_security_group_diagnostics_metrics" {
  description = "An array of Network Security Group Metrics to apply to enable for the Identity Virtual Network. See https://docs.microsoft.com/en-us/azure/azure-monitor/essentials/diagnostic-settings?tabs=CMD#metrics for valid settings."
  type        = list(string)
  default     = []
}

variable "ops_subnet_service_endpoints" {
  description = "An array of Service Endpoints to enable for the ops subnet. See https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-service-endpoints-overview for valid settings."
  type        = list(string)
  default     = ["Microsoft.Storage"]
}

variable "ops_logging_storage_account" {
  description = "Storage Account variables for the ops deployment"
  type = object({
    sku_name = string
    kind     = string
  })
  default = {
    sku_name = "Standard_LRS"
    kind     = "StorageV2"
  }
}

##################################
# Network Peering Configuration ##
##################################

variable "peer_to_hub_virtual_network" {
  description = "A boolean value to indicate if the ops Virtual Network should peer to the hub Virtual Network."
  type        = bool
  default     = true
}

variable "allow_virtual_network_access" {
  description = "Allow access from the remote virtual network to use this virtual network's gateways. Defaults to false."
  type        = bool
  default     = true
}

variable "use_remote_gateways" {
  description = "Use remote gateways from the remote virtual network. Defaults to false."
  type        = bool
  default     = false
}

#########################
# Policy Configuration ##
#########################
