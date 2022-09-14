//Get all the Availability Domains for the region and default backup policies
data "oci_identity_availability_domains" "ad" {
  compartment_id = var.compartment_id
}

############
# Instance
############
resource "oci_core_instance" "instance" {
  for_each = var.compute_instances
  // If no explicit AD number, spread instances on all ADs in round-robin. Looping to the first when last AD is reached
  availability_domain  = each.value.availability_domain #can(each.value.ad_number) == false ? element(local.ADs, index(keys(var.compute_instances), each.key)) : element(local.ADs, each.value.ad_number - 1)
  compartment_id       = each.value.compartment_id
  display_name         = lookup(each.value, "name", each.key)
  extended_metadata    = lookup(each.value, "extended_metadata", null)
  ipxe_script          = lookup(each.value, "ipxe_script", null)
  preserve_boot_volume = lookup(each.value, "preserve_boot_volume", null)
  state                = lookup(each.value, "instance_state", null)
  shape                = lookup(each.value, "shape", null)
  fault_domain         = lookup(each.value, "fault_domain", null)
  shape_config {
    // If shape name contains ".Flex" and instance_flex inputs are not null, use instance_flex inputs values for shape_config block
    // Else use values from data.oci_core_shapes.current_ad for var.shape
    memory_in_gbs             = lookup(each.value.instance_shape_config, "memory_in_gbs", null)
    ocpus                     = lookup(each.value.instance_shape_config, "ocpus", null)
    baseline_ocpu_utilization = lookup(each.value.instance_shape_config, "baseline_ocpu_utilization", null)
  }

  agent_config {
    are_all_plugins_disabled = false
    is_management_disabled   = false
    is_monitoring_disabled   = false

    # ! provider seems to have a bug with plugin_config stanzas below
    // this configuration is applied at first resource creation
    // subsequent updates are detected as changes by terraform but seems to be ignored by the provider ...

    dynamic "plugins_config" {
      for_each = lookup(each.value, "instance_agent_config", {})
      content {
        desired_state = plugins_config.value
        name          = plugins_config.key
      }
    }
  }

  dynamic "create_vnic_details" {
    for_each = lookup(each.value, "vnic_details", {})
    content {
      assign_public_ip = lookup(create_vnic_details.value, "public_ip", false)
      display_name     = lookup(create_vnic_details.value, "vnic_name", create_vnic_details.key)
      hostname_label   = lookup(create_vnic_details.value, "hostname_label", each.key)
      private_ip       = lookup(create_vnic_details.value, "private_ip", null)

      skip_source_dest_check = lookup(create_vnic_details.value, "skip_source_dest_check", false)
      subnet_id              = create_vnic_details.value.subnet_id
      nsg_ids                = lookup(create_vnic_details.value, "nsg_ids", null)
      freeform_tags          = lookup(create_vnic_details.value, "freeform_tags", lookup(each.value, "freeform_tags", null))
      defined_tags           = lookup(create_vnic_details.value, "defined_tags", lookup(each.value, "defined_tags", null))
    }
  }

  metadata = {
    ssh_authorized_keys = lookup(each.value, "ssh_public_keys", null)
    user_data           = lookup(each.value, "user_data", null)
  }

  source_details {
    boot_volume_size_in_gbs = lookup(each.value, "boot_volume_size_in_gbs", null)
    source_id               = each.value.source_id
    source_type             = lookup(each.value, "source_type", "image")
  }

  freeform_tags = lookup(each.value, "freeform_tags", null)
  defined_tags  = lookup(each.value, "defined_tags", null)

  timeouts {
    create = lookup(each.value, "instance_timeout", null)
  }
}