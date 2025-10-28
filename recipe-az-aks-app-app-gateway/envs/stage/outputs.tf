# output "db__admin_password" {
#   value       = random_password.db_admin.result
#   description = "The generated admin password for the database."
#   sensitive   = true
# }

# output "kubeconfig_raw" {
#   description = "Sensitive raw kubeconfig from AKS (base64)"
#   value       = module.compute.kube_config_raw
#   sensitive   = true
# }

output "app_service_hostname" {
  description = "App Service default hostname"
  value       = module.app_service.app_service_default_hostname
}

output "app_service_identity" {
  description = "App Service managed identity details"
  value       = module.app_service.app_service_identity
}

# output "ingress_ip_address" {
#   description = "Ingress IP address"
#   value       = module.compute.ingress_ip_address
# }
