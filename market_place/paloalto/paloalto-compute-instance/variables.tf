# do not set default values for these, they will inherit it from main variables file
variable "instance_display_name" {
  type = string
}

variable "compartment_id" {
  type = string
}

variable "availability_domain" {
  type = number
}

variable "boot_volume_size" {
  type    = number
  default = null
}

variable "ocpus" {
  type    = number
}

variable "memory_in_gbs" {
  type    = number
}

variable "instance_shape" {
  type    = string
}

variable "mp_paloalto_listing_image_resource_id" {
  type = string
}

variable "mp_paloalto_listing_resource_version" {
  type = string
}

variable "mp_paloalto_listing_id" {
  type = string
}

variable "vnic0_details" {
  description = "Map of details for first vnic to be created"
  type        = any
  default     = {}
}

variable "secondary_vnic_details" {
  description = "Map of details for second vnic to be created"
  type        = any
  default     = {}
}

variable "ssh_authorized_keys" {
  type      = string
}

variable "baseline_ocpu_utilization" {
  type      = string
}

variable "boot_volume_backup_policy" {
  type      = string
}

variable "block_volumes" {
  description = "Map of block Volumes to be created"
  type        = any
  default     = {}
}


variable "volume_groups" {
  description = "Map of volume groups to be created"
  type        = any
  default     = {}
}

variable "volume_backup_policy_assignments" {
  description = "Map of volume backup policy assignments to be created"
  type        = any
  default     = {}
}

variable "public_subnet_id" {
  type        = string
  default     = ""
  description = "Public subnet id for the instance"
}

variable "freeform_tags" {
  description = "simple key-value pairs to tag the resources created using freeform tags."
  type        = map(string)
  default     = null
}

variable "defined_tags" {
  description = "predefined and scoped to a namespace to tag the resources created using defined tags."
  type        = map(string)
  default     = null
}

variable "fw_hostname" {
  description = "paloalto hostname"
  type = string
  default = "FGVM"
}

variable "fw_authcode" {
  description = "paloalto authcode"
  type = string
  default = "Europe/Rome"
}

variable "vips" {
  description = "Virtual IPs to be created"
  type        = any
  default     = {}
}