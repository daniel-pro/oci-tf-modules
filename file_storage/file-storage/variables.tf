variable "compartment_id" {
  description = "(Updatable) The OCID of the compartment where to create all resources"
  type        = string
}

variable "file_systems" {
  description = "Map of file systems to be created"
  type        = any
  default     = {}
}

variable "mount_targets" {
  description = "Map of mount targets to be created"
  type        = any
  default     = {}
}

variable "snapshot_policies" {
  description = "Map of snapshot policies to be created"
  type        = any
  default     = {}
}

variable "snapshots" {
  description = "Map of snapshots to be created"
  type        = any
  default     = {}
}