output "bucket_all_input_attributes" {
  description = "all input attributes of created buckets"
  value       = { for k, v in var.buckets : k => v }
}

output "bucket_all_attributes" {
  description = "all attributes of created buckets"
  value       = { for k, v in oci_objectstorage_bucket.bucket : k => v }
}