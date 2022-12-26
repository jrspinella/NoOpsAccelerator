# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.
data "azurerm_resource_group" "hub" {
  name = var.resource_group_name
}

data "azurerm_virtual_network" "hub" {
  name                = var.vnet_name
  resource_group_name = data.azurerm_resource_group.hub.name
}

data "azurerm_subnet" "fw_client_sn" {
  name                 = var.firewall_client_subnet_name
  virtual_network_name = data.azurerm_virtual_network.hub.name
  resource_group_name  = data.azurerm_resource_group.hub.name
}

data "azurerm_subnet" "fw_mgmt_sn" {
  name                 = var.firewall_management_subnet_name
  virtual_network_name = data.azurerm_virtual_network.hub.name
  resource_group_name  = data.azurerm_resource_group.hub.name
}

data "azurerm_public_ip" "fw_client_pip" {
  name                 = var.client_pip_name
  resource_group_name  = data.azurerm_resource_group.hub.name
}

data "azurerm_public_ip" "fw_mgmt_pip" {
  name                 = var.mgmt_pip_name
  resource_group_name  = data.azurerm_resource_group.hub.name
}

data "azurerm_firewall_policy" "firewallpolicy" {
  name                 = var.firewall_policy_name
  resource_group_name  = data.azurerm_resource_group.hub.name
}

resource "azurerm_firewall" "firewall" {
  name                = var.firewall_name
  location            = var.location
  resource_group_name = data.azurerm_resource_group.hub.name
  sku_name            = var.firewall_sku_name
  sku_tier            = var.firewall_sku
  private_ip_ranges   = var.disable_snat_ip_range
  firewall_policy_id  = data.azurerm_firewall_policy.firewallpolicy.id
  tags                = var.tags
  dns_servers         = null
  zones               = null

  ip_configuration {
    name                 = var.client_ipconfig_name
    subnet_id            = data.azurerm_subnet.fw_client_sn.id
    public_ip_address_id = data.azurerm_public_ip.fw_client_pip.id
  }

  management_ip_configuration {
    name                 = var.management_ipconfig_name
    subnet_id            = data.azurerm_subnet.fw_mgmt_sn.id
    public_ip_address_id = data.azurerm_public_ip.fw_mgmt_pip.id
  }
}
