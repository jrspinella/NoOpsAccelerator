# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.
variable "resource_group_name" {
  description = "The name of the resource group the Bastion Host resides in"
  type        = string
  default = ""
}

variable "location" {
  description = "The location/region to keep all your network resources. To get the list of all locations with table format from azure cli, run 'az account list-locations -o table'"
  type        = string
}

variable "virtual_network_name" {
  description = "The name of the virtual network the Bastion Host resides in"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all resources"
  default     = {}
  type        = map(string)
}

#################################
# Bastion Host Configuration
#################################

variable "create_bastion_linux_jumpbox" {
  description = "Create a bastion host and linux jumpbox VM?"
  type        = bool
  default     = true
}

variable "create_bastion_windows_jumpbox" {
  description = "Create a bastion host and windows jumpbox VM?"
  type        = bool
  default     = true
}

variable "bastion_host_name" {
  description = "The name of the Bastion Host"
  type        = string
  default     = "bastionHost"
}

variable "bastion_address_space" {
  description = "The address space to be used for the Bastion Host subnet (must be /27 or larger)."
  type        = string
  default     = "10.0.100.128/27"
}

#################################
# Jumpbox VM Configuration
#################################

variable "jumpbox_keyvault_name" {
  description = "The name of the jumpbox virtual machine keyvault"
  type        = string
  default     = "jumpboxKeyvault"
}

variable "jumpbox_windows_vm_name" {
  description = "The name of the Windows jumpbox virtual machine"
  type        = string
  default     = "jumpboxWindowsVm"
}

variable "jumpbox_admin_username" {
  description = "The admin username of the virtual machine"
  type        = string
  default     = "azure user"
}

variable "jumpbox_admin_password" {
  description = "The admin password of the virtual machine"
  type        = string
  default     = "P@ssw0rd1234"
  sensitive   = true
}

variable "jumpbox_windows_vm_size" {
  description = "The size of the Windows jumpbox virtual machine"
  type        = string
  default     = "Standard_DS1_v2"
}

variable "jumpbox_windows_vm_publisher" {
  description = "The publisher of the Windows jumpbox virtual machine source image"
  type        = string
  default     = "MicrosoftWindowsServer"
}

variable "jumpbox_windows_vm_offer" {
  description = "The offer of the Windows jumpbox virtual machine source image"
  type        = string
  default     = "WindowsServer"
}

variable "jumpbox_windows_vm_sku" {
  description = "The SKU of the Windows jumpbox virtual machine source image"
  type        = string
  default     = "2019-datacenter-gensecond"
}

variable "jumpbox_windows_vm_version" {
  description = "The version of the Windows jumpbox virtual machine source image"
  type        = string
  default     = "latest"
}

variable "jumpbox_linux_vm_name" {
  description = "The name of the Linux jumpbox virtual machine"
  type        = string
  default     = "jumpboxLinuxVm"
}

variable "jumpbox_linux_vm_size" {
  description = "The size of the Linux jumpbox virtual machine"
  type        = string
  default     = "Standard_DS1_v2"
}

variable "jumpbox_linux_vm_publisher" {
  description = "The publisher of the Linux jumpbox virtual machine source image"
  type        = string
  default     = "Canonical"
}

variable "jumpbox_linux_vm_offer" {
  description = "The offer of the Linux jumpbox virtual machine source image"
  type        = string
  default     = "UbuntuServer"
}

variable "jumpbox_linux_vm_sku" {
  description = "The SKU of the Linux jumpbox virtual machine source image"
  type        = string
  default     = "18.04-LTS"
}

variable "jumpbox_linux_vm_version" {
  description = "The version of the Linux jumpbox virtual machine source image"
  type        = string
  default     = "latest"
}

