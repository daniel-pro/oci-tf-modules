resource "oci_certificates_management_certificate" "certificate" {
  for_each = var.certificates

  certificate_config {
    config_type     = "IMPORTED"
    cert_chain_pem  = each.value.cert_chain_pem
    certificate_pem = each.value.certificate_pem
    private_key_pem = each.value.private_key_pem
  }

  compartment_id = each.value.compartment_id
  name           = lookup(each.value, "name", each.key)

}

resource "oci_certificates_management_ca_bundle" "ca_bundle" {
  for_each = var.ca_bundles

    #Required
    ca_bundle_pem = each.value.ca_bundle_pem
    compartment_id = each.value.compartment_id
    name = lookup(each.value, "name", each.key)

    #Optional
    defined_tags = lookup(each.value, "defined_tags", null)
    description = lookup(each.value, "description", null)
    freeform_tags = lookup(each.value, "freeform_tags", null)
}