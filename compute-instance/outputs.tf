output "instance_all_attributes" {
   description = "all attributes of created compute instances"
   value       = { for k, v in oci_core_instance.instance : k => v }
}

output "instance_all_input_attributes" {
   description = "all input attributes of created compute instances"
   value       = { for k, v in var.compute_instances : k => v }
}

