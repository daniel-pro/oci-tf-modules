variable "compartment_id" {
  description = "(Updatable) The OCID of the compartment where to create all resources"
  type        = string
}

variable "compute_instances" {
  description = "Map of compute instances to be created"
  type        = any
  default     = {}
}

variable "block_volumes" {
  description = "Map of block Volumes to be created"
  type        = any
  default     = {}
}

variable "volume_backup_policies" {
  description = "Map of volume backup policies to be created"
  type        = any
  default     = {}
}

variable "boot_volumes_backup_policies" {
  description = "Map of boot volume backup policies to be created"
  type        = any
  default     = {}
}

variable "volume_groups" {
  description = "Map of volume groups to be created"
  type        = any
  default     = {}
}