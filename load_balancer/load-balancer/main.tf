resource "oci_load_balancer_load_balancer" "load_balancer" {
  for_each = var.load_balancers
  #Required
  compartment_id = each.value.compartment_id
  display_name   = lookup(each.value, "name", each.key)
  shape          = each.value.shape
  subnet_ids     = each.value.subnet_ids

  #Optional
  defined_tags               = lookup(each.value, "defined_tags", null)
  freeform_tags              = lookup(each.value, "freeform_tags", null)
  ip_mode                    = lookup(each.value, "ip_mode", "IPV4")
  is_private                 = lookup(each.value, "is_private", "true")
  network_security_group_ids = lookup(each.value, "network_security_group_ids", null)
  dynamic "reserved_ips" {
    for_each = lookup(each.value, "reserved_ips", {})
    content {
      #Optional
      id = reserved_ips.value.ids
    }
  }
  dynamic "shape_details" {
    for_each = lookup(each.value, "shape_details", {})
    #Required
    content {
      maximum_bandwidth_in_mbps = shape_details.value.maximum_bandwidth_in_mbps
      minimum_bandwidth_in_mbps = shape_details.value.minimum_bandwidth_in_mbps
    }
  }
}

resource "oci_load_balancer_certificate" "certificate" {
  for_each = var.lb_certificates
  #Required
  certificate_name = lookup(each.value, "name", each.key)
  load_balancer_id = oci_load_balancer_load_balancer.load_balancer[each.value.lb_name].id

  #Optional
  ca_certificate     = each.value.ca_certificate
  passphrase         = lookup(each.value, "passphrase", null)
  private_key        = each.value.private_key
  public_certificate = each.value.public_certificate

  lifecycle {
    create_before_destroy = true
  }
}

resource "oci_load_balancer_backend_set" "backend_set" {
  for_each = { for k in flatten([
    for key, lb in var.load_balancers : [
      for key_bs, backend_set in lb.backend_sets : {
        lb_key      = key
        bs_key      = key_bs
        backend_set = backend_set
      }
    ]
    ]) : "${k.lb_key}_${k.bs_key}" => k
  }
  #Required
  health_checker {
    #Required
    protocol = each.value.backend_set.health_checker.protocol # either HTTP or TCP

    #Optional
    interval_ms         = lookup(each.value.backend_set.health_checker, "interval_ms", null)
    port                = lookup(each.value.backend_set.health_checker, "port", null)
    response_body_regex = lookup(each.value.backend_set.health_checker, "response_body_regex", null)
    retries             = lookup(each.value.backend_set.health_checker, "retries", null)
    return_code         = lookup(each.value.backend_set.health_checker, "return_code", null)
    timeout_in_millis   = lookup(each.value.backend_set.health_checker, "timeout_in_millis", null)
    url_path            = lookup(each.value.backend_set.health_checker, "url_path", "/")
  }
  load_balancer_id = oci_load_balancer_load_balancer.load_balancer[each.value.lb_key].id
  name             = lookup(each.value.backend_set, "name", "${each.value.lb_key}_${each.value.bs_key}")
  policy           = lookup(each.value.backend_set, "policy", "ROUND_ROBIN") #  "ROUND_ROBIN" "LEAST_CONNECTIONS" "IP_HASH"

  #Optional
  dynamic "lb_cookie_session_persistence_configuration" {
    for_each = { for key, value in each.value.backend_set : key => value if key == "lb_cookie_session_persistence_configuration" }
    content {
      #Optional
      cookie_name        = lookup(lb_cookie_session_persistence_configuration.value, "cookie_name", null)
      disable_fallback   = lookup(lb_cookie_session_persistence_configuration.value, "disable_fallback", null)
      domain             = lookup(lb_cookie_session_persistence_configuration.value, "domain", null)
      is_http_only       = lookup(lb_cookie_session_persistence_configuration.value, "is_http_only", null)
      is_secure          = lookup(lb_cookie_session_persistence_configuration.value, "is_secure", null)
      max_age_in_seconds = lookup(lb_cookie_session_persistence_configuration.value, "max_age_in_seconds", null)
      path               = lookup(lb_cookie_session_persistence_configuration.value, "path", null)
    }
  }
  dynamic "session_persistence_configuration" {
    for_each = { for key, value in each.value.backend_set : key => value if key == "session_persistence_configuration" }
    content {
      #Required
      cookie_name = lookup(session_persistence_configuration.value, "cookie_name", null)

      #Optional
      disable_fallback = lookup(session_persistence_configuration.value, "disable_fallback", true)
    }
  }
  dynamic "ssl_configuration" {
    for_each = { for key, value in each.value.backend_set : key => value if key == "ssl_configuration" }
    content {
      #Optional
      certificate_ids                   = lookup(ssl_configuration.value, "certificate_ids", null)
      certificate_name                  = lookup(ssl_configuration.value, "certificate_name", null)
      cipher_suite_name                 = lookup(ssl_configuration.value, "cipher_suite_name", null)
      protocols                         = lookup(ssl_configuration.value, "protocols", null)
      server_order_preference           = lookup(ssl_configuration.value, "server_order_preference", null)
      trusted_certificate_authority_ids = lookup(ssl_configuration.value, "trusted_certificate_authority_ids", null)
      verify_depth                      = lookup(ssl_configuration.value, "verify_depth", null)
      verify_peer_certificate           = lookup(ssl_configuration.value, "verify_peer_certificate", null)
    }
  }
}

