# VCN default Security List Lockdown
resource "oci_core_default_security_list" "lockdown" {
  // If variable is true, removes all rules from default security list
  manage_default_resource_id = oci_core_vcn.vcn.default_security_list_id

  count = var.lockdown_default_seclist == true && var.lockdown_default_seclist_trigger_action == true ? 1 : 0
}

resource "oci_core_default_security_list" "restore_default" {
  // If variable is false, restore all default rules to default security list
  manage_default_resource_id = oci_core_vcn.vcn.default_security_list_id

  egress_security_rules {
    // allow all egress traffic
    destination = "0.0.0.0/0"
    protocol    = "all"
  }

  ingress_security_rules {
    // allow all SSH
    protocol = "6"
    source   = "0.0.0.0/0"
    tcp_options {
      min = 22
      max = 22
    }
  }

  ingress_security_rules {
    // allow ICMP for all type 3 code 4
    protocol = "1"
    source   = "0.0.0.0/0"

    icmp_options {
      type = "3"
      code = "4"
    }
  }

  dynamic "ingress_security_rules" {
    //allow all ICMP from all VCN CIDRs
    for_each = oci_core_vcn.vcn.cidr_blocks
    iterator = vcn_cidr
    content {
      protocol = "1"
      source   = vcn_cidr.value
      icmp_options {
        type = "3"
      }
    }
  }

  count = var.lockdown_default_seclist == false && var.lockdown_default_seclist_trigger_action == true ? 1 : 0
}
