variable "mysql_db_systems" {
  description = "DB Systems"
  type        = any
  default     = {}
}

variable "compartment_id" {
  description = "The OCID of the compartment where to create all resources"
  type        = string
}