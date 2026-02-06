resource "oci_core_route_table" "route_table" {
  for_each = var.route_tables

  compartment_id = lookup(each.value,"compartment_id",var.compartment_id)
  display_name   = lookup(each.value, "name", each.key)
  vcn_id         = oci_core_vcn.vcn.id

  freeform_tags = lookup(each.value, "freeform_tags", var.freeform_tags)
  defined_tags  = lookup(each.value, "defined_tags", var.defined_tags)

  dynamic "route_rules" {
    for_each = lookup(each.value, "route_rules", {})
    content {
      # * With this route table, NAT Gateway is always declared as the default gateway
      destination       = route_rules.value.destination_type == "CIDR_BLOCK" ? route_rules.value.destination : (route_rules.value.destination_type == "SERVICE_CIDR_BLOCK" ? lookup(data.oci_core_services.all_oci_services[route_rules.value.network_entity].services[0], "cidr_block") : route_rules.value.destination)
      destination_type  = route_rules.value.destination_type
      network_entity_id = can(route_rules.value.network_entity_id) == true ? route_rules.value.network_entity_id : can(oci_core_nat_gateway.nat_gateway[route_rules.value.network_entity]) == true ? oci_core_nat_gateway.nat_gateway[route_rules.value.network_entity].id : (can(oci_core_internet_gateway.internet_gateway[route_rules.value.network_entity]) == true ? oci_core_internet_gateway.internet_gateway[route_rules.value.network_entity].id : (can(oci_core_service_gateway.service_gateway[route_rules.value.network_entity]) == true ? oci_core_service_gateway.service_gateway[route_rules.value.network_entity].id : null))
      description       = lookup(route_rules.value, "description", null)
    }
  }
}

resource "oci_core_route_table" "attachment_route_table" {
  for_each = var.attachment_route_tables

  compartment_id = lookup(each.value,"compartment_id",var.compartment_id)
  display_name   = lookup(each.value, "name", each.key)
  vcn_id         = oci_core_vcn.vcn.id

  freeform_tags = lookup(each.value, "freeform_tags", var.freeform_tags)
  defined_tags  = lookup(each.value, "defined_tags", var.defined_tags)

  dynamic "route_rules" {
    for_each = lookup(each.value, "route_rules", {})
    content {
      # * With this route table, NAT Gateway is always declared as the default gateway
      destination       = route_rules.value.destination_type == "CIDR_BLOCK" ? route_rules.value.destination : (route_rules.value.destination_type == "SERVICE_CIDR_BLOCK" ? lookup(data.oci_core_services.all_oci_services[route_rules.value.network_entity].services[0], "cidr_block") : route_rules.value.destination)
      destination_type  = route_rules.value.destination_type
      network_entity_id = can(route_rules.value.network_entity_id) == true ? route_rules.value.network_entity_id : can(oci_core_nat_gateway.nat_gateway[route_rules.value.network_entity]) == true ? oci_core_nat_gateway.nat_gateway[route_rules.value.network_entity].id : (can(oci_core_internet_gateway.internet_gateway[route_rules.value.network_entity]) == true ? oci_core_internet_gateway.internet_gateway[route_rules.value.network_entity].id : (can(oci_core_service_gateway.service_gateway[route_rules.value.network_entity]) == true ? oci_core_service_gateway.service_gateway[route_rules.value.network_entity].id : null))
      description       = lookup(route_rules.value, "description", null)
    }
  }
}

resource "oci_core_default_route_table" "default_route_table" {
  for_each = var.default_route_table
  manage_default_resource_id = oci_core_vcn.vcn.default_route_table_id

  dynamic "route_rules" {
    for_each = each.value.route_rules 
    content {
      network_entity_id = can(route_rules.value.network_entity_id) == true ? route_rules.value.network_entity_id : (
                          can(oci_core_nat_gateway.nat_gateway[route_rules.value.network_entity]) == true ? oci_core_nat_gateway.nat_gateway[route_rules.value.network_entity].id : (
                          can(oci_core_internet_gateway.internet_gateway[route_rules.value.network_entity]) == true ? oci_core_internet_gateway.internet_gateway[route_rules.value.network_entity].id : (
                          can(oci_core_service_gateway.service_gateway[route_rules.value.network_entity]) == true ? oci_core_service_gateway.service_gateway[route_rules.value.network_entity].id : (
                          can(oci_core_local_peering_gateway.lpg[route_rules.value.network_entity]) == true ? oci_core_local_peering_gateway.lpg[route_rules.value.network_entity].id : null))))

      destination       = route_rules.value.destination_type == "CIDR_BLOCK" ? route_rules.value.destination : (route_rules.value.destination_type == "SERVICE_CIDR_BLOCK" ? lookup(data.oci_core_services.all_oci_services[route_rules.value.network_entity].services[0], "cidr_block") : route_rules.value.destination)
      destination_type  = route_rules.value.destination_type
    }
  }
  defined_tags = lookup(each.value, "defined_tags", var.defined_tags)
}
