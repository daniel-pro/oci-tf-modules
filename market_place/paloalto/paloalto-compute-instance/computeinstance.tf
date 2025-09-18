locals {
  is_flex_shape     = (var.instance_shape == "VM.Standard.3.Flex") || (var.instance_shape == "VM.Optimized3.Flex")
  flex_shape_config = local.is_flex_shape ? [{ "ocpus" : var.ocpus, "memory_in_gbs" : var.memory_in_gbs, "baseline_ocpu_utilization": try(var.baseline_ocpu_utilization, null) }] : []
  #default_backup_policies = { for i in data.oci_core_volume_backup_policies.default_backup_policies.volume_backup_policies : i.display_name => i.id }
  user_data = base64encode(templatefile("${path.module}/userdata/pangfvm", {
    fw_hostname  = var.instance_display_name
    fw_authcode  = var.fw_authcode
  }))
}

data "oci_identity_availability_domains" "ad" {
  compartment_id = var.compartment_id
}

# data "oci_core_volume_backup_policies" "default_backup_policies" {}

# data "cloudinit_config" "paloalto_cloud_init" {
#   gzip          = "true"
#   base64_encode = "true"

#   part {
#     filename     = "paloalto-cloud-init.cfg"
#     content_type = "text/cloud-config"
#     content      = templatefile( "${path.module}/cloud_init/cloudinit.template.yaml", {})
#   }
# }

data "oci_core_private_ips" "paloalto_MP_private_ips" {
  depends_on = [ oci_core_vnic_attachment.vnic_attachment ]

  #for_each = {for key, value in oci_core_vnic_attachment.vnic_attachment : key => value if lookup(value.create_vnic_details , "assign_reserved_public_ip", false)}
  for_each = {for key, value in var.secondary_vnic_details : key => value if lookup(value , "assign_reserved_public_ip", false)}

  ip_address = each.value.private_ip
  subnet_id  = each.value.subnet_id 
}

resource "oci_core_instance" "paloalto_MP_instance" {
  availability_domain = data.oci_identity_availability_domains.ad.availability_domains[var.availability_domain - 1].name

  compartment_id = var.compartment_id

  shape = var.instance_shape
  source_details {
    source_id               = var.mp_paloalto_listing_image_resource_id
    source_type             = "image"
    boot_volume_size_in_gbs = var.boot_volume_size
  }

  dynamic "shape_config" {
    for_each = local.flex_shape_config
    content {
      ocpus         = shape_config.value.ocpus
      memory_in_gbs = shape_config.value.memory_in_gbs
      baseline_ocpu_utilization = shape_config.value.baseline_ocpu_utilization  #"BASELINE_1_1" to explicit non burstable instance
    }
  }
  display_name = var.instance_display_name

  dynamic "create_vnic_details" {
    for_each = var.vnic0_details
    iterator = create_vnic_details
    content {
      assign_public_ip = lookup(create_vnic_details.value, "assign_public_ip", false)
      display_name     = lookup(create_vnic_details.value, "vnic_name", create_vnic_details.key)
      hostname_label   = lookup(create_vnic_details.value, "hostname_label", create_vnic_details.key)
      private_ip       = lookup(create_vnic_details.value, "private_ip", null)

      skip_source_dest_check = lookup(create_vnic_details.value, "skip_source_dest_check", true)
      subnet_id              = create_vnic_details.value.subnet_id
      nsg_ids                = lookup(create_vnic_details.value, "nsg_ids", null)
    }
  }

  lifecycle {
    ignore_changes = [ metadata ]
  }
  metadata = {
    ssh_authorized_keys = var.ssh_authorized_keys
    #user_data           = local.user_data
  }

  preserve_boot_volume = false
  freeform_tags = var.freeform_tags
  defined_tags  = var.defined_tags
}


resource "oci_core_vnic_attachment" "vnic_attachment" {
  for_each = var.secondary_vnic_details
  #Required
  create_vnic_details {

    #Optional
    assign_private_dns_record = lookup(each.value, "assign_private_dns_record", null)
    assign_public_ip          = lookup(each.value, "assign_public_ip", null)
    display_name              = lookup(each.value, "name", each.key)
    defined_tags              = lookup(each.value, "defined_tags", null)
    freeform_tags             = lookup(each.value, "freeform_tags", null)
    hostname_label            = lookup(each.value, "hostname_label", null)
    nsg_ids                   = lookup(each.value, "nsg_ids", null)
    private_ip                = lookup(each.value, "private_ip", null)
    skip_source_dest_check    = lookup(each.value, "skip_source_dest_check", true)
    subnet_id                 = lookup(each.value, "subnet_id", null)
    vlan_id                   = lookup(each.value, "vlan_id", null)
  }
  instance_id = oci_core_instance.paloalto_MP_instance.id

  #Optional
  display_name = lookup(each.value, "name", each.key)
  nic_index    = lookup(each.value, "nic_index", null)
}

resource "oci_core_public_ip" "paloalto_MP_instance_public_ip" {
  #for_each = {for key, value in data.oci_core_private_ips.paloalto_MP_private_ips.private_ips : value.display_name => value}
  for_each = {for key, value in var.secondary_vnic_details : key => value if lookup(value , "assign_reserved_public_ip", false)}

  compartment_id = var.compartment_id
  display_name   = join("-", [each.key, "pub-ip"])
  lifetime       = "RESERVED"
  private_ip_id  = data.oci_core_private_ips.paloalto_MP_private_ips[each.key].private_ips[0].id
  freeform_tags = var.freeform_tags
  defined_tags  = var.defined_tags
}

output "vm_public_ip" {
  value = oci_core_instance.paloalto_MP_instance.public_ip
}
output "vm_private_ip" {
  value = oci_core_instance.paloalto_MP_instance.private_ip
}

data "oci_core_vnic_attachments" "vnic_attachments" {
    #Required
    compartment_id = var.compartment_id

    #Optional
#    availability_domain = var.vnic_attachment_availability_domain
#    instance_id = oci_core_instance.test_instance.id
#    vnic_id = oci_core_vnic.test_vnic.id
}

resource "oci_core_private_ip" "public_vip_private_ip" {
  for_each = var.vips
  #Optional
  defined_tags = lookup(each.value, "defined_tags", null)
  display_name   = join("-", [lookup(each.value, "display_name", each.key), "Private"])
  freeform_tags = lookup(each.value, "freeform_tags", null)
  hostname_label = lookup(each.value, "hostname_label", null)
  ip_address = lookup(each.value, "ip_address", null)
  # route_table_id = lookup(each.value, "route_table_id", null)
  # subnet_id = lookup(each.value, "subnet_id", null)
  # vlan_id = lookup(each.value, "vlan_id", null)
  #vnic_id = data.oci_core_vnic_attachments.vnic_attachments.vnic_attachments[each.value.vnic_index].vnic_id
  vnic_id = oci_core_vnic_attachment.vnic_attachment[each.value.vnic_name].vnic_id
}

resource "oci_core_public_ip" "public_vip_public_ip" {
  for_each = {for key, value in var.vips : key => value if lookup(value , "assign_public_ip", false)}
  compartment_id = var.compartment_id
  display_name   = join("-", [lookup(each.value, "display_name", each.key), "Public"])
  lifetime       = "RESERVED"
  private_ip_id  = oci_core_private_ip.public_vip_private_ip[each.key].id
  freeform_tags = lookup(each.value, "freeform_tags", null)
  defined_tags  = lookup(each.value, "defined_tags", null)
}