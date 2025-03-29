locals {
  is_organization_level = var.organization_id != ""
  is_folder_level       = var.folder_id != ""
}

resource "google_project" "project" {
  name            = var.project_name
  project_id      = var.project_id
  billing_account = var.billing_account
  
  # Conditional organization or folder assignment
  org_id          = local.is_organization_level ? var.organization_id : null
  folder_id       = local.is_folder_level ? var.folder_id : null
  
  labels          = var.labels
  
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
