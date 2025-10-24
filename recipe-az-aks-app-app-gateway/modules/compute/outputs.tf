output "aks_id" {
  description = "AKS cluster id"
  value       = azurerm_kubernetes_cluster.this.id
}

output "kube_config_raw" {
  description = "Raw kubeconfig (base64)"
  value       = azurerm_kubernetes_cluster.this.kube_config_raw
  sensitive   = true
}
