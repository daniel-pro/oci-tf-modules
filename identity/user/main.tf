resource "oci_identity_user" "user" {
  for_each = var.users

    #Required
    compartment_id = lookup(each.value, "compartment_id", var.compartment_id)
    description    = each.value.description
    name           = lookup(each.value, "name", each.key)

    #Optional
    freeform_tags = lookup(each.value, "freeform_tags", null)
    defined_tags  = lookup(each.value, "defined_tags", null)
    email = lookup(each.value, "email", null)
}

resource "oci_identity_user_group_membership" "user_group_membership" {
    #Required
  for_each = { for k in flatten([
    for key, user in var.users : [
      for key_group in user.groups : {
        user_key  = key
        group_key = key_group
        user      = user
      }
    ]
    ]) : "${k.user_key}_${k.group_key}" => k
  }
    group_id = each.value.group_key
    user_id = oci_identity_user.user[each.value.user_key].id
}
