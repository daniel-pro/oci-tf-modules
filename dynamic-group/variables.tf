variable "compartment_id" {
  description = "The OCID of the compartment where to create all resources"
  type        = string
}

variable "dynamic_groups" {
  description = "The map of all dynamic groups to be created."
  type        = none
  default     = {}
}

