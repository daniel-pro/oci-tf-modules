variable "compartment_id" {
  description = "Compartment Id of the new ZDM VM"
  type        = string
}

variable "display_name" {
  description = "ZDM VM name"
  type        = string
}

variable "availability_domain" {
  description = "ZDM VM availability_domain"
  type        = string
}

variable "shape" {
  description = "ZDM VM shape"
  type        = string
  default     = "VM.Standard.E5.Flex"
}

variable "shape_config_memory_in_gbs" {
  description = "ZDM VM Memory in GBs"
  type        = string
  default     = "16"
}

variable "shape_config_ocpus" {
  description = "ZDM VM OCPUs number"
  type        = string
  default     = "2"
}

variable "create_vnic_details_assign_public_ip" {
  description = "ZDM VM Public IP Flag"
  type        = bool
  default     = false
}

variable "create_vnic_details_private_ip" {
  description = "ZDM VM Private IP value"
  type        = string
  default     = null
}

variable "create_vnic_details_subnet_id" {
  description = "ZDM VM subnet id"
  type        = string
}

variable "create_vnic_details_nsg_ids" {
  description = "ZDM VM NSG list"
  type        = list
  default     = []
}

variable "metadata_ssh_public_keys" {
  description = "ZDM VM opc's SSH authorized public keys"
  type        = string
}