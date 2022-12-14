variable "tenancy_id" {
  type        = string
  description = "The ID of the tenancy."
  default     = null
}

variable "compartments" {
  type        = any
  description = "The map of all compartments to be created"
  default     = {}
}