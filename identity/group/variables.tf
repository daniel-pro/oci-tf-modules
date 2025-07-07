variable "tenancy_id" {
  type        = string
  description = "The ID of the tenancy."
  default     = null
}

variable "groups" {
  type        = any
  description = "The map of all groups to be created"
  default     = {}
}