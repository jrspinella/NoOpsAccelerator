# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

output "resource_group_name" {
  description = "The name of the resource group in which resources are created"
  value       = module.mod_hub_resource_group.name
}

output "resource_group_location" {
  description = "The location of the resource group in which resources are created"
  value       = module.mod_hub_resource_group.location
}

output "virtual_network_name" {
  description = "The name of the virtual network"
  value       = module.mod_hub_network.virtual_network_name
}

output "virtual_network_address_space" {
  description = "List of address spaces that are used the virtual network."
  value       = module.mod_hub_network.virtual_network_address_space
}

output "virtual_network_id" {
  description = "The id of the virtual network"
  value       = module.mod_hub_network.virtual_network_id
}

output "storage_account_id" {
  description = "The id of the storage account"
  value       = module.mod_hub_logging_storage.id
}

output "storage_account_name" {
  description = "The name of the storage account"
  value       = module.mod_hub_logging_storage.name
}

output "firewall_private_ip" {
  description = "Firewall Private IP Address."
  value       = module.mod_hub_firewall.firewall_private_ip
}

output "firewall_client_subnet_name" {
  description = "Firewall client subnet name."
  value       = module.hub_fw_client.name
}

output "firewall_management_subnet_name" {
  description = "Firewall management subnet name."
  value       = module.hub_fw_management.name
}

output "firewall_client_subnet_id" {
  description = "Firewall client subnet ID."
  value       = module.hub_fw_client.id
}

output "firewall_mgmt_subnet_id" {
  description = "Firewall management subnet ID."
  value       = module.hub_fw_management.id
}

output "log_analytics_storage_id" {
  description = "Log Analytics Storage ID."
  value       = module.mod_hub_logging_storage.id
}