resource "oci_load_balancer_backend" "backend" {
  for_each = { for k in flatten([
    for key, lb in var.load_balancers : [
      for key_bs, backend_set in lb.backend_sets : [
        for key_b, backend in backend_set.backends : {
          lb_key  = key
          bs_key  = key_bs
          b_key   = key_b
          backend = backend
        }
      ]
    ]
    ]) : "${k.lb_key}_${k.bs_key}_${k.b_key}" => k
  }
  #Required
  backendset_name  = oci_load_balancer_backend_set.backend_set["${each.value.lb_key}_${each.value.bs_key}"].name
  ip_address       = each.value.backend.ip_address
  load_balancer_id = oci_load_balancer_load_balancer.load_balancer[each.value.lb_key].id
  port             = each.value.backend.port

  #Optional
  backup  = lookup(each.value.backend, "backup", null)
  drain   = lookup(each.value.backend, "drain", null)
  offline = lookup(each.value.backend, "offline", null)
  weight  = lookup(each.value.backend, "weight", null)
}


resource "oci_load_balancer_hostname" "hostname" {
  for_each = { for k in flatten([
    for key, lb in var.load_balancers : [
      for key_h, hostname in lb.hostnames : {
        lb_key   = key
        host_key = key_h
        hostname = hostname
      }
    ]
    ]) : "${k.lb_key}_${k.host_key}" => k
  }
  #Required
  hostname         = each.value.hostname.hostname
  load_balancer_id = oci_load_balancer_load_balancer.load_balancer[each.value.lb_key].id
  name             = "${each.value.lb_key}_${each.value.host_key}"

  #Optional
  lifecycle {
    create_before_destroy = true
  }
}


