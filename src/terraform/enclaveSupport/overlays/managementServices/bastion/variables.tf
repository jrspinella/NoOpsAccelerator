# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.
variable "resource_group_name" {
  description = "The name of the resource group the Bastion Host resides in"
  type        = string
  default     = ""
}

variable "vnet_name" {
  description = "The name of the Firewall virtual network"
  type        = string
}

variable "org_prefix" {
  description = "A name for the organization. It defaults to anoa."
  type        = string
}

variable "location" {
  description = "The location/region to keep all your network resources. To get the list of all locations with table format from azure cli, run 'az account list-locations -o table'"
  type        = string
}

variable "deploy_environment" {
  description = "The environment to deploy to. It defaults to 'dev'."
  type        = string
  default     = "dev"
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

variable "enable_resource_lock" {
  description = "(Optional) Enable resource locks"
  type        = bool
  default     = false
}

variable "lock_level" {
  description = "(Optional) id locks are enabled, Specifies the Level to be used for this Lock."
  type        = string
  default     = "CanNotDelete"
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
  default     = "10.0.100.160/27"
}

variable "bastion_subnet_service_endpoints" {
  description = "List of service endpoints to be enabled on the Bastion Host subnet."
  type        = list(string)
  default     = []
}

variable "bastion_nsg_rules" {
  description = "A list of maps containing the following keys: name, description, access, priority, protocol, direction, source_port_ranges, source_address_prefix, destination_port_ranges, destination_address_prefix"
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
    "allow_https_Inbound" = {
      name                       = "AllowHttpsInbound"
      priority                   = "120"
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "Internet"
      destination_address_prefix = "*"
    },
    "allow_https" = {
      name                       = "AllowGatewayManagerInbound"
      priority                   = "130"
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "GatewayManager"
      destination_address_prefix = "*"
    },
    "allow_ssh_outbound" = {
      name                       = "AllowSshOutbound"
      priority                   = "100"
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "VirtualNetwork"
      source_address_prefix      = "*"
      destination_address_prefix = "22"
    },
    "allow_rdp_outbound" = {
      name                       = "AllowRdpOutbound"
      priority                   = "101"
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "VirtualNetwork"
      source_address_prefix      = "*"
      destination_address_prefix = "3389"
    },
    "allow_azure_services_outbound" = {
      name                       = "AllowAzureCloudOutbound"
      priority                   = "110"
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "*"
      destination_address_prefix = "AzureCloud"
    }
  }
}

#################################
# Jumpbox VM Configuration
#################################

variable "use_random_password" {
  description = "Set this to true to use a random password for the windows VM. If set to false, the password will be stored in the terraform state file."
  type        = bool
  default     = true
}

variable "use_key_vault" {
  type        = bool
  default     = false
  description = "Set this to true to use a Key Vault to store the SSH public key for the linux VM. If set to false, the public key will be stored in the terraform state file."
}

variable "ssh_key_name" {
  type        = string
  default     = ""
  description = "The name of the Key Vault secret that holds the SSH public key to be used"
}

variable "key_vault_id" {
  type        = string
  default     = ""
  description = "The name of the Key Vault instance where the SSH public key is stored. Just the name of the vault, not the URI"
}

variable "size_linux_jumpbox" {
  description = "The size of the linux virtual machine"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "publisher_linux_jumpbox" {
  description = "The publisher of the linux image"
  type        = string
  default     = "Canonical"
}

variable "offer_linux_jumpbox" {
  description = "The offer of the linux image"
  type        = string
  default     = "UbuntuServer"
}

variable "sku_linux_jumpbox" {
  description = "The sku of the linux image"
  type        = string
  default     = "18.04-LTS"
}

variable "image_version_linux_jumpbox" {
  description = "The version of the linux image"
  type        = string
  default     = "latest"
}

variable "size_windows_jumpbox" {
  description = "The size of the windows virtual machine"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "publisher_windows_jumpbox" {
  description = "The publisher of the windows image"
  type        = string
  default     = "Canonical"
}

variable "offer_windows_jumpbox" {
  description = "The offer of the windows image"
  type        = string
  default     = "UbuntuServer"
}

variable "sku_windows_jumpbox" {
  description = "The sku of the windows image"
  type        = string
  default     = "18.04-LTS"
}

variable "image_version_windows_jumpbox" {
  description = "The version of the windows image"
  type        = string
  default     = "latest"
}

variable "admin_username" {
  description = "The admin username of the linux virtual machine"
  type        = string
  default     = "azure"
}

variable "admin_password" {
  description = "The admin password of the virtual machines"
  type        = string
  default     = ""
  sensitive   = true
}

variable "keyvault_name" {
  description = "The name of the keyvault to store the admin password"
  type        = string
  default     = ""
}
