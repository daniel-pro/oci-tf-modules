variable "compartment_id" {
  type        = string
  description = "The ID of the compartment where the bucket will be created in"
  default     = null
}

variable "buckets" {
  description = "Buckets"
  type        = any
  default     = {}
}