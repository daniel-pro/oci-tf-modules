resource "oci_core_cpe" "cpe" {
  for_each = var.cpes
  #Required
  compartment_id = var.compartment_id
  ip_address     = each.value.ip_address

  #Optional

  # Not provided and handled by design
  cpe_device_shape_id = lookup(each.value, "cp_device_shape_id", null)

  display_name = lookup(each.value, "name", each.key)

  defined_tags  = lookup(each.value, "defined_tags", null)
  freeform_tags = lookup(each.value, "freeform_tags", null)
}

resource "oci_core_ipsec" "ipsec_connection" {
  for_each = var.ipsec_connections

  #Required
  compartment_id = var.compartment_id
  cpe_id         = oci_core_cpe.cpe[each.value.cpe_name].id
  drg_id         = each.value.drg_id
  static_routes  = lookup(each.value, "static_routes", [])

  #Optional
  cpe_local_identifier      = lookup(each.value, "cpe_local_identifier", null)
  cpe_local_identifier_type = lookup(each.value, "cpe_local_identifier_type", null)
  display_name              = lookup(each.value, "name", each.key)

  defined_tags  = lookup(each.value, "defined_tags", null)
  freeform_tags = lookup(each.value, "freeform_tags", null)
}


resource "oci_core_ipsec_connection_tunnel_management" "ipsec_connection_tunnel" {
  for_each = { for k in flatten([
    for key, ipsec in var.ipsec_connections : [
      for key_tunnel, tunnel in ipsec.tunnels : {
        ipsec_key  = key
        tunnel_key = key_tunnel
        tunnel     = tunnel
      }
    ]
    ]) : "${k.ipsec_key}_${k.tunnel_key}" => k
  }
  #Required
  ipsec_id  = oci_core_ipsec.ipsec_connection[each.value.ipsec_key].id
  tunnel_id = data.oci_core_ipsec_connection_tunnels.ipsec_connection_tunnels[each.key].ip_sec_connection_tunnels[each.value.tunnel.tunnel_idx - 1].id
  routing   = each.value.tunnel.routing

  #Optional
  dynamic "bgp_session_info" {
    for_each = { for key, value in each.value.tunnel : key => value if key == "bgp_session_info" }
    #Optional
    content {
      customer_bgp_asn      = lookup(bgp_session_info.value, "customer_bgp_asn", null)
      customer_interface_ip = lookup(bgp_session_info.value, "customer_interface_ip", null)
      oracle_interface_ip   = lookup(bgp_session_info.value, "oracle_interface_ip", null)
    }
  }
  
  display_name = lookup(each.value, "name", each.key)

  dynamic "encryption_domain_config" {
    for_each = { for key, value in each.value.tunnel : key => value if key == "encryption_domain_config" }
    #Optional
    content {
      cpe_traffic_selector    = lookup(encryption_domain_config.value, "cpe_traffic_selector", null)
      oracle_traffic_selector = lookup(encryption_domain_config.value, "oracle_traffic_selector", null)
    }
  }

   dynamic "dpd_config" {
    for_each = { for key, value in each.value.tunnel : key => value if key == "dpd_config" }
    #Optional
    content {
      dpd_mode            = lookup(dpd_config.value, "dpd_mode", "INITIATE_AND_RESPOND")
      dpd_timeout_in_sec  = lookup(dpd_config.value, "dpd_timeout_in_sec", "20")
    }
  }

  shared_secret = lookup(each.value.tunnel, "shared_secret", null)
  ike_version   = lookup(each.value.tunnel, "ike_version", null)
  nat_translation_enabled = lookup(each.value.tunnel, "nat_translation_enabled", "AUTO")
  oracle_can_initiate = lookup(each.value.tunnel, "oracle_can_initiate", "INITIATOR_OR_RESPONDER")

   dynamic "phase_one_details" {
    for_each = { for key, value in each.value.tunnel : key => value if key == "phase_one_details" }
    #Optional
    content {
      custom_authentication_algorithm  = lookup(phase_one_details.value, "custom_authentication_algorithm", "SHA2_384")
      custom_dh_group  = lookup(phase_one_details.value, "custom_dh_group", "GROUP20")
      custom_encryption_algorithm  = lookup(phase_one_details.value, "custom_encryption_algorithm", "AES_256_CBC")
      is_custom_phase_one_config  = lookup(phase_one_details.value, "is_custom_phase_one_config", "true")
      lifetime  = lookup(phase_one_details.value, "lifetime", "28800")
    }
  }

   dynamic "phase_two_details" {
    for_each = { for key, value in each.value.tunnel : key => value if key == "phase_two_details" }
    #Optional
    content {
      custom_authentication_algorithm  = lookup(phase_two_details.value, "custom_authentication_algorithm", null)
      dh_group  = lookup(phase_two_details.value, "dh_group", "GROUP5")
      custom_encryption_algorithm  = lookup(phase_two_details.value, "custom_encryption_algorithm", "AES_256_GCM")
      is_custom_phase_two_config  = lookup(phase_two_details.value, "is_custom_phase_two_config", "true")
      is_pfs_enabled = lookup(phase_two_details.value, "is_pfs_enabled", "true")
      lifetime  = lookup(phase_two_details.value, "lifetime", "3600")
    }
  }
}

data "oci_core_ipsec_connection_tunnels" "ipsec_connection_tunnels" {
  for_each = { for k in flatten([
    for key, ipsec in var.ipsec_connections : [
      for key_tunnel, tunnel in ipsec.tunnels : {
        ipsec_key  = key
        tunnel_key = key_tunnel
        tunnel     = tunnel
      }
    ]
    ]) : "${k.ipsec_key}_${k.tunnel_key}" => k
  }
  #Required
  ipsec_id = oci_core_ipsec.ipsec_connection[each.value.ipsec_key].id
  depends_on = [ 
    oci_core_ipsec.ipsec_connection 
  ]
}
