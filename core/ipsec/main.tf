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
  shared_secret = lookup(each.value.tunnel, "shared_secret", null)
  ike_version   = lookup(each.value.tunnel, "ike_version", null)
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
