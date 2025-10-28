terraform {
  backend "local" {
    path = "./terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "this" {
  name     = "rg-kk-stage"
  location = "eastus"
  tags = var.tags
}

module "network" {
  source = "../../modules/network"
  resource_group_name = azurerm_resource_group.this.name
  resource_group_location = azurerm_resource_group.this.location
  depends_on = [azurerm_resource_group.this]
subnets=[
    { name = "aks-subnet" , cidr_block = "10.0.1.0/24" },
    { name = "db-subnet"  , cidr_block = "10.0.2.0/24" },
    { name = "appgw-subnet", cidr_block = "10.0.3.0/24" },
    { name = "app-subnet" , cidr_block = "10.0.4.0/24" },
]
  tags = {
    env     = "stage"
    product_id = "21205"
  }
}

# module "compute" {
#   source = "../../modules/compute"
#   resource_group_name = azurerm_resource_group.this.name
#   location            = azurerm_resource_group.this.location
#   subnet_id           = module.network.subnet_ids["aks-subnet"]
#   node_count          = 1
#   node_vm_size        = "Standard_A4m_v2"
#   depends_on = [module.network]
#   tags = var.tags
# }

# module "db" {
#   source              = "../../modules/db"
#   resource_group_name = azurerm_resource_group.this.name
#   location            = azurerm_resource_group.this.location
#   subnet_id           = module.network.subnet_ids["db-subnet"]
#   admin_password      = random_password.db_admin.result
#   tags = {
#     env = "stage"
#   }
#   depends_on = [module.network]
# }

module "storage" {
  source              = "../../modules/storage"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  account_name        = "kkstageweb"
  tags = var.tags
  depends_on = [azurerm_resource_group.this]
}

module "app_gateway" {
  source              = "../../modules/app_gateway"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  name_prefix         = "kk-stage"
  vnet_subnet_id      = module.network.subnet_ids["appgw-subnet"]
  backend_address_pool =  ["135.234.244.76"] 
  #  [module.compute.ingress_ip_address]
  enable_waf          = false  # Disabled for initial setup
  enable_public_ip    = true   # Enable public access
  public_ip_name      = "kk-stage-appgw-pip"
  tags = var.tags
  depends_on = [module.network]
}

module "app_service" {
  source                    = "../../modules/compute_app_service"
  resource_group_name       = azurerm_resource_group.this.name
  location                  = azurerm_resource_group.this.location
  name_prefix              = "kk-stage"
  subnet_id                = module.network.subnet_ids["app-subnet"]
  app_gateway_backend_pool_id = module.app_gateway.backend_address_pool_id
  tags                     = var.tags
  depends_on               = [module.network, module.app_gateway]
}