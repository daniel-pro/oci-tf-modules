resource "oci_database_pluggable_database" "pluggable_database" {
  for_each = var.pluggable_databases
    #Required
    container_database_id = each.value.container_database_id
    pdb_name = lookup(each.value, "pdb_name", each.key)

    #Optional
    defined_tags                       = lookup(each.value, "defined_tags", null)
    freeform_tags                      = lookup(each.value, "freeform_tags", null)
    pdb_admin_password                 = lookup(each.value, "pdb_admin_password", null)
    should_pdb_admin_account_be_locked = lookup(each.value, "should_pdb_admin_account_be_locked", null)
    tde_wallet_password                = lookup(each.value, "tde_wallet_password", null)

  # Default is 20m
  timeouts {
    create = "2h"
    delete = "2h"
  }
}