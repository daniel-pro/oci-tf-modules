data "oci_identity_availability_domains" "ad" {
  compartment_id = var.compartment_id
}

resource "oci_core_instance" "instance" {
  for_each = {
    for k, v in var.compute_instances : k => v
    if var.enabled
  }
  # for_each             = var.disabled == true ? {} : var.compute_instances
  availability_domain  = data.oci_identity_availability_domains.ad.availability_domains[each.value.availability_domain - 1].name
  compartment_id       = each.value.compartment_id
  display_name         = lookup(each.value, "name", each.key)
  extended_metadata    = lookup(each.value, "extended_metadata", null)
  ipxe_script          = lookup(each.value, "ipxe_script", null)
  preserve_boot_volume = lookup(each.value, "preserve_boot_volume", null)
  state                = lookup(each.value, "instance_state", null)
  shape                = lookup(each.value, "shape", null)
  fault_domain         = lookup(each.value, "fault_domain", null)
  shape_config {
    memory_in_gbs             = lookup(each.value.instance_shape_config, "memory_in_gbs", null)
    ocpus                     = lookup(each.value.instance_shape_config, "ocpus", null)
    baseline_ocpu_utilization = lookup(each.value.instance_shape_config, "baseline_ocpu_utilization", null)
  }

  dynamic "licensing_configs" {
    for_each = lookup(each.value, "licensing_configs", {})
    content {
      type         = lookup(licensing_configs.value, "type", null)
      license_type = lookup(licensing_configs.value, "license_type", null)
    }
  }

  agent_config {
    are_all_plugins_disabled = false
    is_management_disabled   = false
    is_monitoring_disabled   = false

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
      assign_public_ip = lookup(create_vnic_details.value, "assign_public_ip", false)
      display_name     = lookup(create_vnic_details.value, "vnic_name", create_vnic_details.key)
      hostname_label   = lookup(create_vnic_details.value, "hostname_label", each.key)
      private_ip       = lookup(create_vnic_details.value, "private_ip", null)

      skip_source_dest_check = lookup(create_vnic_details.value, "skip_source_dest_check", false)
      subnet_id              = create_vnic_details.value.subnet_id
      nsg_ids                = lookup(create_vnic_details.value, "nsg_ids", null)
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
  lifecycle {
    ignore_changes = [defined_tags]
  }
}

resource "oci_core_vnic_attachment" "vnic_attachment" {
  for_each = var.vnic_attachments
  #Required
  create_vnic_details {

    #Optional
    assign_private_dns_record = lookup(each.value.create_vnic_details, "assign_private_dns_record", null)
    assign_public_ip          = lookup(each.value.create_vnic_details, "assign_public_ip", null)
    display_name              = lookup(each.value.create_vnic_details, "name", null)
    defined_tags              = lookup(each.value.create_vnic_details, "defined_tags", null)
    freeform_tags             = lookup(each.value.create_vnic_details, "freeform_tags", null)
    hostname_label            = lookup(each.value.create_vnic_details, "hostname_label", null)
    nsg_ids                   = lookup(each.value.create_vnic_details, "nsg_ids", null)
    private_ip                = lookup(each.value.create_vnic_details, "private_ip", null)
    skip_source_dest_check    = lookup(each.value.create_vnic_details, "skip_source_dest_check", null)
    subnet_id                 = lookup(each.value.create_vnic_details, "subnet_id", null)
    vlan_id                   = lookup(each.value.create_vnic_details, "vlan_id", null)
  }
  instance_id = oci_core_instance.instance[each.value.instance_name].id

  #Optional
  display_name = lookup(each.value, "name", each.key)
  nic_index    = lookup(each.value, "nic_index", null)
}