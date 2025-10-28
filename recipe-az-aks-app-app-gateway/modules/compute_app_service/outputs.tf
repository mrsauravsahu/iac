output "app_service_name" {
  value       = azurerm_linux_web_app.app.name
  description = "Name of the App Service"
}

output "app_service_default_hostname" {
  value       = azurerm_linux_web_app.app.default_hostname
  description = "Default hostname of the App Service"
}

output "app_service_id" {
  value       = azurerm_linux_web_app.app.id
  description = "Resource ID of the App Service"
}

output "app_service_identity" {
  value       = azurerm_linux_web_app.app.identity
  description = "Identity block containing the Managed Service Identity information"
}

output "instrumentation_key" {
  value       = azurerm_application_insights.app_insights.instrumentation_key
  description = "Instrumentation key for Application Insights"
  sensitive   = true
}