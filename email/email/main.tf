resource "oci_email_email_domain" "domain" {
    compartment_id = var.compartment_id
    name = var.domain_name
  
    #Optional
    defined_tags = var.defined_tags
    freeform_tags = var.freeform_tags    
    description = var.domain_description
    domain_verification_id = var.domain_verification_id ### != null ? var.domain_verification_id : var.domain_verification != null ? oci_email_domain_verification.domain_verification[var.domain_verification].id : null
}

resource "oci_email_dkim" "dkim" {
    count = var.create_dkim ? 1 : 0
    #Required
    # email_domain_id = var.email_domain_id != null ? var.email_domain_id : var.email_domain != null ? oci_email_email_domain.domain[var.email_domain].id : null
    email_domain_id = oci_email_email_domain.domain.id

    #Optional
    defined_tags = var.defined_tags
    freeform_tags = var.freeform_tags  
    description = var.dkim_description 
    name = var.dkim_name
}

resource "oci_email_sender" "sender" {
    count = var.create_email_sender ? 1 : 0
    #Required
    compartment_id = var.compartment_id
    email_address = var.email_address

    #Optional
    defined_tags = var.defined_tags
    freeform_tags = var.freeform_tags  

}

resource "oci_identity_user" "email_user" {
    count = var.create_username ? 1 : 0

    #Required
    compartment_id = var.compartment_id
    description = var.username_description 
    name = var.username

    #Optional
    defined_tags = var.defined_tags
    freeform_tags = var.freeform_tags 
    email = var.username_email 
}

resource "oci_identity_smtp_credential" "smtp_credential" {
    count = var.generate_smtp_credentials ? 1 : 0
    description = var.smtp_credential_description
    user_id = var.smtp_user_id != null ? var.smtp_user_id : oci_identity_user.email_user.0.id
}