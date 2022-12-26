# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

output "azurerm_network_security_group_id" {
  description = "The ID of the Network Security Group"
  value       = azurerm_network_security_group.nsg.id
}

output "azurerm_network_security_group_name" {
  description = "The Name of the Network Security Group"
  value       = azurerm_network_security_group.nsg.name
}
