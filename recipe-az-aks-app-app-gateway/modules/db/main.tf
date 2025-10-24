// PostgreSQL Flexible Server (minimal scaffold)
// Note: PGVector requires the 'pgvector' extension which may require specific engine versions.
resource "azurerm_postgresql_flexible_server" "this" {
  name                = var.server_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku_name            = var.sku_name
  administrator_login = var.admin_user
  administrator_password = var.admin_password

  storage_mb = var.storage_gb * 1024

  # For now create the server with public network access. If you need private
  # VNet access, provide a delegated subnet and also set up a Private DNS zone
  # and pass its ARM resource id into `private_dns_zone_id`.
  public_network_access_enabled = true
  version             = var.postgres_version
  zone                = var.zone

  tags = var.tags
}

// Create a named database inside the Flexible Server for application use
resource "azurerm_postgresql_flexible_server_database" "appdb" {
  name      = var.db_name
  server_id = azurerm_postgresql_flexible_server.this.id
}

// NOTE: PGVector (the `pgvector` extension) must be enabled manually or via a
// separate provisioning step. We intentionally do not run automated local-exec
// extension creation here — run psql against the server and run:
//   CREATE EXTENSION IF NOT EXISTS pgvector;
// after networking/credentials are configured (or add a secure CI step).

// Optional: add the allowed extension value to the server configuration so the
// 'vector' extension is permitted. This is gated behind
// var.enable_vector_extension to avoid accidental changes to existing servers.
resource "azurerm_postgresql_flexible_server_configuration" "vector_extension" {
  count     = var.enable_vector_extension ? 1 : 0

  name      = "azure.extensions"
  server_id = azurerm_postgresql_flexible_server.this.id
  value     = "vector"
}

