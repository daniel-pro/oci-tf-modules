output "tag_namespace_all_input_attributes" {
   description = "all input attributes of created tag namespaces"
   value       = { for k, v in var.tag_namespaces : k => v }
}

output "tag_namespace_all_attributes" {
   description = "all attributes of created tag namespaces"
   value       = { for k, v in oci_identity_tag_namespace.tag_namespace : k => v }
}