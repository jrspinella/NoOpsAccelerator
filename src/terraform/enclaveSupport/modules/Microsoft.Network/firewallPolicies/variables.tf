# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

variable "location" {
  description = "The location/region to keep all your network resources. To get the list of all locations with table format from azure cli, run 'az account list-locations -o table'"
  type        = string
}

variable "resource_group_name" {
  description = "A container that holds related resources for an Azure solution"
  type        = string
}

variable "firewall_policy_name" {
  description = "The name of the Firewall Policy Name"
  type        = string
}

variable "firewall_sku" {
  description = "The SKU for Azure Firewall"
  type        = string
}

variable "firewall_policy_collection_group_name" {
  description = "The name of the Firewall Policy Collection Group"
  type        = string
}

variable "application_rule_collection" {
  description = "The Firewall Policy Applicatiom Rule Collection"
  type = set(object(
    {
      action   = string
      name     = string
      priority = number
      rule = set(object(
        {
          destination_fqdn_tags = set(string)
          destination_fqdns     = set(string)
          name                  = string
          protocols = set(object(
            {
              port = number
              type = string
            }
          ))
          source_addresses = set(string)
          source_ip_groups = set(string)
        }
      ))
    }
  ))
  default = []
}

variable "network_rule_collection" {
  description = "The Firewall Policy Network Rule Collection"
  type = set(object(
    {
      action   = string
      name     = string
      priority = number
      rule = set(object(
        {
          destination_addresses = set(string)
          destination_fqdns     = set(string)
          destination_ip_groups = set(string)
          destination_ports     = set(string)
          name                  = string
          protocols             = set(string)
          source_addresses      = set(string)
          source_ip_groups      = set(string)
        }
      ))
    }
  ))
  default = []
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "enable_diagnostic_settings" {
  description = "Create a bastion host and jumpbox VM?"
  type        = bool
  default = false
}

variable "diagnostics_name" {
  description = "diagnostic settings name on this resource."
  type        = string
  default = ""
}

variable "fw_log_categories" {
  description = "List of Diagnostic Log Categories"
  type        = list(string)
  default = [  ]
}

variable "fw_metric_categories" {
  description = "List of Diagnostic Metric Categories"
  type        = list(string)
  default = [  ]
}

variable "flow_log_retention_in_days" {
  description = "The number of days to retain flow log data"
  default     = "7"
  type        = number
}

