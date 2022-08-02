output "drg_id" {
  description = "id of drg if it is created"
  value       = oci_core_drg.drg.id
}

output "drg_display_name" {
  description = "display name of drg if it is created"
  value       = oci_core_drg.drg[*].display_name
}

# Complete outputs for each resources with provider parity. Auto-updating.
# Useful for module composition.
output "drg_all_attributes" {
  description = "all attributes of created drg"
  value       = { for k, v in oci_core_drg.drg : k => v }
}

### output "rpc_id" {
###   description = "id of RPC if it is created"
###   value       = join(",", oci_core_remote_peering_connection.rpc.*.id)
### }
### 
### output "rpc_display_name" {
###   description = "display name of RPC if it is created"
###   value       = join(",", oci_core_remote_peering_connection.rpc.*.display_name)
### }

output "rpc_ids" {
  description = "id of RPC if it is created"
  value       = [for c in oci_core_remote_peering_connection.rpc[*]: {for k, v in c : k => v.id}] 
}

output "rpc_all_attributes" {
  description = "all attributes of created RPC"
  value       = { for k, v in oci_core_remote_peering_connection.rpc : k => v }
}
