terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}

locals {
  # Path: src\terraform\azresources\modules\Microsoft.Security\azureSecurityCenter\main.tf
  # Name: azureSecurityCenter
  # Description: Azure Security Center

  bundle = [
    "AppServices",
    "Arm",
    "ContainerRegistry",
    "Containers",
    "CosmosDbs",
    "Dns",
    "KeyVaults",
    "KubernetesService",
    "OpenSourceRelationalDatabases",
    "SqlServers",
    "SqlServerVirtualMachines",
    "StorageAccounts",
    "VirtualMachines"
  ]
}
