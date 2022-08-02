variable "load_balancers" {
  description = "Load Balancers"
  type        = any
  default     = {}
}

variable "lb_certificates" {
  description = "Load Balancers SSL Certificates"
  type        = any
  default     = {}
}

variable "lb_backend_sets" {
  description = "Load Balancers Backend Sets"
  type        = any
  default     = {}
}