output "instance_name" {
  description = "The name of the database instance"
  value       = google_sql_database_instance.instance.name
}

output "instance_connection_name" {
  description = "The connection name of the instance to be used in connection strings"
  value       = google_sql_database_instance.instance.connection_name
}

output "instance_self_link" {
  description = "The URI of the instance"
  value       = google_sql_database_instance.instance.self_link
}

output "instance_service_account_email_address" {
  description = "The service account email address assigned to the instance"
  value       = google_sql_database_instance.instance.service_account_email_address
}

output "private_ip_address" {
  description = "The first private (PRIVATE) IPv4 address assigned"
  value       = google_sql_database_instance.instance.private_ip_address
}

output "public_ip_address" {
  description = "The first public (PRIMARY) IPv4 address assigned"
  value       = google_sql_database_instance.instance.public_ip_address
}

output "database_name" {
  description = "Name of the database"
  value       = google_sql_database.database.name
}

output "user_name" {
  description = "Name of the user"
  value       = google_sql_user.user.name
}

output "generated_user_password" {
  description = "The auto generated default user password if no input password was provided"
  value       = var.user_password == "" ? random_password.user_password[0].result : null
  sensitive   = true
}