resource "oci_load_balancer_listener" "listener" {
  for_each = { for k in flatten([
    for key, lb in var.load_balancers : [
      for key_ls, listener in lb.listeners : {
        lb_key   = key
        lsnr_key = key_ls
        listener = listener
      }
    ]
    ]) : "${k.lb_key}_${k.lsnr_key}" => k
  }
  #Required
  default_backend_set_name = oci_load_balancer_backend_set.backend_set["${each.value.lb_key}_${each.value.listener.default_backend_set_name}"].name
  load_balancer_id         = oci_load_balancer_load_balancer.load_balancer[each.value.lb_key].id
  name                     = "${each.value.lb_key}_${each.value.lsnr_key}"
  port                     = each.value.listener.port
  protocol                 = lookup(each.value.listener, "protocol", "HTTP") # "HTTP" "HTTP2" "TCP"

  #Optional
  dynamic "connection_configuration" {
    for_each = { for key, value in each.value.listener : key => value if key == "connection_configuration" }
    content {
      #Required
      idle_timeout_in_seconds = connection_configuration.value.idle_timeout_in_seconds

      #Optional
      backend_tcp_proxy_protocol_version = lookup(connection_configuration.value, "backend_tcp_proxy_protocol_version", null)
    }
  }
  hostname_names = [for host in lookup(each.value.listener, "hostnames", []) : oci_load_balancer_hostname.hostname["${each.value.lb_key}_${host}"].name]

  #    routing_policy_name = can(each.value.listener.routing_policy_name) ? oci_load_balancer_load_balancer_routing_policy.load_balancer_routing_policy[each.value.listener.routing_policy_name].name : null
  #    rule_set_names = [for ruleset in lookup(each.value.listener, "rule_set_names", []) : oci_load_balancer_rule_set.rule_set["${each.value.lb_key}_${ruleset}"].name ]

  dynamic "ssl_configuration" {
    for_each = { for key, value in each.value.listener : key => value if key == "ssl_configuration" }
    content {
      #Optional
      certificate_name                  = lookup(ssl_configuration.value, "certificate_name", null)
      certificate_ids                   = lookup(ssl_configuration.value, "certificate_ids", null)
      cipher_suite_name                 = lookup(ssl_configuration.value, "cipher_suite_name", null)
      protocols                         = lookup(ssl_configuration.value, "protocols", null)
      server_order_preference           = lookup(ssl_configuration.value, "server_order_preference", null)
      trusted_certificate_authority_ids = lookup(ssl_configuration.value, "trusted_certificate_authority_ids", null)
      verify_depth                      = lookup(ssl_configuration.value, "verify_depth", null)
      verify_peer_certificate           = lookup(ssl_configuration.value, "verify_peer_certificate", false)
    }
  }
  depends_on = [
    oci_load_balancer_certificate.certificate
  ]
}

/* WIP


















resource "oci_load_balancer_load_balancer_routing_policy" "test_load_balancer_routing_policy" {
    #Required
    condition_language_version = var.load_balancer_routing_policy_condition_language_version
    load_balancer_id = oci_load_balancer_load_balancer.test_load_balancer.id
    name = var.load_balancer_routing_policy_name
    rules {
        #Required
        actions {
            #Required
            name = var.load_balancer_routing_policy_rules_actions_name

            #Optional
            backend_set_name = oci_load_balancer_backend_set.test_backend_set.name
        }
        condition = var.load_balancer_routing_policy_rules_condition
        name = var.load_balancer_routing_policy_rules_name
    }
}



resource "oci_load_balancer_rule_set" "test_rule_set" {
    #Required
    items {
        #Required
        action = var.rule_set_items_action

        #Optional
        allowed_methods = var.rule_set_items_allowed_methods
        are_invalid_characters_allowed = var.rule_set_items_are_invalid_characters_allowed
        conditions {
            #Required
            attribute_name = var.rule_set_items_conditions_attribute_name
            attribute_value = var.rule_set_items_conditions_attribute_value

            #Optional
            operator = var.rule_set_items_conditions_operator
        }
        description = var.rule_set_items_description
        header = var.rule_set_items_header
        http_large_header_size_in_kb = var.rule_set_items_http_large_header_size_in_kb
        prefix = var.rule_set_items_prefix
        redirect_uri {

            #Optional
            host = var.rule_set_items_redirect_uri_host
            path = var.rule_set_items_redirect_uri_path
            port = var.rule_set_items_redirect_uri_port
            protocol = var.rule_set_items_redirect_uri_protocol
            query = var.rule_set_items_redirect_uri_query
        }
        response_code = var.rule_set_items_response_code
        status_code = var.rule_set_items_status_code
        suffix = var.rule_set_items_suffix
        value = var.rule_set_items_value
    }
    load_balancer_id = oci_load_balancer_load_balancer.test_load_balancer.id
    name = var.rule_set_name
}

resource "oci_load_balancer_ssl_cipher_suite" "test_ssl_cipher_suite" {
    #Required
    ciphers = var.ssl_cipher_suite_ciphers
    name = var.ssl_cipher_suite_name

    #Optional
    load_balancer_id = oci_load_balancer_load_balancer.test_load_balancer.id
}
*/