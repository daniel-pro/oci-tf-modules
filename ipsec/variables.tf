variable "compartment_id" {
  type = string
  description = "The ID of the compartment where the bucket will be created in"
  default = null
}

variable "cpes" {
  type = any
  description = "The Customer Premises Equipments to be created"
  default = {}
}

variable "ipsec_connections" {
  description = "IPsec connections"
  type        = any
  default     = {}
}