output "aks_id" {
  description = "AKS cluster id"
  value       = azurerm_kubernetes_cluster.this.id
}

output "kube_config_raw" {
  description = "Raw kubeconfig (base64)"
  value       = azurerm_kubernetes_cluster.this.kube_config_raw
  sensitive   = true
}

output "outbound_ip_addresses" {
  description = "The outbound (egress) IP addresses of the AKS cluster"
  value       = split(",",join(",", (azurerm_kubernetes_cluster.this.network_profile[0].load_balancer_profile[0].effective_outbound_ips)))
}

output "ingress_ip_address" {
  description = "The IP address of the AKS cluster's load balancer (for ingress)"
  value       = try(split(",", azurerm_kubernetes_cluster.this.network_profile[0].load_balancer_profile[0].effective_outbound_ips), null)
}
