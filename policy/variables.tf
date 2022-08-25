variable "compartment_id" {
  type = string
  description = "The ID of the compartment where the bucket will be created in"
  default = null
}

variable "policies" {
  description = "Policies to be created."
  type        = any
  default     = {}
}