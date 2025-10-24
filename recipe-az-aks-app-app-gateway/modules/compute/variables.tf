variable "aks_name" {
  type        = string
  description = "AKS cluster name"
  default     = "app-aks"
}

variable "location" {
  type        = string
  description = "Location for AKS cluster"
  default     = "eastus"
}

variable "resource_group_name" {
  type        = string
  description = "Resource group name where AKS will be created"
}

variable "node_count" {
  type        = number
  default     = 1
}

variable "node_vm_size" {
  type        = string
  default     = "Standard_A4m_v2"
}

variable "subnet_id" {
  type        = string
  description = "Subnet id the AKS node pool should use"
}

variable "dns_prefix" {
  type        = string
  description = "DNS prefix for AKS cluster"
  default     = "computeaks"
}

variable "service_cidr" {
  type        = string
  description = "Service CIDR for the Kubernetes cluster (must not overlap with VNet/subnets)"
  default     = "10.2.0.0/16"
}

variable "dns_service_ip" {
  type        = string
  description = "DNS service IP inside the service CIDR"
  default     = "10.2.0.10"
}

variable "docker_bridge_cidr" {
  type        = string
  description = "Docker bridge CIDR used by AKS cluster"
  default     = "172.17.0.1/16"
}


