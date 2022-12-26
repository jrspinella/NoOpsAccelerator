# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

output "hub_subid" {
  description = "Subscription ID where the Hub Resource Group is provisioned"
  value       = var.hub_subid
}

/* output "hub_rgname" {
  description = "The Hub Resource Group name"
  value       = azurerm_resource_group.hub.name
} */

/* output "hub_vnetname" {
  description = "The Hub Virtual Network name"
  value       = module.hub-network.virtual_network_name
}

output "firewall_private_ip" {
  description = "Firewall private IP"
  value       = module.firewall.firewall_private_ip
} */

output "ops_subid" {
  description = "Subscription ID where the Tier 1 Resource Group is provisioned"
  value       = coalesce(var.ops_subid, var.hub_subid)
}

output "laws_name" {
  description = "LAWS Name"
  value       = ""
}

output "laws_rgname" {
  description = "Resource Group for Laws"
  value       = ""
}
