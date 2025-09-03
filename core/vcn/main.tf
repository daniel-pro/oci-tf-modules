resource "oci_core_vcn" "vcn" {
  cidr_blocks    = var.vcn_cidrs[*]
  compartment_id = var.compartment_id
  display_name   = var.vcn_name
  dns_label      = var.vcn_dns_label
  is_ipv6enabled = var.enable_ipv6

  freeform_tags = var.freeform_tags
  defined_tags  = var.defined_tags
}


resource "oci_core_drg_attachment" "drg_vcn_attachment" {
  for_each     = var.drg_vcn_attachment
  display_name = "${each.value.drg_name}-to-${oci_core_vcn.vcn.display_name}"

  freeform_tags = lookup(each.value, "freeform_tags", var.freeform_tags)
  defined_tags  = lookup(each.value, "defined_tags", var.defined_tags)

  drg_id = each.value.drg_id

  network_details {
    id             = oci_core_vcn.vcn.id                                                                     # required
    route_table_id = can(each.value.route_table_id) ? each.value.route_table_id : can(each.value.route_table) ? oci_core_route_table.attachment_route_table[each.value.route_table].id : null
    type           = "VCN"                                                                                   # Required
  }

  drg_route_table_id = can(each.value.drg_route_table_id) ? each.value.drg_route_table_id : null # (Optional) (Updatable) string

  # * args not valid for attachment type VCN at the moment
  export_drg_route_distribution_id             = null  # (Optional) (Updatable) string
  remove_export_drg_route_distribution_trigger = false # (Optional) (Updatable) boolean
}

data "oci_core_vcn_dns_resolver_association" "vcn_dns_resolver_association" {
    #Required
    vcn_id = oci_core_vcn.vcn.id
}
