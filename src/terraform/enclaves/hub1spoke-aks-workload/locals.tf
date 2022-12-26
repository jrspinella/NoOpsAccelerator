# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

################################
### GLOBAL VARIABLES         ###
################################

locals {
  firewall_premium_environments = ["public", "usgovernment"] # terraform azurerm environments where Azure Firewall Premium is supported
}
