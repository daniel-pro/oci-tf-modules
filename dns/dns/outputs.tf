output "dns_view_all_input_attributes" {
  description = "all input attributes of created DNS views"
  value       = { for k, v in var.dns_views : k => v }
}

output "dns_view_all_attributes" {
  description = "all attributes of created DNS views"
  value       = { for k, v in oci_dns_view.dns_view : k => v }
}

output "dns_zone_all_input_attributes" {
  description = "all input attributes of created DNS zones"
  value       = { for k, v in var.dns_zones : k => v }
}

output "dns_zone_all_attributes" {
  description = "all attributes of created DNS zones"
  value       = { for k, v in oci_dns_zone.dns_zone : k => v }
}

output "dns_rrset_all_input_attributes" {
  description = "all input attributes of created DNS records"
  value       = { for k, v in var.dns_rrsets : k => v }
}

output "dns_rrset_all_attributes" {
  description = "all attributes of created DNS records"
  value       = { for k, v in oci_dns_rrset.dns_rrset : k => v }
}

output "dns_resolver_all_input_attributes" {
  description = "all input attributes of created DNS resolvers"
  value       = { for k, v in var.dns_resolvers : k => v }
}

output "dns_resolver_all_attributes" {
  description = "all attributes of created DNS resolvers"
  value       = { for k, v in oci_dns_resolver.dns_resolver : k => v }
}

output "dns_resolver_endpoint_all_input_attributes" {
  description = "all input attributes of created DNS resolver_endpoints"
  value       = { for k, v in var.dns_resolver_endpoints : k => v }
}

output "dns_resolver_endpoint_all_attributes" {
  description = "all attributes of created DNS resolver_endpoints"
  value       = { for k, v in oci_dns_resolver_endpoint.dns_resolver_endpoint : k => v }
}