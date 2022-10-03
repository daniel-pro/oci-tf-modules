# locals {
#  tcp_protocol  = "6"
#  udp_protocol  = "17"
#  all_protocols = "all"
#  anywhere      = "0.0.0.0/0"
#  db_port       = "1521"
#  ssh_port      = "22"
#  app_ports     = ["7201", "7202", "7401", "7402", "7601", "7602", "7001", "7002"]
#  fss_ports     = ["2048", "2050", "111"]
#}

resource "oci_core_security_list" "security_list" {
  for_each = var.security_lists

  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id

  freeform_tags = lookup(each.value, "freeform_tags", var.freeform_tags)
  defined_tags  = lookup(each.value, "defined_tags", var.defined_tags)

  display_name = lookup(each.value, "name", each.key)
  dynamic "ingress_security_rules" {

    for_each = lookup(each.value, "ingress_security_rules", {})

    content {
      protocol = ingress_security_rules.value.protocol
      source   = ingress_security_rules.value.source

      description = lookup(ingress_security_rules.value, "description", ingress_security_rules.key)

      stateless   = lookup(ingress_security_rules.value, "stateless", false)
      source_type = lookup(ingress_security_rules.value, "source_type", "CIDR_BLOCK")

      dynamic "icmp_options" {
        for_each = lookup(ingress_security_rules.value, "icmp_options", {})

        content {
          type = icmp_options.value.type
          code = icmp_options.value.code
        }
      }

      dynamic "tcp_options" {
        for_each = lookup(ingress_security_rules.value, "tcp_options", {})

        content {
          dynamic "source_port_range" {
            for_each = lookup(tcp_options.value, "source_port_range", {})
            content {
              max = source_port_range.value.max
              min = source_port_range.value.min
            }
          }
          max = tcp_options.value.destination_port_range_max
          min = tcp_options.value.destination_port_range_min
        }
      }
      dynamic "udp_options" {
        for_each = lookup(ingress_security_rules.value, "udp_options", {})
        content {
          dynamic "source_port_range" {
            for_each = lookup(udp_options.value, "source_port_range", {})
            content {
              max = source_port_range.value.max
              min = source_port_range.value.min
            }
          }
          max = udp_options.value.destination_port_range_max
          min = udp_options.value.destination_port_range_min
        }
      }
    }
  }

  dynamic "egress_security_rules" {

    for_each = lookup(each.value, "egress_security_rules", {})

    content {
      protocol    = egress_security_rules.value.protocol
      destination = egress_security_rules.value.destination

      description = lookup(egress_security_rules.value, "description", egress_security_rules.key)

      stateless        = lookup(egress_security_rules.value, "stateless", false)
      destination_type = lookup(egress_security_rules.value, "destination_type", "CIDR_BLOCK")

      dynamic "icmp_options" {
        for_each = lookup(egress_security_rules.value, "icmp_options", {})

        content {
          type = icmp_options.value.type
          code = icmp_options.value.code
        }
      }

      dynamic "tcp_options" {
        for_each = lookup(egress_security_rules.value, "tcp_options", {})

        content {
          dynamic "source_port_range" {
            for_each = lookup(tcp_options.value, "source_port_range", {})
            content {
              max = source_port_range.value.max
              min = source_port_range.value.min
            }
          }
          max = tcp_options.value.destination_port_range_max
          min = tcp_options.value.destination_port_range_min
        }
      }
      dynamic "udp_options" {
        for_each = lookup(egress_security_rules.value, "udp_options", {})
        content {
          dynamic "source_port_range" {
            for_each = lookup(udp_options.value, "source_port_range", {})
            content {
              max = source_port_range.value.max
              min = source_port_range.value.min
            }
          }
          max = udp_options.value.destination_port_range_max
          min = udp_options.value.destination_port_range_min
        }
      }
    }
  }
}
