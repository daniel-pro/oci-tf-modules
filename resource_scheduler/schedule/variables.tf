variable "compartment_id" {
  type        = string
  description = "The ID of the compartment where the schedule will be created in"
  default     = null
}

variable "schedules" {
  description = "Schedules"
  type        = any
  default     = {}
}