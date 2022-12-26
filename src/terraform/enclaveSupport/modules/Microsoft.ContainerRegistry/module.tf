data "azurerm_resource_group" "rg" {
    name = var.resource_group_name
}

resource "azurerm_container_registry" "acr" {
  name                = "${var.prefix}registry"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = var.location
  sku                 = var.sku_name
  admin_enabled       = var.admin_enabled

  identity {
    type = var.identity_type
    identity_ids = [
      var.identities
    ]
  }
}
