# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

output "id" {
  description = "The ID of the managed disk."
  value       = azurerm_managed_disk.vm_data_disk.id
}

output "name" {
  description = "The name of the managed disk."
  value       = azurerm_managed_disk.vm_data_disk.name
}
