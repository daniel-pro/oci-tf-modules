output "oci_database_pluggable_database_all_attributes" {
  description = "all attributes of created pluggable database"
  value       = { for k, v in oci_database_pluggable_database.pluggable_database : k => v }
  sensitive = true
}

output "oci_database_pluggable_database_all_input_attributes" {
  description = "all input attributes of created pluggable database"
  value       = { for k, v in var.pluggable_database : k => v }
}
