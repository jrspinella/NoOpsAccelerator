# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

output "azurerm_network_security_rule_name" {
  description = "The name of the network security rule. "
  value       = azurerm_network_security_rule.ssh_rule.name
  }
