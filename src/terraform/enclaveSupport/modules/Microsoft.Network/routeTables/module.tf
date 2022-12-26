# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

resource "azurerm_route_table" "routetable" {
  name                          = var.name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  disable_bgp_route_propagation = var.disable_bgp_route_propagation
  tags                          = var.tags
}
