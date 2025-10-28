variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "location" {
  type        = string
  description = "Azure region for the App Service"
}

variable "name_prefix" {
  type        = string
  description = "Prefix for resource names"
}

variable "subnet_id" {
  type        = string
  description = "ID of the subnet for VNet integration"
}

variable "app_gateway_backend_pool_id" {
  type        = string
  description = "ID of the Application Gateway backend pool"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources"
  default     = {}
}
