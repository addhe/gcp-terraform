output "project_id" {
  description = "The ID of the created project"
  value       = google_project.project.project_id
}

output "project_number" {
  description = "The number of the created project"
  value       = google_project.project.number
}

output "project_name" {
  description = "The name of the created project"
  value       = google_project.project.name
}

output "service_account" {
  description = "The default service account for the project"
  value       = "${google_project.project.number}-compute@developer.gserviceaccount.com"
}
