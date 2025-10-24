variable "server_name" {
  type        = string
  description = "Name of the PostgreSQL flexible server"
  default     = "app-db-pg"
}

variable "location" {
  type        = string
  description = "Location for the DB server"
  default     = "eastus"
}

variable "resource_group_name" {
  type        = string
  description = "Resource group for the DB server"
}

variable "subnet_id" {
  type        = string
  description = "Delegated subnet id for the flexible server"
}

variable "admin_user" {
  type        = string
  default     = "pgadmin"
}

variable "admin_password" {
  type        = string
  description = "Administrator password (sensitive)"
}

variable "sku_name" {
  type    = string
  default = "B_Standard_B4ms"
}

variable "storage_gb" {
  type    = number
  default = 32
}

variable "postgres_version" {
  type    = string
  default = "14"
}

variable "zone" {
  type        = string
  description = "Availability zone for the flexible server (keep in sync with existing server)"
  default     = "1"
}

variable "tags" {
  type    = map(string)
  default = {}
}
variable "db_name" {
  type        = string
  description = "Database name"
  default     = "appdb"
}

variable "db_sku" {
  type        = string
  description = "SKU for Azure Database for PostgreSQL"
  default     = "GP_Standard_D4s_v3"
}

variable "enable_vector_extension" {
  type        = bool
  description = "If true, add 'vector' to the allowed extensions via server configuration. Disabled by default."
  default     = false
}
