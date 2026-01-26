output "oci_database_db_system_all_attributes" {
  description = "all attributes of created database system"
  value       = { for k, v in oci_database_db_system.db_system : k => v }
  sensitive = true
}

output "oci_database_db_system_all_input_attributes" {
  description = "all input attributes of created database system"
  value       = { for k, v in var.db_systems : k => v }
}

output "oci_databases_on_all_db_systems" {
  description = "all dbs created during the DB system creation"
  value       = data.oci_database_databases.databases
}

output "oci_recovery_protection_policies" {
  value       = data.oci_recovery_protection_policies.protection_policies
}