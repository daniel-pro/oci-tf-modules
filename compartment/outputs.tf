output "iam_compartment_all_input_attributes" {
  description = "all attributes of created compartments"
  value       = { for k, v in var.compartments : k => v }
}

output "compartment_id" {
  description = "ID of the just created compartment"
  value       = oci_identity_compartment.identity_compartment[keys(var.compartments)[0]].id
}

output "compartment_ids" {
  description = "IDs of the just created compartments"
  value       = [for c in oci_identity_compartment.identity_compartment[*] : { for k, v in c : k => v.id }]
}