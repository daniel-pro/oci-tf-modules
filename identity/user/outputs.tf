output "user_all_input_attributes" {
  description = "all input attributes of created users"
  value       = { for k, v in var.users : k => v }
}

output "user_all_attributes" {
  description = "all attributes of created user"
  value       = { for k, v in oci_identity_user.user : k => v }
}