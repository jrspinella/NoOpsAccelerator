resource "azurerm_public_ip" "pip" {
  name                = var.client_publicip_name
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = var.sku_name
  tags                = var.tags
}
