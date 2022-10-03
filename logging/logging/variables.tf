variable "compartment_id" {
  description = "Compartment OCID"
  type        = string
}

variable "log_groups" {
  description = "Log Groups"
  type        = any
  default     = {}
}

variable "logs" {
  description = "Logs"
  type        = any
  default     = {}
}

variable "unified_agent_configurations" {
  description = "Unified Agent Configurations"
  type        = any
  default     = {}
}