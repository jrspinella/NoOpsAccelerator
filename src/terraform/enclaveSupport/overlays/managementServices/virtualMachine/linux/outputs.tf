output "name" {
  description = "The name of the VM"
  value       = module.mod_virtual_machine.name
}

output "id" {
  description = "The id of the VM"
  value       = module.mod_virtual_machine.id
}

output "vm" {
  description = "The VM object"
  value       = module.mod_virtual_machine
}

output "vm_network_interface_id" {
  description = "The VM nic resource id"
  value       = module.mod_virtual_machine.vm_network_interface_id
}
