output "oci_database_data_guard_association_all_attributes" {
  description = "all attributes of dataguard associations"
  value       = { for k, v in oci_database_data_guard_association.data_guard_association : k => v }
  sensitive = true
}

output "oci_database_data_guard_association_all_input_attributes" {
  description = "all input attributes of created dataguard associations"
  value       = { for k, v in var.data_guard_associations : k => v }
}
