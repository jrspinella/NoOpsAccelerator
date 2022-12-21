# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

output "public_ip" {
  description = "The public IP for the firewall"
  value       = azurerm_public_ip.pip.ip_address
}

output "public_ip_id" {
  description = "The public IP for the firewall"
  value       = azurerm_public_ip.pip.id
}

output "public_ip_name" {
  description = "The public IP for the firewall"
  value       = azurerm_public_ip.pip.name
}


