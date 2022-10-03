variable "compartment_id" {
  description = "compartment id where to create all resources"
  type        = string
  # no default value, asking user to explicitly set this variable's value. see codingconventions.adoc
}

variable "freeform_tags" {
  description = "simple key-value pairs to tag the created resources using freeform OCI Free-form tags."
  type        = map(any)
  default     = null
}

variable "defined_tags" {
  description = "predefined and scoped to a namespace to tag the created resources using OCI Defined tags."
  type        = map(any)
  default     = null
}

# drg parameters

variable "drg_display_name" {
  description = "(Updatable) Name of Dynamic Routing Gateway. Does not have to be unique."
  type        = string
  default     = "drg"

  validation {
    condition     = length(var.drg_display_name) > 0
    error_message = "The drg_display_name value cannot be an empty string."
  }
}

variable "rpcs" {
  description = "(Updatable) Map of RCPs."
  type        = any
  default     = {}
}

