variable "compartment_id" {
  type        = string
  description = "The ID of the compartment where the bucket will be created in"
  default     = null
}

variable "web_app_firewalls" {
  description = "WAFs"
  type        = any
  default     = {}
}

variable "web_app_firewall_policies" {
  description = "WAF Policies"
  type        = any
  default     = {}
}
