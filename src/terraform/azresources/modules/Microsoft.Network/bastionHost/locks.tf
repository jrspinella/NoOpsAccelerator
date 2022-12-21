# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

module "locks" {
  source = "../../Microsoft.Authorization/locks"
  count  = var.enable_resource_lock ? 1 : 0
  name   = "${azurerm_bastion_host.bastion_host.name}-${var.lock_level}-lock"
  scope_id   = azurerm_bastion_host.bastion_host.id
  lock_level = var.lock_level
}


