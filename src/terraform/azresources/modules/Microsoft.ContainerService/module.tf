
# Needed as introduced in >2.79.1 - https://github.com/hashicorp/terraform-provider-azurerm/issues/13585
resource "null_resource" "aks_registration_preview" {
  provisioner "local-exec" {
    command = "az feature register --namespace Microsoft.ContainerService -n AutoUpgradePreview"
  }
}
### AKS cluster resource
resource "azurerm_kubernetes_cluster" "aks" {
  depends_on = [
    null_resource.aks_registration_preview
  ]
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name

  default_node_pool {
  }

  dynamic "kubelet_config" {
  }

  dynamic "linux_os_config" {

  }

  dynamic "aci_connector_linux" {
  }

  dynamic "oms_agent" {
  }

  dynamic "ingress_application_gateway" {
  }

  dynamic "key_vault_secrets_provider" {
  }

  dynamic "auto_scaler_profile" {
  }

  dynamic "identity" {
  }

  dynamic "kubelet_identity" {
  }

  dynamic "linux_profile" {
  }

  dynamic "network_profile" {
  }

  #Enabled RBAC
  dynamic "azure_active_directory_role_based_access_control" {
  }

  dynamic "service_principal" {
  }

  lifecycle {
    ignore_changes = [
      windows_profile, private_dns_zone_id
    ]
  }
  tags = merge(local.tags, lookup(var.settings, "tags", {}))

  dynamic "windows_profile" {
  }
}

#
# Node pools
#
resource "azurerm_kubernetes_cluster_node_pool" "nodepools" {
}
