# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

output "network_interface_id" {
  description = "The ID of the Network Interface"
  value       = azurerm_network_interface.nic.id
}

output "network_interface_name" {
  description = "The Name of the Network Interface"
  value       = azurerm_network_interface.nic.name
}
