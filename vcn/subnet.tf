locals {
  dhcp_default_options = data.oci_core_dhcp_options.dhcp_options.options.0.id
  #dp_sec_lists         = flatten([for seclist, value in var.security_lists: value.id])
  dp_sec_lists         = [for k,v in var.subnets: v ]
  # matchkeys(var.security_lists,  keys(var.security_lists), "ssh")
}

resource "oci_core_subnet" "vcn_subnet" {
  for_each       = var.subnets
  cidr_block     = each.value.cidr_block
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id

  dhcp_options_id = oci_core_dhcp_options.dhcp_options[each.value.dhcp_options].id
  display_name    = lookup(each.value, "name", each.key)
  dns_label       = lookup(each.value, "dns_label", null)
  
  freeform_tags = lookup(each.value, "freeform_tags", var.freeform_tags)
  defined_tags  = lookup(each.value, "defined_tags", var.defined_tags)

  prohibit_public_ip_on_vnic = lookup(each.value, "type", "public") == "public" ? false : true
  route_table_id             = oci_core_route_table.route_table[each.value.route_table].id
  security_list_ids          = matchkeys(([for seclist, value in oci_core_security_list.security_list: value.id]),  keys(var.security_lists), lookup(each.value, "security_lists", []) )
}

data "oci_core_dhcp_options" "dhcp_options" {

  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id
}

data "oci_core_security_lists" "security_lists" {

  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id
}

