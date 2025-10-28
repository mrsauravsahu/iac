// Network module
// Creates an Azure Virtual Network and subnets inside a provided resource group.

resource "azurerm_virtual_network" "this" {
  name                = var.vnet_name
  location            = var.resource_group_location != "" ? var.resource_group_location : data.azurerm_resource_group.target[0].location
  resource_group_name = var.resource_group_name
  address_space       = var.address_space
  tags = var.tags
}

resource "azurerm_subnet" "this" {
  for_each = { for s in var.subnets : s.name => s }

  name                 = each.value.name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [each.value.cidr_block]
}

// Data lookup for resource group location (fails if RG not present)
data "azurerm_resource_group" "target" {
  count = var.resource_group_location == "" ? 1 : 0
  name  = var.resource_group_name
}

