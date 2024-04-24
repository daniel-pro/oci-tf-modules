output "vcn_id" {
  description = "id of vcn that is created"
  value       = oci_core_vcn.vcn.id
}


output "internet_gateway_all_attributes" {
  description = "all attributes of created internet gateway"
  value       = { for k, v in oci_core_internet_gateway.internet_gateway : k => v }
}

output "lpg_all_attributes" {
  description = "all attributes of created lpg"
  value       = { for k, v in oci_core_local_peering_gateway.lpg : k => v }
}

output "nat_gateway_all_attributes" {
  description = "all attributes of created nat gateway"
  value       = { for k, v in oci_core_nat_gateway.nat_gateway : k => v }
}

output "service_gateway_all_attributes" {
  description = "all attributes of created service gateway"
  value       = { for k, v in oci_core_service_gateway.service_gateway : k => v }
}

output "vcn_all_attributes" {
  description = "all attributes of created vcn"
  value       = { for k, v in oci_core_vcn.vcn : k => v }
}

output "subnet_id" {
  value = try(oci_core_subnet.vcn_subnet[*].id, null)
}
output "subnet_all_attributes" {
  description = "all attributes of created vcn"
  value       = { for k, v in oci_core_subnet.vcn_subnet : k => v }
}
output "security_list_id" {
  value = try(oci_core_security_list.security_list[*].id, null)
}
output "security_list_all_attributes" {
  description = "all attributes of created security list"
  value       = { for k, v in oci_core_security_list.security_list : k => v }
}

output "network_security_group_all_attributes" {
  description = "all attributes of created nsgs"
  value       = { for k, v in oci_core_network_security_group.network_security_group : k => v }
}

output "dns_resolver_id" {
  description = "The VCN DNS resolver ID"
  value = data.oci_core_vcn_dns_resolver_association.vcn_dns_resolver_association.dns_resolver_id
}