variable "cloud_exadata_infrastructures" {
  description = "Cloud Exadata Infrastructures"
  type        = any
  default     = {}
}

variable "cloud_vm_clusters" {
  description = "Cloud VM Clusters"
  type        = any
  default     = {}
}

variable "db_homes" {
  description = "DB Homes"
  type        = any
  default     = {}
}

variable "databases" {
  description = "DBs"
  type        = any
  default     = {}
}
variable "compartment_id" {
  description = "The OCID of the compartment where to create all resources"
  type        = string
}