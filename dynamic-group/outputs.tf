output "dynamic_group_all_attributes" {
   description = "all attributes of created compute dynamic groups"
   value       = { for k, v in oci_core_dynamic_group.dynamic_group : k => v }
}

output "dynamic_group_all_input_attributes" {
   description = "all input attributes of created dynamic groups"
   value       = { for k, v in var.dynamic_groups : k => v }
}