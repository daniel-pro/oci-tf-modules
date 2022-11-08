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
    view_id = can(each.value.view_name) ? oci_dns_view.dns_view[each.value.view_name].id : null
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
    zone_name_or_id = oci_dns_zone.dns_zone[each.value.zone_name].id

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
        client_address_conditions = lookup(each.value, "client_address_conditions", null)
        qname_cover_conditions = lookup(each.value, "qname_cover_conditions", null)
      }
    }
}

resource "oci_dns_resolver_endpoint" "dns_resolver_endpoint" {
  for_each = var.dns_resolver_endpoints
    #Required
    is_forwarding = each.value.is_forwarding
    is_listening = each.value.is_listening
    name = lookup(each.value, "name", each.key)
    resolver_id = oci_dns_resolver.dns_resolver[each.value.resolver_name].id
    subnet_id = each.value.subnet_id
    scope = lookup(each.value, "scope", "PRIVATE")

    #Optional
    endpoint_type = lookup(each.value, "endpoint_type", null)
    forwarding_address = lookup(each.value, "forwarding_address", null)
    listening_address = lookup(each.value, "listening_address", null)
    nsg_ids = lookup(each.value, "nsg_ids", null)
}