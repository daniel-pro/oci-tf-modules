variable "compartment_id" {
  type        = string
  description = "The ID of the compartment where the resource will be created in"
  default     = null
}

variable "domain_name" {
  description = "Email Domain Name"
  type        = string
  default     = null
}

variable "defined_tags" {
  description = "Defined Tags"
  type        = any
  default     = {}
}

variable "freeform_tags" {
  description = "Freeform Tags"
  type        = any
  default     = {}
}

variable "domain_description" {
  description = "Email Domain Description"
  type        = string
  default     = null
}

variable "domain_verification_id" {
  description = "Domain Verification Idn"
  type        = string
  default     = null
}

variable "create_dkim" {
  description = "Flag to create DKIM"
  type        = bool
  default     = false
}

variable "dkim_name" {
  description = "Domain Verification Idn"
  type        = string
  default     = null
}

variable "email_domain_id" {
  description = "Email Domain Id"
  type        = string
  default     = null
}

variable "email_domain" {
  description = "Email Domain"
  type        = string
  default     = null
}

variable "dkim_description" {
  description = "DKIM Description"
  type        = string
  default     = null
}

variable "dkim_private_key" {
  description = "DKIM Private Key"
  type        = string
  default     = null
}

variable "create_email_sender" {
  description = "Create Email Sender Flag"
  type        = bool
  default     = false
}

variable "email_address" {
  description = "Email Address"
  type        = string
  default     = null
}

variable "create_username" {
  description = "Create Username Flag"
  type        = bool
  default     = false
}

variable "username" {
  description = "Username"
  type        = string
  default     = null
}

variable "username_description" {
  description = "Username Descriptio"
  type        = string
  default     = null
}

variable "username_email" {
  description = "Username Email"
  type        = string
  default     = null
}

variable "generate_smtp_credentials" {
  description = "Flag to generate SMTP Credentials"
  type        = bool
  default     = false
}

variable "smtp_credential_description" {
  description = "SMTP Credential Descriptio"
  type        = string
  default     = null
}

variable "smtp_user_id" {
  description = "SMTP User Id"
  type        = string
  default     = null
}