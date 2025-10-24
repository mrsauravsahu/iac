output "db__admin_password" {
  value       = random_password.db_admin.result
  description = "The generated admin password for the database."
  sensitive   = true
}
output "kubeconfig_raw" {
  description = "Sensitive raw kubeconfig from AKS (base64)"
  value       = module.compute.kube_config_raw
  sensitive   = true
}
