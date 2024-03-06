variable "network_load_balancers" {
  description = "Network Load Balancers"
  type        = any
  default     = {}
}

variable "lb_backend_sets" {
  description = "Network Load Balancers Backend Sets"
  type        = any
  default     = {}
}
