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

variable "enable_accelerated_networking" {
  type = bool
  default = false
  description = "Set this to true to enable accelerated networking. Ensure that the VM type supports this feature before enabling."
}

variable "nsg_id" {
  type = string
  default = ""
  description = "The ID of the Network Security Group to associate with the VM. If not specified, a new NSG will be created"
}

variable "network_security_group_rules" {
  type = map(object({
    name                       = string
    priority                   = string
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
  }))
  default = {
    "default-ssh" = {
      name                       = "default-ssh"
      priority                   = "100"
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  }
  description = "A list of objects that define the NSG rules to be created. If not specified, a default rule allowing SSH access will be created"
}

variable "public_ip_address_id" {
  type = string
  default = ""
  description = "The ID of the public IP address to use for the VM. If not specified, a new public IP address will be created"
}

/* data_disks = {
      data1 = {
        name                 = "server1-data1"
        storage_account_type = "Standard_LRS"
        # Only Empty is supported. More community contributions required to cover other scenarios
        create_option           = "Empty"
        disk_size_gb            = "10"
        lun                     = 1
        zones                   = ["1"]
        disk_encryption_set_key = "set1"
        caching                 = "ReadWrite"
      }
  } */
variable "data_disks" {
  type        = map(any)
  default     = {}
  description = "If data disks are to be created for this VM, list their sizes here"
}

variable "os_disk_caching" {
  type        = string
  default     = "ReadWrite"
  description = "The caching type for the OS disk. Defaults to ReadWrite. Possible values are None, ReadOnly, and ReadWrite. Defaults to None if not specified."
}

variable "os_disk_storage_account_type" {
  type        = string
  default     = "Standard_LRS"
  description = "The storage account type for the OS disk. Defaults to Standard_LRS. Possible values are Standard_LRS, StandardSSD_LRS, Premium_LRS, UltraSSD_LRS, StandardSSD_ZRS, Standard_ZRS"
}

variable "disable_password_authentication" {
  description = "Disable password authentication for the virtual machine"
  type        = bool
  default     = false
}

variable "name" {
  description = "The name of the virtual machine"
  type        = string
}

variable "size" {
  description = "The size of the virtual machine"
  type        = string
}

variable "admin_username" {
  description = "The admin username of the virtual machine"
  type        = string
}

variable "admin_password" {
  description = "The admin password of the virtual machine"
  type        = string
  sensitive   = true
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

variable "tags" {
  description = "A map of tags to add to all resources"
  default     = {}
  type        = map(string)
}
