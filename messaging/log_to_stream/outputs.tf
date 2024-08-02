output "log_service_connector_all_attributes" {
  description = "all log service_connector attributes"
  value       = { for k, v in oci_sch_service_connector.service_connector : k => v }
}

output "stream_all_attributes" {
  description = "all stream attributes"
  value       = { for k, v in oci_streaming_stream.stream : k => v }
}

output "stream_pool_all_attributes" {
  description = "all stream poool attributes"
  value       = { for k, v in oci_streaming_stream_pool.stream_pool : k => v }
}