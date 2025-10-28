// Compute module (AKS minimal implementation)
// Note: we omit the role_based_access_control block here to avoid provider schema mismatches.
resource "azurerm_kubernetes_cluster" "this" {
  name                = var.aks_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.dns_prefix

  default_node_pool {
    name           = "defaultnp"
    node_count     = var.node_count
    vm_size        = var.node_vm_size
    vnet_subnet_id = var.subnet_id
  }

  tags = var.tags

  identity {
    type = "SystemAssigned"
  }

  web_app_routing {
    dns_zone_ids = []
  }

  network_profile {
    network_plugin    = "kubenet"
    service_cidr      = var.service_cidr
    dns_service_ip    = var.dns_service_ip
  }

  // do not enable explicit RBAC block here; cluster will have default RBAC behavior
}
