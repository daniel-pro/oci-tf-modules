output "oci_database_db_system_all_attributes" {
  description = "all attributes of created database cloud exadata infrastructure"
  value       = { for k, v in oci_database_db_system.db_system : k => v }
}

output "oci_database_db_system_all_input_attributes" {
  description = "all input attributes of created database cloud exadata infrastructure"
  value       = { for k, v in var.db_systems : k => v }
}
