variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {
    env     = "stage"
    product_id = "21205"
  }
}