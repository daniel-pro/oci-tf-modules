variable "compartment_id" {
  type        = string
  description = "The ID of the compartment where the bucket will be created in"
  default     = null
}

variable "tag_namespaces" {
  description = "Tag Namespaces"
  type        = any
  default     = {}
}

variable "identity_tags" {
  description = "Defined Tags"
  type        = any
  default     = {}
}

variable "tag_defaults" {
  description = "Default Tags"
  type        = any
  default     = {}
}