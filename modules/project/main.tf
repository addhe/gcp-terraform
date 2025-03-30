locals {
  is_organization_level = var.organization_id != ""
  is_folder_level       = var.folder_id != ""
}

resource "google_project" "project" {
  name            = var.project_name[var.environment]
  project_id      = var.project_id[var.environment]
  billing_account = var.billing_account
  
  # Conditional organization or folder assignment
  org_id          = local.is_organization_level ? var.organization_id : null
  folder_id       = local.is_folder_level ? var.folder_id : null
  
  labels = {
    environment = var.environment
    managed_by  = "terraform"
  }
  
  lifecycle {
    prevent_destroy = true
  }
}

resource "google_project_service" "project_services" {
  for_each = toset(var.services)
  
  project  = google_project.project.project_id
  service  = each.value
  
  disable_dependent_services = true
  disable_on_destroy         = false
}

# Create service account for Cloud SQL
resource "google_service_account" "cloudsql_sa" {
  account_id   = "cloudsql-sa"
  display_name = "Cloud SQL Service Account"
  project      = google_project.project.project_id
}

# Grant necessary roles to the service account
resource "google_project_iam_member" "cloudsql_sa_roles" {
  for_each = toset([
    "roles/cloudsql.client",
    "roles/cloudsql.admin"
  ])
  
  project = google_project.project.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.cloudsql_sa.email}"
}

# Enable default service account for Cloud SQL
resource "google_project_service_identity" "cloud_sql" {
  provider = google-beta
  project  = google_project.project.project_id
  service  = "sqladmin.googleapis.com"
}

# Grant necessary roles to Cloud SQL service account
resource "google_project_iam_member" "cloud_sql_sa_roles" {
  for_each = toset([
    "roles/cloudsql.client",
    "roles/cloudsql.instanceUser",
    "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  ])
  
  project = google_project.project.project_id
  role    = each.value
  member  = "serviceAccount:${google_project_service_identity.cloud_sql.email}"
}
