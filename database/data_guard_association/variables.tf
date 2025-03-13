variable "data_guard_associations" {
  description = "Dataguard associations"
  type        = any
  default     = {}
}
variable "compartment_id" {
  description = "(Updatable) The OCID of the compartment where to create all resources"
  type        = string
}