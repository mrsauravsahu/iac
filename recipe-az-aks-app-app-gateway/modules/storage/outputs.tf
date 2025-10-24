output "account_id" {
  value       = azurerm_storage_account.this.id
  description = "Storage account id"
}

output "web_endpoint" {
  value       = azurerm_storage_account.this.primary_web_endpoint
  description = "Static website endpoint"
}
