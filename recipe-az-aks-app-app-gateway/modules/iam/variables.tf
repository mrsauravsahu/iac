variable "operator_principals" {
  type        = list(string)
  description = "List of operator principal IDs who may assume elevated roles"
  default     = []
}
