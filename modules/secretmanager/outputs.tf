output "secrets" {
  description = "Map of created secrets and their details"
  value = {
    for k, v in google_secret_manager_secret.secret : k => {
      id   = v.id
      name = v.name
    }
  }
  sensitive = true
}

output "secret_versions" {
  description = "Map of created secret versions"
  value = {
    for k, v in google_secret_manager_secret_version.secret_version : k => v.name
  }
  sensitive = true
}
