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
  tags = {
    env     = "stage"
  }
}

module "network" {
  source = "../../modules/network"
  resource_group_name = azurerm_resource_group.this.name
  resource_group_location = azurerm_resource_group.this.location
  depends_on = [azurerm_resource_group.this]
}

module "compute" {
  source = "../../modules/compute"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  subnet_id           = module.network.subnet_ids["aks-subnet"]
  node_count          = 1
  node_vm_size        = "Standard_A4m_v2"
  depends_on = [module.network]
}

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
  tags = {
    env = "stage"
  }
  depends_on = [azurerm_resource_group.this]
}
