# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

resource "random_id" "keyvault" {
  byte_length = 12
}

module "key_vault" {
  source = "../../../modules/Microsoft.KeyVault"

  name                = format("%.24s", lower(replace("${var.keyvault_name}${random_id.keyvault.id}", "/[[:^alnum:]]/", "")))
  location            = var.location
  resource_group_name = var.resource_group_name
  key_vault           = var.key_vault
  tags = merge(var.tags, {
    deployed-by = format("AzureNoOpsTF [%s]", terraform.workspace)
  })
}
