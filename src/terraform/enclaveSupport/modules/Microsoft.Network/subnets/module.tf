# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

resource "azurerm_subnet" "subnet" {
  name                 = var.name
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name
  address_prefixes     = try(var.address_prefixes, "address_prefixes", [])
  
  service_endpoints = try(var.service_endpoints, "service_endpoints", [])

  private_endpoint_network_policies_enabled     = try(var.private_endpoint_network_policies_enabled, "private_endpoint_network_policies_enabled", false)
  private_link_service_network_policies_enabled = try(var.private_link_service_network_policies_enabled, "private_link_service_network_policies_enabled", false)
}

