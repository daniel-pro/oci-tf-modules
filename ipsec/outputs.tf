output "ipsec_connection_all_input_attributes" {
  description = "all input attributes of created IPsec connections"
  value       = { for k, v in var.ipsec_connections : k => v }
}

output "cpe_all_input_attributes" {
  description = "all input attributes of created Customer Premises Equipments"
  value       = { for k, v in var.cpes : k => v }
}

output "ipsec_connection_all_attributes" {
  description = "all attributes of created IPsec connections"
  value       = { for k, v in oci_core_ipsec.ipsec_connection : k => v }
}

output "cpe_all_attributes" {
  description = "all  attributes of created Customer Premises Equipments"
  value       = { for k, v in oci_core_cpe.cpe : k => v }
}


