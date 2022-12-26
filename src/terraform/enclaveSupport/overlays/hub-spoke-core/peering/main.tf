# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

/*
SUMMARY: Module to deploy the Hub Network Peering to Spokes based on the Azure Mission Landing Zone conceptual architecture
DESCRIPTION: The following components will be options in this deployment
              hubToSpokePeering
              SpokeTohubPeering
AUTHOR/S: jspinella
*/

module "hub_to_spoke" {
  source = "../../../modules/Microsoft.Network/virtualNetworks/virtualNetworkPeering"

  peering_name = var.peering_name
  resource_group_name = var.resource_group_name
  location = var.location

  virtual_network_name = var.virtual_network_name
  remote_virtual_network_id = var.remote_virtual_network_id
  allow_virtual_network_access = var.allow_virtual_network_access
  allow_forwarded_traffic = var.allow_forwarded_traffic
  allow_gateway_transit = var.allow_gateway_transit
  use_remote_gateways = var.use_remote_gateways
}
