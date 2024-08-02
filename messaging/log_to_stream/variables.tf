variable "compartment_id" {
  description = "Compartment OCID"
  type        = string
}

variable "service_connectors" {
  description = "Log Service Connectors"
  type        = any
  default     = {}
}

variable "streams" {
  description = "Streams"
  type        = any
  default     = {}
}

variable "stream_pools" {
  description = "Stream Pools"
  type        = any
  default     = {}
}

variable "logs" {
  description = "Logs"
  type        = any
  default     = {}
}

variable "log_groups" {
  description = "Log Groups"
  type        = any
  default     = {}
}