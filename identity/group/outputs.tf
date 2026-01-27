output "group_all_attributes" {
  description = "all attributes of created identity groups"
  value       = { for k, v in oci_identity_group.identity_group : k => v }
}

output "group_all_input_attributes" {
  description = "all input attributes of created identity groups"
  value       = { for k, v in var.groups : k => v }
}