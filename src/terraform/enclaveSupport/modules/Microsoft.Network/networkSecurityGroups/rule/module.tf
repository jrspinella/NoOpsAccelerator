# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

resource "azurerm_network_security_rule" "ssh_rule" {
  name                        = format("%s-%s-vm-nsg-rule", var.name, var.location)
  resource_group_name         = var.resource_group_name
  network_security_group_name = var.nsg_id
  priority                    = var.priority
  direction                   = var.direction
  access                      = var.access
  protocol                    = var.protocol
  source_port_range           = var.source_port_range
  destination_port_range      = var.destination_port_range
  source_address_prefix       = var.source_address_prefix
  destination_address_prefix  = var.destination_address_prefix
}
