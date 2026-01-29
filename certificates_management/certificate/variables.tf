variable "compartment_id" {
  description = "The ID of the compartment where to create all resources"
  type        = string
}

variable "certificates" {
  description = "Map of certificates to be created"
  type        = any
  default     = {}
}

variable "ca_bundles" {
  description = "Map of CA Bundles to be created"
  type        = any
  default     = {}
}