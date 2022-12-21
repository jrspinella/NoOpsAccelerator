#################################
# Global Configuration
#################################

variable "global_settings" {
  description = "Global settings object"
}
variable "client_config" {
  description = "Client configuration object"
}

variable "tags" {
  description = "A map of key value pairs to apply as tags to resources provisioned in this deployment"
  type        = map(string)
  default = {}
}

variable "org_prefix" {
  description = "A name for the organization. It defaults to anoa."
  type        = string
}

variable "location" {
  description = ""
  type        = string
}

variable "deploy_environment" {
  description = "The environment to deploy to. It defaults to 'dev'."
  type        = string
  default     = "dev"
}

#################################
# Logging Configuration
#################################

variable "log_analytics_resource_id" {
  description = "The name of the log analytics workspace resource id"
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "The name of the log analytics workspace"
  type        = string
}

variable "log_analytics_storage_id" {
  description = "The name of the log analytics storage account"
  type        = string
}

#################################
# Hub Configuration
#################################

variable "hub_subid" {
  description = "Subscription ID for the Hub deployment"
  type        = string
}

variable "hub_rgname" {
  description = "Resource Group for the deployment"
  type        = string
  default     = "hub"
}

variable "hub_vnetname" {
  description = "Virtual Network Name for the deployment"
  type        = string
  default     = "hub-vnet"
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
  type        = map(object({
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
  description = "An array of Network Security Group diagnostic logs to apply to the Hub Virtual Network. See https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-nsg-manage-log#log-categories for valid settings."
  type        = list(string)
  default     = ["NetworkSecurityGroupEvent", "NetworkSecurityGroupRuleCounter"]
}

variable "hub_network_security_group_diagnostics_metrics" {
  description = "An array of Network Security Group Metrics to apply to enable for the Hub Virtual Network. See https://docs.microsoft.com/en-us/azure/azure-monitor/essentials/diagnostic-settings?tabs=CMD#metrics for valid settings."
  type        = list(string)
  default     = []
}

variable "hub_subnet_service_endpoints" {
  description = "An array of Service Endpoints to enable for the Hub subnet. See https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-service-endpoints-overview for valid settings."
  type        = list(string)
  default     = ["Microsoft.Storage"]
}

variable "ddos_id" {
  description = "DDOS id for the virtual network"
  type        = string
  default     = ""
}

variable "hub_logging_storage_account" {
  description = "Storage Account variables for the hub deployment"
  default     = {}
}

variable "enable_resource_locks" {
  description = "Flag to enable locks on the hub resources"
  type        = bool
  default     = true
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

variable "firewall_name" {
  description = "Name of the Hub Firewall"
  type        = string
  default     = "firewall"
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
  description = "Name of the firewall policy to apply to the hub firewall"
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

variable "client_publicip_name" {
  description = "The name of the Firewall Client Public IP"
  type        = string
  default     = "firewall-client-public-ip"
}

variable "management_ipconfig_name" {
  description = "The name of the Firewall Management IP Configuration"
  type        = string
  default     = "firewall-management-ip-config"
}

variable "management_publicip_name" {
  description = "The name of the Firewall Management Public IP"
  type        = string
  default     = "firewall-management-public-ip"
}



