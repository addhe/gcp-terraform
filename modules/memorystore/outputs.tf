output "instance_name" {
  description = "The name of the Redis instance"
  value       = google_redis_instance.cache.name
}

output "host" {
  description = "The IP address of the Redis instance"
  value       = google_redis_instance.cache.host
}

output "port" {
  description = "The port number of the Redis instance"
  value       = google_redis_instance.cache.port
}

output "current_location_id" {
  description = "The current zone where the Redis endpoint is placed"
  value       = google_redis_instance.cache.current_location_id
}

output "read_endpoint" {
  description = "The IP address of the Redis read endpoint when read replicas are enabled"
  value       = google_redis_instance.cache.read_endpoint
}

output "read_endpoint_port" {
  description = "The port number of the Redis read endpoint when read replicas are enabled"
  value       = google_redis_instance.cache.read_endpoint_port
}

output "auth_string" {
  description = "The AUTH string for the Redis instance"
  value       = google_redis_instance.cache.auth_string
  sensitive   = true
}