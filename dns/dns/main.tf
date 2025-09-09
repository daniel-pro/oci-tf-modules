resource "oci_dns_view" "dns_view" {
  for_each = var.dns_views
    #Required
    compartment_id = lookup(each.value, "compartment_id", var.compartment_id)

    #Optional
    scope = lookup(each.value, "scope", null)
    defined_tags = lookup(each.value, "defined_tags", null)
    display_name = lookup(each.value, "name", each.key)
    freeform_tags = lookup(each.value, "freeform_tags", null)
}

resource "oci_dns_zone" "dns_zone" {
  for_each = var.dns_zones
    #Required
    compartment_id = lookup(each.value, "compartment_id", var.compartment_id)
    name = lookup(each.value, "name", each.key)
    zone_type = each.value.zone_type

    #Optional
    defined_tags = lookup(each.value, "defined_tags", null)
    dynamic external_masters {
        for_each = lookup(each.value, "external_masters", {})
        content {
          #Required
          address = external_masters.value.address

          #Optional
          port = lookup(external_masters.value, "port", null)
          tsig_key_id = can(external_masters.value.tsig_key_name) ? oci_dns_tsig_key.tsig_key[external_masters.value.tsig_key_name].id : null
        }
    }
    freeform_tags = lookup(each.value, "freeform_tags", null)
    scope = lookup(each.value, "scope", null)
    view_id = lookup(each.value, "view_id", can(each.value.view_name) ? oci_dns_view.dns_view[each.value.view_name].id : null)
}

resource "oci_dns_tsig_key" "tsig_key" {
  for_each = var.tsig_keys
    #Required
    algorithm = each.value.tsig_key_algorithm
    compartment_id = lookup(each.value, "compartment_id", var.compartment_id)
    name = lookup(each.value, "name", each.key)
    secret = each.value.secret

    #Optional
    defined_tags = lookup(each.value, "defined_tags", null)
    freeform_tags = lookup(each.value, "freeform_tags", null)
}

resource "oci_dns_rrset" "dns_rrset" {
  for_each = var.dns_rrsets
    #Required
    domain = each.value.domain
    rtype = each.value.rtype
    zone_name_or_id = oci_dns_zone.dns_zone[each.value.zone_name_or_id].id
    #zone_name_or_id = each.value.zone_name_or_id
    #Optional
    compartment_id = lookup(each.value, "compartment_id", var.compartment_id)
    dynamic items {
      for_each = lookup(each.value, "items" , {})
      content {
        #Required
        domain = items.value.domain
        rdata = items.value.rdata
        rtype = items.value.rtype
        ttl = items.value.ttl
      }
    }
    scope = lookup(each.value, "scope", null)
    view_id = can(each.value.view_name) ? oci_dns_view.dns_view[each.value.view_name].id : null
}

resource "oci_dns_resolver" "dns_resolver" {
  for_each = var.dns_resolvers
    #Required
    resolver_id = each.value.resolver_id

    #Optional
    scope =  lookup(each.value, "scope", null)

    dynamic attached_views {
      for_each = lookup(each.value,"attached_views", [])
      content {
        #Required
        view_id = oci_dns_view.dns_view[attached_views.value.view_name].id
      }
    }
    defined_tags = lookup(each.value, "defined_tags", null)
    display_name = lookup(each.value, "name", each.key)
    freeform_tags = lookup(each.value, "freeform_tags", null)
    dynamic rules {
      for_each = lookup(each.value, "rules", {})
      content {
        #Required
        action = rules.value.action
        destination_addresses = rules.value.destination_addresses
        source_endpoint_name = rules.value.source_endpoint_name

        #Optional
        client_address_conditions = lookup(rules.value, "client_address_conditions", null)
        qname_cover_conditions = lookup(rules.value, "qname_cover_conditions", null)
      }
    }
  depends_on = [
    oci_dns_resolver_endpoint.dns_resolver_endpoint
  ]
}

resource "oci_dns_resolver_endpoint" "dns_resolver_endpoint" {
  for_each = var.dns_resolver_endpoints
    #Required
    is_forwarding = each.value.is_forwarding
    is_listening = each.value.is_listening
    name = lookup(each.value, "name", each.key)
    resolver_id = each.value.resolver_id
    subnet_id = each.value.subnet_id
    scope = lookup(each.value, "scope", "PRIVATE")

    #Optional
    endpoint_type = lookup(each.value, "endpoint_type", null)
    forwarding_address = lookup(each.value, "forwarding_address", null)
    listening_address = lookup(each.value, "listening_address", null)
    nsg_ids = lookup(each.value, "nsg_ids", null)
}

