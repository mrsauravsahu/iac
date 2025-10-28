output "id" {
  description = "The ID of the Application Gateway"
  value       = azurerm_application_gateway.main.id
}

output "frontend_ip_configuration" {
  description = "The frontend IP configuration of the Application Gateway"
  value       = try(azurerm_application_gateway.main.frontend_ip_configuration[0], null)
}

output "backend_address_pool_id" {
  description = "The ID of the default backend address pool"
  value       = [for pool in azurerm_application_gateway.main.backend_address_pool : pool.id][0]
}

output "http_listener_ids" {
  description = "The IDs of the HTTP listeners"
  value       = [for listener in azurerm_application_gateway.main.http_listener : listener.id]
}

output "public_ip_address" {
  description = "The public IP address of the Application Gateway (if enabled)"
  value       = try(azurerm_public_ip.this[0].ip_address, null)
}

output "public_ip_fqdn" {
  description = "The FQDN of the Application Gateway's public IP (if enabled)"
  value       = try(azurerm_public_ip.this[0].fqdn, null)
}