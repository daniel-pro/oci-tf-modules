output "oci_database_cloud_exadata_infrastructure_all_attributes" {
  description = "all attributes of created database cloud exadata infrastructure"
  value       = { for k, v in oci_database_cloud_exadata_infrastructure.cloud_exadata_infrastructure : k => v }
}

output "oci_database_cloud_exadata_infrastructure_all_input_attributes" {
  description = "all input attributes of created database cloud exadata infrastructure"
  value       = { for k, v in var.cloud_exadata_infrastructures : k => v }
}

output "oci_database_cloud_vm_cluster_all_attributes" {
  description = "all attributes of created database Cloud VM Cluster"
  value       = { for k, v in oci_database_cloud_vm_cluster.cloud_vm_cluster : k => v }
}

output "oci_database_cloud_vm_cluster_all_input_attributes" {
  description = "all input attributes of created database Cloud VM Cluster"
  value       = { for k, v in var.cloud_vm_clusters : k => v }
}