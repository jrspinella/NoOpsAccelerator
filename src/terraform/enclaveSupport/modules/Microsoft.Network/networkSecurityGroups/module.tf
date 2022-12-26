# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

resource "azurerm_network_security_group" "nsg" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  tags = merge(var.tags, {
    deployed-by = format("AzureNoOpsTF [%s]", terraform.workspace)
  })
}

resource "azurerm_network_security_rule" "nsgrules" {
  for_each = var.nsg_rules

  name                        = each.value.name
  priority                    = each.value.priority
  direction                   = each.value.direction
  access                      = each.value.access
  protocol                    = each.value.protocol
  source_port_range           = each.value.source_port_range != "" ? each.value.source_port_range : "*"
  destination_port_range      = each.value.destination_port_range != "" ? each.value.destination_port_range : "*"
  source_address_prefix       = each.value.source_address_prefix != "" ? each.value.source_address_prefix : "*"
  destination_address_prefix  = each.value.destination_address_prefix != "" ? each.value.destination_address_prefix : "*"
  resource_group_name         = azurerm_network_security_group.nsg.resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

resource "azurerm_subnet_network_security_group_association" "nsg" {
  subnet_id                 = var.subnet_id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

