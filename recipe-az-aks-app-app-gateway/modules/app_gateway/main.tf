locals {
  frontend_ip_configuration_name = "${var.name_prefix}-feip"
  frontend_port_name            = "${var.name_prefix}-feport"
  backend_address_pool_name     = "${var.name_prefix}-beap"
  http_setting_name            = "${var.name_prefix}-be-htst"
  listener_name                = "${var.name_prefix}-httplstn"
  request_routing_rule_name    = "${var.name_prefix}-rqrt"
  public_ip_name              = coalesce(var.public_ip_name, "${var.name_prefix}-pip")
}

# Public IP for Application Gateway (if enabled)
resource "azurerm_public_ip" "this" {
  count               = var.enable_public_ip ? 1 : 0
  name                = local.public_ip_name
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                = "Standard"
  tags               = var.tags
}

# Application Gateway v2
resource "azurerm_application_gateway" "main" {
  name                = "${var.name_prefix}-appgw"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  sku {
    name     = var.enable_waf ? "WAF_v2" : "Standard_v2"
    tier     = var.enable_waf ? "WAF_v2" : "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "${var.name_prefix}-gateway-ip-config"
    subnet_id = var.vnet_subnet_id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  dynamic "frontend_ip_configuration" {
    for_each = var.enable_public_ip ? [1] : []
    content {
      name                 = local.frontend_ip_configuration_name
      public_ip_address_id = azurerm_public_ip.this[0].id
    }
  }

  dynamic "frontend_ip_configuration" {
    for_each = var.enable_public_ip ? [] : [1]
    content {
      name                          = "${local.frontend_ip_configuration_name}-private"
      subnet_id                     = var.vnet_subnet_id
      private_ip_address_allocation = "Dynamic"
    }
  }

  backend_address_pool {
    name         = local.backend_address_pool_name
    ip_addresses = var.backend_address_pool
  }

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol             = "Http"
    request_timeout      = 60
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name            = local.frontend_port_name
    protocol                      = "Http"
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    rule_type                 = "Basic"
    priority                  = 100
    http_listener_name        = local.listener_name
    backend_address_pool_name = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
  }

  # Placeholder for WAF configuration - will be expanded in later implementation
  dynamic "waf_configuration" {
    for_each = var.enable_waf ? [1] : []
    content {
      enabled          = true
      firewall_mode   = "Prevention"
      rule_set_type  = "OWASP"
      rule_set_version = "3.2"
    }
  }

  # Note: HTTPS listeners and SSL certificates will be added in the next iteration
  lifecycle {
    ignore_changes = [
      tags["created_date"],
      backend_http_settings,
      frontend_port,
      http_listener,
      request_routing_rule,
      probe,
    ]
  }
}