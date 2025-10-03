
output "group_id" {
  description = "ID of the just created group"
  value       = oci_identity_group.identity_group[keys(var.groups)[0]].id
}

output "groups_ids" {
  description = "IDs of the just created groups"
  value       = [for c in oci_identity_group.identity_group[*] : { for k, v in c : k => v.id }]
}