# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.


output "resource_group_name" {
  description = "The name of the resource group the Bastion Host resides in"
  value       = data.azurerm_resource_group.hub.name
}

output "bastion_name" {
  description = "The name of the Bastion Host"
  value       = azurerm_bastion_host.bastion_host.name
}

output "bastion_resource_id" {
  description = "The name of the Bastion Host Resource ID"
  value       = azurerm_bastion_host.bastion_host.id
}

output "bastion_public_ip_address_id" {
  description = "The name of the Bastion Host Public IP Address"
  value       = module.bastion_host_pip.id
}
