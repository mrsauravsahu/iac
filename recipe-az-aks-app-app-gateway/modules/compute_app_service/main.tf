# App Service Plan
resource "azurerm_service_plan" "app" {
  name                = "${var.name_prefix}-plan"
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type            = "Linux"
  sku_name           = "B3"

  tags = var.tags
}

# Application Insights
resource "azurerm_application_insights" "app_insights" {
  name                = "${var.name_prefix}-appinsights"
  location            = var.location
  resource_group_name = var.resource_group_name
  application_type    = "web"

  tags = var.tags
}

# Linux Web App
resource "azurerm_linux_web_app" "app" {
  name                = "${var.name_prefix}-app"
  location            = var.location
  resource_group_name = var.resource_group_name
  service_plan_id     = azurerm_service_plan.app.id

  site_config {
    application_stack {
      node_version = "18-lts"  # Latest LTS version of Node.js
    }

    always_on = true

    # Health check not required for MVP per requirements
    health_check_path = null

    # Using Application Gateway for WAF, so direct access can be restricted
    ip_restriction {
      virtual_network_subnet_id = var.subnet_id
      priority                  = 100
      name                     = "VNet"
    }
  }

  # Enable system-assigned managed identity
  identity {
    type = "SystemAssigned"
  }

  # VNet Integration
  virtual_network_subnet_id = var.subnet_id

  # Application settings including App Insights
  app_settings = {
    "APPINSIGHTS_INSTRUMENTATIONKEY"             = azurerm_application_insights.app_insights.instrumentation_key
    "APPLICATIONINSIGHTS_CONNECTION_STRING"       = azurerm_application_insights.app_insights.connection_string
    "ApplicationInsightsAgent_EXTENSION_VERSION"  = "~3"
    "WEBSITE_NODE_DEFAULT_VERSION"               = "~18"  # Ensure Node.js 18 LTS
  }

  # Deployment via ZIP as per requirements
  # Note: Actual ZIP deployment is done through CI/CD or Azure CLI, not through Terraform
  zip_deploy_file = null  # Will be handled outside Terraform

  tags = var.tags

  lifecycle {
    ignore_changes = [
      # Ignore changes to zip_deploy_file as it's managed outside Terraform
      zip_deploy_file,
      # Ignore changes to app_settings that might be modified by the app
      app_settings["WEBSITE_RUN_FROM_PACKAGE"],
    ]
  }
}

# Private Endpoint
resource "azurerm_private_endpoint" "app" {
  name                = "${var.name_prefix}-app-endpoint"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "${var.name_prefix}-app-connection"
    private_connection_resource_id = azurerm_linux_web_app.app.id
    is_manual_connection          = false
    subresource_names            = ["sites"]
  }

  tags = var.tags
}