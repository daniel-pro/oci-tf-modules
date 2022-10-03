resource "oci_core_network_security_group" "network_security_group" {
  for_each = var.network_security_groups

  #Required
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id

  #Optional
  display_name = lookup(each.value, "name", each.key)

  freeform_tags = lookup(each.value, "freeform_tags", var.freeform_tags)
  defined_tags  = lookup(each.value, "defined_tags", var.defined_tags)
}


resource "oci_core_network_security_group_security_rule" "network_security_group_security_rule" {
  for_each = { for k in flatten([
    for key, nsg in var.network_security_groups : [
      for key_sr, secrule in nsg.security_rules : {
        nsg_key     = key
        secrule_key = key_sr
        secrule     = secrule
      }
    ]
    ]) : "${k.nsg_key}_${k.secrule_key}" => k
  }
  network_security_group_id = oci_core_network_security_group.network_security_group[each.value.nsg_key].id
  direction                 = lookup(each.value.secrule, "direction")
  protocol                  = lookup(each.value.secrule, "protocol")

  description      = lookup(each.value.secrule, "description", each.value.secrule_key)
  source           = lookup(each.value.secrule, "source", null)
  source_type      = lookup(each.value.secrule, "source_type", null)
  stateless        = lookup(each.value.secrule, "stateless", null)
  destination      = lookup(each.value.secrule, "destination", null)
  destination_type = lookup(each.value.secrule, "destination_type", null)

  dynamic "tcp_options" {
    for_each = lookup(each.value.secrule, "tcp_options", [])
    content {
      dynamic "source_port_range" {
        for_each = can(each.value.secrule.tcp_options.source_port_range) ? each.value.secrule.tcp_options : {}
        content {
          max = source_port_range.value.max
          min = source_port_range.value.min
        }
      }
      dynamic "destination_port_range" {
        for_each = can(each.value.secrule.tcp_options.destination_port_range) ? each.value.secrule.tcp_options : {}
        content {
          max = destination_port_range.value.max
          min = destination_port_range.value.min
        }
      }
    }
  }

  dynamic "icmp_options" {
    for_each = lookup(each.value.secrule, "icmp_options", [])
    content {
      type = icmp_options.value.type
      code = icmp_options.value.code
    }
  }

  dynamic "udp_options" {
    for_each = lookup(each.value.secrule, "udp_options", [])
    content {
      dynamic "source_port_range" {
        for_each = can(each.value.secrule.udp_options.source_port_range) ? each.value.secrule.udp_options : {}
        content {
          max = source_port_range.value.max
          min = source_port_range.value.min
        }
      }
      dynamic "destination_port_range" {
        for_each = can(each.value.secrule.udp_options.destination_port_range) ? each.value.secrule.udp_options : {}
        content {
          max = destination_port_range.value.max
          min = destination_port_range.value.min
        }
      }
    }
  }
}