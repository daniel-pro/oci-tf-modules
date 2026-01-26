variable "subnets" {
  description = "subnets configured for the Autonomous Recovery Service"
  type        = any
  default     = {}
}

variable "protection_policies" {
  description = "protection policies of the Autonomous Recovery Service"
  type        = any
  default     = {}
}

# variable "compartment_id" {
#   description = "The OCID of the compartment where to create all resources"
#   type        = string
# }