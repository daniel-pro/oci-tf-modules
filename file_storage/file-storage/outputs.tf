output "file_system_all_attributes" {
  description = "all attributes of created compute instances"
  value       = { for k, v in oci_file_storage_file_system.file_system : k => v }
}

output "file_system_all_input_attributes" {
  description = "all input attributes of created compute instances"
  value       = { for k, v in var.file_systems : k => v }
}

output "mount_target_all_attributes" {
  description = "all attributes of created mount targets"
  value       = { for k, v in oci_file_storage_mount_target.mount_target : k => v }
}

output "mount_target_all_input_attributes" {
  description = "all input attributes of created mount targets"
  value       = { for k, v in var.mount_targets : k => v }
}

output "snapshot_policy_all_attributes" {
  description = "all attributes of created snapshot policies"
  value       = { for k, v in oci_file_storage_filesystem_snapshot_policy.filesystem_snapshot_policy : k => v }
}

output "snapshot_policy_all_input_attributes" {
  description = "all input attributes of created snapshot policies"
  value       = { for k, v in var.snapshot_policies : k => v }
}

output "snapshot_all_attributes" {
  description = "all attributes of created snapshots"
  value       = { for k, v in oci_file_storage_snapshot.snapshot : k => v }
}

output "snapshot_all_input_attributes" {
  description = "all input attributes of created snapshots"
  value       = { for k, v in var.snapshots : k => v }
}

output "export_set_all_attributes" {
  description = "all attributes of created export sets"
  value       = { for k, v in oci_file_storage_export_set.export_set : k => v }
}