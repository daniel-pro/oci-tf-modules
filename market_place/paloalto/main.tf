module "paloalto_compute_instance" {
  source = "./paloalto-compute-instance"

  instance_display_name = var.instance_display_name
  compartment_id        = var.compartment_id
  availability_domain   = var.availability_domain
  boot_volume_size      = var.boot_volume_size
  ocpus                 = var.ocpus
  baseline_ocpu_utilization = var.baseline_ocpu_utilization
  memory_in_gbs                    = var.memory_in_gbs
  instance_shape                   = var.instance_shape
  mp_paloalto_listing_image_resource_id = var.mp_paloalto_listing_image_resource_id

  mp_paloalto_listing_resource_version = var.mp_paloalto_listing_resource_version
  mp_paloalto_listing_id               = var.mp_paloalto_listing_id

  #vcn_compartment_id     = var.vcn_compartment_id
  #existing_vcn_id        = var.existing_vcn_id
  #subnet_compartment_id  = var.subnet_compartment_id
  #subnet_id              = var.subnet_id
  vnic0_details         = var.vnic0_details
  secondary_vnic_details         = var.secondary_vnic_details
  vips                  = var.vips
  ssh_authorized_keys   = var.ssh_authorized_keys
  freeform_tags         = var.freeform_tags
  defined_tags          = var.defined_tags
  public_subnet_id      = var.public_subnet_id
  fw_hostname           = var.instance_display_name
  boot_volume_backup_policy      = var.boot_volume_backup_policy
}