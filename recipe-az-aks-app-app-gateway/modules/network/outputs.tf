// Network module outputs (interface)
output "vnet_id" {
  description = "The ID of the Virtual Network"
  value       = azurerm_virtual_network.this.id
}

output "subnet_ids" {
  description = "Map of subnet names to IDs"
  value = { for s in azurerm_subnet.this : s.name => s.id }
}
