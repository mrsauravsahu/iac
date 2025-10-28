// Network module variables
variable "vnet_name" {
  type        = string
  description = "Name of the Virtual Network"
  default     = "app-vnet"
}

variable "address_space" {
  type        = list(string)
  description = "VNet address space"
  default     = ["10.0.0.0/16"]
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group where networking resources will be created"
}

variable "resource_group_location" {
  type        = string
  description = "Location of the resource group (pass this to avoid data lookup when RG is created in same plan)"
  default     = ""
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "subnets" {
  type = list(object({
    name       = string
    cidr_block = string
  }))
  description = "List of subnets to create"
  default = [
    { name = "aks-subnet" , cidr_block = "10.0.1.0/24" },
    { name = "db-subnet"  , cidr_block = "10.0.2.0/24" },
    { name = "appgw-subnet", cidr_block = "10.0.3.0/24" },
  ]
}
