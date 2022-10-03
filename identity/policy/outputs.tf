output "policy_all_attributes" {
  description = "all attributes of created compute policies"
  value       = { for k, v in oci_identity_policy.policy : k => v }
}

output "policy_all_input_attributes" {
  description = "all input attributes of created policies"
  value       = { for k, v in var.policies : k => v }
}