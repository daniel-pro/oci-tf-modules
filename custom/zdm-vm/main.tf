data "oci_identity_availability_domains" "ad" {
  compartment_id = var.compartment_id
}

data "oci_core_images" "ol8_latest" {
  compartment_id = var.compartment_id

  operating_system = "Oracle Linux"
  operating_system_version = "8"
  shape = var.shape
}


output "latest_ol8_image" {
        value = data.oci_core_images.ol8_latest.images.0.id
}

resource "oci_core_instance" "zdminstance" {
  availability_domain  = data.oci_identity_availability_domains.ad.availability_domains[var.availability_domain - 1].name
  compartment_id       = var.compartment_id
  display_name         = var.display_name
  shape                = var.shape
  shape_config {
    memory_in_gbs     = var.shape_config_memory_in_gbs
    ocpus             = var.shape_config_ocpus
  }

  create_vnic_details {
      assign_public_ip = var.create_vnic_details_assign_public_ip
      hostname_label   = var.display_name
      private_ip       = var.create_vnic_details_private_ip
      subnet_id        = var.create_vnic_details_subnet_id
      nsg_ids          = var.create_vnic_details_nsg_ids
  }

  metadata = {
    ssh_authorized_keys = var.metadata_ssh_public_keys
    user_data           = base64encode(file("${path.module}/userdata/bootstrap_zdm.sh"))
  }

  source_details {
    boot_volume_size_in_gbs = "100"
    source_id               = data.oci_core_images.ol8_latest.images.0.id
    source_type             = "image"
  }
}