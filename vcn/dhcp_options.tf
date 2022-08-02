resource "oci_core_dhcp_options" "dhcp_options" {
    for_each       = var.dhcp_options

    compartment_id = var.compartment_id

    dynamic options {
        for_each = lookup(each.value, "options", null)

        content {
           type        = options.value.type
           server_type = lookup(options.value, "server_type", null)
           search_domain_names = lookup(options.value, "search_domain_names", null)
           custom_dns_servers  = lookup(options.value, "custom_dns_servers",null)
        }
    }

    vcn_id = oci_core_vcn.vcn.id

    display_name    = lookup(each.value, "name", each.key)
}
