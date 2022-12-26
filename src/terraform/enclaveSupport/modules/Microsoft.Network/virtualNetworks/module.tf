# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

locals {
  // Only one DDOS Protection Plan per region
  ddos_vnet = toset(var.enable_ddos_protection ? ["Standard"] : [])
}

resource "azurerm_network_ddos_protection_plan" "ddos" {
  for_each = local.ddos_vnet
  name     = "${var.vnet_name}-ddos"

  resource_group_name = var.resource_group_name
  location            = length(var.location) > 0 ? var.location : "eastus"
  tags                = length(var.tags) > 0 ? var.tags : {}

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  resource_group_name = var.resource_group_name
  location            = length(var.location) > 0 ? var.location : "eastus"
  tags                = length(var.tags) > 0 ? var.tags : {}
  address_space       = var.vnet_address_space

   dynamic "ddos_protection_plan" {
    for_each = local.ddos_vnet
    content {
      id     = azurerm_network_ddos_protection_plan.ddos[ddos_protection_plan.value].id
      enable = true
    }
  }

  lifecycle {
    ignore_changes = [name]
  }
}

