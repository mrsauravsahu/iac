variable "resource_group_name" {
  description = "Name of the resource group where the Application Gateway should be created"
  type        = string
}

variable "location" {
  description = "Azure region where the Application Gateway should be created"
  type        = string
}

variable "name_prefix" {
  description = "Prefix to use for resource naming"
  type        = string
  default     = "appgw"
}

variable "vnet_subnet_id" {
  description = "ID of the subnet where the Application Gateway should be deployed"
  type        = string
}

variable "backend_address_pool" {
  description = "List of backend IP addresses or FQDNs"
  type        = list(string)
  default     = []
}

variable "enable_waf" {
  description = "Whether to enable WAF features (uses WAF_v2 SKU)"
  type        = bool
  default     = false
}

variable "enable_public_ip" {
  description = "Whether to create and use a public IP for the Application Gateway"
  type        = bool
  default     = false
}

variable "public_ip_name" {
  description = "Name of the public IP resource (if enabled)"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
