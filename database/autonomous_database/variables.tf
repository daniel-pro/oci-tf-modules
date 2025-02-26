variable "autonomous_dbs" {
  description = "Autonomous DBs"
  type        = any
  default     = {}
}

variable "compartment_id" {
  description = "The OCID of the compartment where to create all resources"
  type        = string
}