output "load_balancer_all_input_attributes" {
  description = "all input attributes of created load balancers"
  value       = { for k, v in var.load_balancers : k => v }
}

output "load_balancer_all_attributes" {
  description = "all attributes of created load balancers"
  value       = { for k, v in oci_load_balancer_load_balancer.load_balancer : k => v }
}