output "oci_email_email_domain" {
  description = "all oci_email_email_domain attributes"
  value       = oci_email_email_domain.domain
}

output "oci_email_dkim" {
  description = "all oci_email_dkim attributes"
  value       = oci_email_dkim.dkim
}

output "oci_email_sender" {
  description = "all oci_email_sender attributes"
  value       = oci_email_sender.sender
}

output "oci_identity_user" {
  description = "all oci_identity_user attributes"
  value       = oci_identity_user.email_user
}

output "oci_identity_smtp_credential" {
  description = "all oci_identity_smtp_credential attributes"
  value       = oci_identity_smtp_credential.smtp_credential
}