resource "oci_identity_policy" "policy" {
    for_each       = var.policies
    compartment_id = lookup(each.value, "compartment", var.compartment_id)

    description    = lookup(each.value, "description", each.key)
    name           = lookup(each.value, "name", each.key)
    statements     = each.value.statements

    freeform_tags  = lookup(each.value, "freeform_tags", null)
    defined_tags   = lookup(each.value, "defined_tags", null)    
    version_date   = lookup(each.value, "version_date", null)
}