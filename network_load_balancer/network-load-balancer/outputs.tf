output "network_load_balancer_all_input_attributes" {
  description = "all input attributes of created networkload balancers"
  value       = { for k, v in var.network_load_balancers : k => v }
}

output "network_load_balancer_all_attributes" {
  description = "all attributes of created network load balancers"
  value       = { for k, v in oci_network_load_balancer_network_load_balancer.network_load_balancer : k => v }
}
