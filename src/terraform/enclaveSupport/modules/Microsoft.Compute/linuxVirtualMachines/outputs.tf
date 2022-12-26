output "name" {
  description = "The name of the VM"
  value       = azurerm_linux_virtual_machine.vm.name
}

output "id" {
  description = "The id of the VM"
  value       = azurerm_linux_virtual_machine.vm.id
}

output "vm" {
  description = "The VM object"
  value       = azurerm_linux_virtual_machine.vm
}

output "vm_network_interface_id" {
  description = "The VM nic object"
  value       = module.mod_virtual_machine_nic.network_interface_id
}
