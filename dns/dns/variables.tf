variable "compartment_id" {
  type        = string
  description = "The ID of the compartment where the bucket will be created in"
  default     = null
}

variable "dns_views" {
  description = "DNS Views"
  type        = any
  default     = {}
}

variable "dns_zones" {
  description = "DNS Zones"
  type        = any
  default     = {}
}

variable "tsig_keys" {
  description = "TSIG Keys"
  type        = any
  default     = {}
}

variable "dns_rrsets" {
  description = "DNS Records"
  type        = any
  default     = {}
}

variable "dns_resolvers" {
  description = "DNS Resolvers"
  type        = any
  default     = {}
}

variable "dns_resolver_endpoints" {
  description = "DNS Resolvers Endpoints"
  type        = any
  default     = {}
}