variable "compartment_id" {
  description = "The ID of the compartment where to create all resources"
  type        = string
}

variable "volume_backup_policies" {
  description = "Map of volume backup policies to be created"
  type        = any
  default     = {}
}
