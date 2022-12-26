data "azurerm_subscription" "current" {}

resource "azurerm_security_center_subscription_pricing" "defenderPricing" {
  for_each      = local.bundle
  resource_type = each.value
  tier          = "Standard"
}

resource "azurerm_security_center_auto_provisioning" "autoProvision" {
  auto_provision = "On"
}

resource "azurerm_security_center_workspace" "securityWorkspaceSettings" {
  scope        = data.azurerm_subscription.current.id
  workspace_id = azurerm_log_analytics_workspace.example.id
}

resource "azurerm_security_center_contact" "securityNotifications" {
  name                = var.security_contact.name
  email               = var.security_contact.email
  phone               = var.security_contact.phone
  alert_notifications = var.security_contact.alert_notifications
  alerts_to_admins    = var.security_contact.alerts_to_admins
}
