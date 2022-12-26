# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

variable "cluster_name" {
  description = "Name of the AKS cluster."
  default = "k8stest"
}

variable "resource_group_name" {
  description = "Name of the resource group in which to create the AKS cluster."
  type = string
  default = "k8stest"
}

variable "location" {
  description = "Location of the AKS cluster."
  type = string
  default = "eastus"
}

variable "resource_group_location" {
  default     = "eastus"
  type = string
  description = "Location of the resource group."
}

variable "resource_group_name_prefix" {
  default     = "rg"
  type = string
  description = "Prefix of the resource group name that's combined with a random ID so name is unique in your Azure subscription."
}

variable "aks_version" {
  default     = "eastus"
  type = string
  description = "AKS version to use."
}

variable "node_count" {
  description = "Number of nodes in the AKS cluster."
  default = 3
}

variable "node_vm_size" {
  description = "VM size of the nodes in the AKS cluster."
  default = "Standard_D2_v2"
}

variable "enable_auto_scaling" {
  description = "Enable auto scaling of the AKS cluster."
  default = true
}

variable "minimum_node_count" {
  description = "Minimum number of nodes in the AKS cluster."
  default = 3
}

variable "maximum_node_count" {
  description = "Maximum number of nodes in the AKS cluster."
  default = 3
}

variable "enable_rbac" {
  description = "Enable RBAC for the AKS cluster."
  default = true
}

variable "enable_pod_security_policy" {
  description = "Enable pod security policy for the AKS cluster."
  default = true
}

variable "enable_private_link" {
  description = "Enable private link for the AKS cluster."
  default = true
}

variable "enable_log_analytics" {
  description = "Enable log analytics for the AKS cluster."
  default = true
}

variable "enable_monitoring" {
  description = "Enable monitoring for the AKS cluster."
  default = true
}

variable "enable_http_application_routing" {
  description = "Enable http application routing for the AKS cluster."
  default = true
}

variable "enable_azure_policy" {
  description = "Enable Azure Policy for the AKS cluster."
  default = true
}

variable "enable_kubernetes_dashboard" {
  description = "Enable Kubernetes dashboard for the AKS cluster."
  default = true
}

variable "agent_count" {
  description = "Number of agent nodes in the AKS cluster."
  default = 3
}

# The following two variable declarations are placeholder references.
# Set the values for these variable in terraform.tfvars
variable "aks_service_principal_app_id" {
  default = ""
}

variable "aks_service_principal_client_secret" {
  default = ""
}


# Refer to https://azure.microsoft.com/global-infrastructure/services/?products=monitor for available Log Analytics regions.
variable "log_analytics_workspace_location" {
  default = "eastus"
}

variable "log_analytics_workspace_name" {
  default = "testLogAnalyticsWorkspaceName"
}

# Refer to https://azure.microsoft.com/pricing/details/monitor/ for Log Analytics pricing
variable "log_analytics_workspace_sku" {
  default = "PerGB2018"
}


variable "ssh_public_key" {
   description = "SSH public key to use for the AKS cluster."
  default = "~/.ssh/id_rsa.pub"
}

variable "enable_pod_security_policy" {
    description = "Enable Pod Security Policy"
    default = false
}
