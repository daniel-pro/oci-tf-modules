variable "compartment_id" {
  description = "The ID of the compartment where to create all resources"
  type        = string
}

variable "volume_backup_policy_assignments" {
  description = "Map of volume backup policy assignments to be created"
  type        = any
  default     = {}
}