resource "oci_dns_steering_policy" "steering_policy" {
  for_each = var.steering_policies
    #Required
    compartment_id = lookup(each.value, "compartment_id", var.compartment_id)
    display_name   = lookup(each.value, "name", each.key)
    template       = each.value.template

    #Optional
    dynamic answers {
      for_each = lookup(each.value, "answers", {})
      content {
        #Required
        name  = lookup(answers.value, "name", answers.key)
        rdata = answers.value.rdata
        rtype = answers.value.rtype

        #Optional
        is_disabled = lookup(answers.value, "is_disabled", null)
        pool        = lookup(answers.value, "pool", null)       
      }

    }

    freeform_tags           = lookup(each.value, "freeform_tags", null)
    #health_check_monitor_id = can(each.value.health_check_monitor_id) ? each.value.health_check_monitor_id : can(each.value.http_health_check_monitor) ? oci_health_checks_http_monitor.http_monitor[each.value.http_health_check_monitor].id : can(each.value.ping_health_check_monitor) ? oci_health_checks_ping_monitor.health_checks_ping_monitor[each.value.ping_health_check_monitor].id : null
    health_check_monitor_id = can(each.value.health_check_monitor_id) ? each.value.health_check_monitor_id : can(each.value.http_health_check_monitor) ? oci_health_checks_http_monitor.http_monitor[each.value.http_health_check_monitor].id :  null

    dynamic rules {
      for_each = lookup(each.value, "rules", {})
      content {
        #Required
        rule_type = rules.value.rule_type

        #Optional
        dynamic cases {
          for_each = lookup(rules.value, "cases", {})
          content {
            #Optional
            answer_data {
              #Optional
              answer_condition = lookup(answer_data.value, "answer_condition", null)
              should_keep      = lookup(answer_data.value, "should_keep", null)
              value            = lookup(answer_data.value, "value", null)
            }

            case_condition = lookup(cases.value, "case_condition")            
          }
        }

        dynamic default_answer_data {
          for_each = lookup(rules.value, "default_answer_data", {})
          content {
            #Optional
            answer_condition = lookup(default_answer_data.value, "answer_condition")
            should_keep      = lookup(default_answer_data.value, "should_keep")   
            value            = lookup(default_answer_data.value, "value", null)         
          }
        }
        default_count = lookup(rules.value, "default_count", null)
        description = lookup(rules.value, "description", null)

      }
    }
    ttl = lookup(each.value, "ttl" , null)
}


resource "oci_health_checks_http_monitor" "http_monitor" {
  for_each = var.http_monitors
    #Required
    compartment_id = lookup(each.value, "compartment_id", var.compartment_id)
    display_name = lookup(each.value, "name", each.key)
    interval_in_seconds = each.value.interval_in_seconds
    protocol = each.value.protocol
    targets = each.value.targets

    #Optional
    defined_tags = lookup(each.value, "defined_tags", null)
    freeform_tags =  lookup(each.value, "freeform_tags", null)
    headers = lookup(each.value, "headers", null)
    is_enabled = lookup(each.value, "is_enabled", null)
    method = lookup(each.value, "method", null)
    path = lookup(each.value, "path", null)
    port = lookup(each.value, "port", null)
    timeout_in_seconds = lookup(each.value, "timeout_in_seconds", null)
    vantage_point_names = lookup(each.value, "vantage_point_names", null)
}

resource "oci_health_checks_http_probe" "http_probe" {
  for_each = var.http_probes 
    #Required
    compartment_id = lookup(each.value, "compartment_id", var.compartment_id)
    protocol = each.value.protocol
    targets = each.value.targets

    #Optional
    headers = lookup(each.value, "headers", null)
    method = lookup(each.value, "method", null)
    path = lookup(each.value, "path", null)
    port = lookup(each.value, "port", null)
    timeout_in_seconds = lookup(each.value, "timeout_in_seconds", null)
    vantage_point_names = lookup(each.value, "vantage_point_names", null)
}

resource "oci_dns_steering_policy_attachment" "steering_policy_attachment" {
  for_each = { for k in flatten([
    for key, sp in var.steering_policies : [
      for dns_zone in sp.dns_zones : {
        sp_key          = key
        dns_zone        = dns_zone
        steering_policy = sp
      }
    ]
    ]) : "${k.sp_key}_${k.dns_zone.name}" => k
  }
    #Required
    domain_name = each.value.dns_zone.domain_name
    steering_policy_id = oci_dns_steering_policy.steering_policy[lookup(each.value.steering_policy, "name", each.value.sp_key)].id
    zone_id = oci_dns_zone.dns_zone[each.value.dns_zone.name].id

    #Optional
    display_name = "${lookup(each.value.steering_policy, "name", each.value.sp_key)}-${each.value.dns_zone.name}"
}