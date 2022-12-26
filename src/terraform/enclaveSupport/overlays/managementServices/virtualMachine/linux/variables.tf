# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

variable "resource_group_name" {
  description = "The name of the resource group the virtual machine resides in"
  type        = string
}

variable "location" {
  description = "The location/region to keep all your network resources. To get the list of all locations with table format from azure cli, run 'az account list-locations -o table'"
  type        = string
}

variable "virtual_network_name" {
  description = "The name of the virtual network the virtual machine resides in"
  type        = string
}

variable "subnet_name" {
  description = "The name of the subnet the virtual machine resides in"
  type        = string
}

variable "network_interface_name" {
  description = "The name of the network interface the virtual machine resides in"
  type        = string
}

variable "ip_configuration_name" {
  description = "The name of the ip configuration the virtual machine resides in"
  type        = string
}

variable "public_ip_address_id" {
  description = "The id of the public ip address the virtual machine resides in"
  type        = string
}

variable "nsg_id" {
  type = string
  default = ""
  description = "The ID of the Network Security Group to associate with the VM. If not specified, a new NSG will be created"
}

variable "disable_password_authentication" {
  description = "Specifies whether password authentication should be disabled. If set to false, an admin_password must be specified."
  type        = bool
  default     = "false"
}

variable "use_random_password" {
  description = "Specifies whether a random password should be generated for the virtual machine. If set to false, an admin_password must be specified."
  type        = bool
  default     = true
}

variable "publisher" {
  description = "(Optional) The publisher of the image used to create the virtual machine."
  type = string
  default = "Canonical"
}

variable "offer" {
  description = "(Optional) Specifies the offer of the platform image or marketplace image used to create the virtual machine."
  type = string
  default = "UbuntuServer"
}

variable "sku" {
  description = "(Optional) Specifies the Ubuntu Server version."
  type = string
  default = "18.04-LTS"
}

variable "image_version" {
  description = "(Optional) Specifies the version of the platform image or marketplace image used to create the virtual machine."
  type = string
  default = "latest"
}


variable "size" {
  description = "The size of the virtual machine"
  type        = string
}

variable "admin_username" {
  description = "The admin username of the virtual machine"
  type        = string
  default = ""
}

variable "admin_password" {
  description = "The admin password of the virtual machine"
  type        = string
  sensitive   = true
  default = ""
}

variable "use_key_vault" {
  type = bool
  default = false
  description = "Set this to true to use a Key Vault to store the SSH public key"
}

variable "ssh_key_name" {
  type = string
  default = ""
  description = "The name of the Key Vault secret that holds the SSH public key to be used"
}

variable "key_vault_id" {
  type = string
  default = ""
  description = "The name of the Key Vault instance where the SSH public key is stored. Just the name of the vault, not the URI"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  default     = {}
  type        = map(string)
}
