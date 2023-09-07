########################
# Internet Gateway (IGW)
########################

resource "oci_core_internet_gateway" "internet_gateway" {
  for_each       = var.internet_gateway  != null ? var.internet_gateway : {}
  compartment_id = lookup(each.value,"compartment_id",var.compartment_id)
  display_name   = lookup(each.value, "name", each.key)

  freeform_tags = lookup(each.value, "freeform_tags", var.freeform_tags)
  defined_tags  = lookup(each.value, "defined_tags", var.defined_tags)

  vcn_id = oci_core_vcn.vcn.id

}

resource "oci_core_service_gateway" "service_gateway" {
  for_each       = var.service_gateway != null ? var.service_gateway : {}
  compartment_id = lookup(each.value,"compartment_id",var.compartment_id)
  display_name   = lookup(each.value, "name", each.key)

  freeform_tags = lookup(each.value, "freeform_tags", var.freeform_tags)
  defined_tags  = lookup(each.value, "defined_tags", var.defined_tags)

  services {
    service_id = lookup(data.oci_core_services.all_oci_services[lookup(each.value, "name", each.key)].services[0], "id")
  }

  vcn_id = oci_core_vcn.vcn.id

}

###################
# NAT Gateway (NGW)
###################
resource "oci_core_nat_gateway" "nat_gateway" {
  for_each = var.nat_gateway  != null ? var.nat_gateway : {}

  compartment_id = lookup(each.value,"compartment_id",var.compartment_id)
  display_name   = lookup(each.value, "name", each.key)
  freeform_tags  = lookup(each.value, "freeform_tags", var.freeform_tags)
  defined_tags   = lookup(each.value, "defined_tags", var.defined_tags)

  public_ip_id = var.nat_gateway_public_ip_id != "none" ? var.nat_gateway_public_ip_id : null

  vcn_id = oci_core_vcn.vcn.id

}

#######################
# Service Gateway (SGW)
#######################
data "oci_core_services" "all_oci_services" {
  for_each = var.service_gateway  != null ? var.service_gateway : {}
  filter {
    name   = "name"
    values = ["All .* Services In Oracle Services Network"]
    regex  = true
  }

}


#############################
# Local Peering Gateway (LPG)
#############################

resource "oci_core_local_peering_gateway" "lpg" {
  for_each       = var.local_peering_gateway != null ? var.local_peering_gateway : {}
  compartment_id = lookup(each.value,"compartment_id",var.compartment_id)
  display_name   = lookup(each.value, "name", each.key)

  freeform_tags = lookup(each.value, "freeform_tags", var.freeform_tags)
  defined_tags  = lookup(each.value, "defined_tags", var.defined_tags)

  vcn_id = oci_core_vcn.vcn.id

  #Optional
  peer_id        = can(each.value.peer_id) == false ? null : each.value.peer_id
  route_table_id = can(each.value.route_table_id) == false ? null : each.value.route_table_id

}
