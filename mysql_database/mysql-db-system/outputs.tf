output "oci_mysql_mysql_db_system_all_attributes" {
  description = "all attributes of created database system"
  value       = { for k, v in oci_mysql_mysql_db_system.mysql_db_system : k => v }
  sensitive = true
}

output "oci_mysql_mysql_db_system_all_input_attributes" {
  description = "all input attributes of created database system"
  value       = { for k, v in var.mysql_db_systems : k => v }
}