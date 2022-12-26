
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
  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = format("%s-%s-aks", var.cluster_name, var.location)
  kubernetes_version  = var.aks_version

  enable_pod_security_policy = var.enable_pod_security_policy
  private_cluster_enabled    = var.enable_private_link

  role_based_access_control {
    enabled = var.enable_rbac
  }

  addon_profile {
    oms_agent {
      enabled                    = var.enable_log_analytics
      log_analytics_workspace_id = var.log_analytics_workspace_id
    }
  }

  default_node_pool {
    name                = "linux01"
    vm_size             = var.vm_sku
    type                = "VirtualMachineScaleSets"
    enable_auto_scaling = var.enable_auto_scaling
    min_count           = var.minimum_node_count
    max_count           = var.maximum_node_count
    node_count          = var.node_count
    vnet_subnet_id      = azurerm_subnet.aks_subnet.id
  }

  linux_profile {
    admin_username = var.admin_username
    ssh_key {
      key_data = data.azurerm_key_vault_secret.ssh_key.value
    }
  }

  windows_profile {
    admin_username = var.admin_username
    admin_password = random_password.windows_admin_password.result
  }


  network_profile {
    load_balancer_sku  = "Standard"
    network_plugin     = var.network_plugin
    network_policy     = var.network_policy
    service_cidr       = var.service_cidr
    dns_service_ip     = var.dns_service_ip
    docker_bridge_cidr = var.docker_bridge_cidr
  }

  identity {
    type = "SystemAssigned"
  }

  tags = merge(var.tags, {
    deployed-by = format("AzureNoOpsTF [%s]", terraform.workspace)
  })

  lifecycle {
    ignore_changes = [
      tags["Organization"],
      default_node_pool.0.node_count, # Prevent K8s autoscaling changes from being modified by Terraform
      service_principal.0.client_id   # Prevent client ID being overwritten - this can happen if MSI is being used.
    ]
  }
}
