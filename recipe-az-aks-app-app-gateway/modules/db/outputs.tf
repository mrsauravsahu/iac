output "server_id" {
  description = "PostgreSQL flexible server id"
  value       = azurerm_postgresql_flexible_server.this.id
}

output "fqdn" {
  description = "Server fully qualified domain name"
  value       = azurerm_postgresql_flexible_server.this.fqdn
}
output "postgresql_server_id" {
  description = "ID of the PostgreSQL server"
  value       = null
}
