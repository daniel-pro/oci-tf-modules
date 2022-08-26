resource "oci_core_drg" "drg" {
  compartment_id = var.compartment_id
  display_name   = var.drg_display_name

  freeform_tags = var.freeform_tags
  defined_tags  = var.defined_tags
}

resource "oci_core_remote_peering_connection" "rpc" {
  for_each       = var.rpcs
  compartment_id = var.compartment_id
  drg_id         = oci_core_drg.drg.id
  display_name   = each.key

  freeform_tags = var.freeform_tags
  defined_tags  = var.defined_tags


  peer_id          = lookup(each.value, "rpc_acceptor_id", null)
  peer_region_name = lookup(each.value, "rpc_acceptor_region", null)

}