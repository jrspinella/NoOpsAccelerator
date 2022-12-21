# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

output "azurerm_firewall_policy_id" {
  description = "The ID of the firewall policy"
  value       = azurerm_firewall_policy.firewallpolicy.id
}

output "azurerm_firewall_policy_name" {
  description = "The name of the firewall policy"
  value       = azurerm_firewall_policy.firewallpolicy.name
}
