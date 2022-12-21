# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

output "virtual_network_name" {
  description = "The name of the virtual network"
  value       = azurerm_virtual_network_peering.virtualNetworkPeerings.virtual_network_name
  }
