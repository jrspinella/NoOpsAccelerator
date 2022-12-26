output "name" {
  description = "The name of the VM"
  value       = azurerm_windows_virtual_machine.vm.name
}

output "id" {
  description = "The id of the VM"
  value       = azurerm_windows_virtual_machine.vm.id
}

output "vm" {
  description = "The VM object"
  value       = azurerm_windows_virtual_machine.vm
}

output "nic" {
  description = "The VM nic object"
  value       = azurerm_network_interface.vm_nic
}
