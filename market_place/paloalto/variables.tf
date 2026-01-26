# to be used by instance
variable "instance_display_name" {
  type        = string
  default     = ""
  description = "Instance display name"
}

variable "compartment_id" {
  type        = string
  default     = ""
  description = "Compartment id in which stack will be created"
}

variable "availability_domain" {
  type        = string
  default     = ""
  description = "Availability domain in which stack will be created in"
}

variable "boot_volume_size" {
  type        = number
  description = "Size of boot volume in GB"
  default     = null
}

variable "ocpus" {
  type        = number
  description = "Number of OCPUs on the instance"
}

variable "memory_in_gbs" {
  type        = number
  description = "Size of memory in GB"
}

variable "baseline_ocpu_utilization" {
  type        = string
  default     = "BASELINE_1_1"  #"BASELINE_1_1" to explicit non burstable instance
  description = "Burst Baseline"
}

variable "instance_shape" {
  type        = string
  description = "Shape of the instance"
}

variable "mp_paloalto_listing_image_resource_id" {
  type        = string
  description = "Target image id"
}

variable "mp_paloalto_listing_resource_version" {
  type        = string
  description = "Target image version "
}

variable "mp_paloalto_listing_id" {
  type        = string
  description = "Target image version"
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
  type        = string
  default     = ""
  description = "SSH public key"
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

variable "fw_authcode" {
  description = "paloalto authcode"
  type = string
  default = ""
}

variable "vips" {
  description = "Virtual IPs to be created"
  type        = any
  default     = {}
}