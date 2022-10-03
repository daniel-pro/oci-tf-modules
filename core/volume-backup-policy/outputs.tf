output "volume_backup_policy_all_attributes" {
  description = "all attributes of created volume backup policy"
  value       = { for k, v in oci_core_volume_backup_policy.volume_backup_policy : k => v }
}

output "volume_backup_policy_all_input_attributes" {
  description = "all input attributes of reated volume backup policy"
  value       = { for k, v in var.volume_backup_policies : k => v }
}

