output "oci_database_autonomous_database_all_attributes" {
  description = "all attributes of created autonomous database"
  value       = { for k, v in oci_database_autonomous_database.autonomous_database : k => v }
  sensitive = true
}

output "oci_database_autonomous_database_all_input_attributes" {
  description = "all input attributes of created autonomous database "
  value       = { for k, v in var.autonomous_dbs : k => v }
}
