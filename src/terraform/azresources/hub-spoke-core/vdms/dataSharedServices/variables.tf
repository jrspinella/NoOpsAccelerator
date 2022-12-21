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
  default = {
    "DeploymentType" : "AzureNoOpsTF"
  }
}

variable "org_prefix" {
  description = "A name for the organization. It defaults to anoa."
  type        = string
}

variable "location" {
  description = "A name for the organization. It defaults to anoa."
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
  default = ""
}

variable "log_analytics_workspace_id" {
  description = "The name of the log analytics workspace"
  type        = string
  default = ""
}

variable "log_analytics_storage_id" {
  description = "The name of the log analytics storage account"
  type        = string
  default = ""
}

#################################
# Tier 1 Configuration
#################################

variable "datasvcs_subid" {
  description = "Subscription ID for the deployment"
  type        = string
  default     = ""
}

variable "datasvcs_rgname" {
  description = "Resource Group for the deployment"
  type        = string
  default     = "operations"
}

variable "datasvcs_vnetname" {
  description = "Virtual Network Name for the deployment"
  type        = string
  default     = "operations-vnet"
}

variable "datasvcs_vnet_address_space" {
  description = "The CIDR Virtual Network Address Prefix for the datasvcs Virtual Network."
  type        = list(string)
  default     = ["10.0.100.0/24"]
}

variable "datasvcs_vnet_subnet_address_space" {
  description = "The CIDR Subnet Address Prefix for the default datasvcs subnet. It must be in the datasvcs Virtual Network space.'"
  type        = string
  default     = "10.0.100.128/27"
}

variable "datasvcs_virtual_network_diagnostics_logs" {
  description = "An array of Network Diagnostic Logs to enable for the datasvcs Virtual Network. See https://docs.microsoft.com/en-us/azure/azure-monitor/essentials/diagnostic-settings?tabs=CMD#logs for valid settings."
  type        = list(string)
  default     = []
}

variable "datasvcs_virtual_network_diagnostics_metrics" {
  description = "An array of Network Diagnostic Metrics to enable for the datasvcs Virtual Network. See https://docs.microsoft.com/en-us/azure/azure-monitor/essentials/diagnostic-settings?tabs=CMD#metrics for valid settings."
  type        = list(string)
  default     = ["AllMetrics"]
}

variable "datasvcs_network_security_group_rules" {
  description = "An array of Network Security Group Rules to apply to the datasvcs Virtual Network. See https://docs.microsoft.com/en-us/azure/templates/microsoft.network/networksecuritygroups/securityrules?tabs=bicep#securityrulepropertiesformat for valid settings."
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

variable "datasvcs_network_security_group_diagnostics_logs" {
  description = "An array of Network Security Group diagnostic logs to apply to the Identity Virtual Network. See https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-nsg-manage-log#log-categories for valid settings."
  type        = list(string)
  default     = ["NetworkSecurityGroupEvent", "NetworkSecurityGroupRuleCounter"]
}

variable "datasvcs_network_security_group_diagnostics_metrics" {
  description = "An array of Network Security Group Metrics to apply to enable for the Identity Virtual Network. See https://docs.microsoft.com/en-us/azure/azure-monitor/essentials/diagnostic-settings?tabs=CMD#metrics for valid settings."
  type        = list(string)
  default     = []
}

variable "datasvcs_subnet_service_endpoints" {
  description = "An array of Service Endpoints to enable for the datasvcs subnet. See https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-service-endpoints-overview for valid settings."
  type        = list(string)
  default     = ["Microsoft.Storage"]
}

variable "datasvcs_logging_storage_account" {
  description = "Storage Account variables for the datasvcs deployment"
  type = object({
    sku_name = string
    kind     = string
  })
  default = {
    sku_name = "Standard_LRS"
    kind     = "StorageV2"
  }
}

#################################
# Firewall configuration section
#################################

variable "firewall_private_ip" {
  description = "The private IP address of the firewall"
  type        = string
  default     = ""
}
