
data azurerm_client_config current {}

data azurerm_subscription current {}

# Org Management Group
data azurerm_management_group org {
  name = "policy_dev"
}

# Child Management Group
data azurerm_management_group team_a {
  name = "team_a"
}

# Contributor role
data azurerm_role_definition contributor {
  name = "Contributor"
}

# Virtual Machine Contributor role
data azurerm_role_definition vm_contributor {
  name = "Virtual Machine Contributor"
}
