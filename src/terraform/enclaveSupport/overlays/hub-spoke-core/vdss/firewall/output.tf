output "firewall_private_ip" {
  description = "Firewall Private IP Address."
  value       = module.mod_hub_firewall.firewall_private_ip
}

output "firewall_client_subnet_name" {
  description = "Firewall client subnet name."
  value       = module.hub_fw_client.name
}

output "firewall_management_subnet_name" {
  description = "Firewall management subnet name."
  value       = module.hub_fw_management.name
}

output "firewall_client_subnet_id" {
  description = "Firewall client subnet ID."
  value       = module.hub_fw_client.id
}

output "firewall_mgmt_subnet_id" {
  description = "Firewall management subnet ID."
  value       = module.hub_fw_management.id
}
