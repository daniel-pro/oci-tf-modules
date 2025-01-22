output "certificate_all_attributes" {
  description = "all attributes of created certificate"
  value       = { for k, v in oci_certificates_management_certificate.certificate : k => v }
}

output "certificate_all_input_attributes" {
  description = "all input attributes of created created"
  value       = { for k, v in var.certificates : k => v }
}

output "ca_bundle_all_attributes" {
  description = "all attributes of created ca_bundle"
  value       = { for k, v in oci_certificates_management_ca_bundle.ca_bundle : k => v }
}

output "ca_bundle_all_input_attributes" {
  description = "all input attributes of created created"
  value       = { for k, v in var.ca_bundles : k => v }
}