include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../modules/project"
}

# Konfigurasi spesifik untuk modul project
locals {
  # Mendapatkan workspace dari command-line argument atau TF_WORKSPACE
  workspace = get_env("TF_WORKSPACE", "dev")
}

inputs = {
  # Pass workspace as environment to module
  environment = local.workspace
  
  services = [
    "compute.googleapis.com",
    "iam.googleapis.com",
    "container.googleapis.com",
    "servicenetworking.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "cloudbilling.googleapis.com",
    "cloudkms.googleapis.com",
    "monitoring.googleapis.com",
    "logging.googleapis.com"
  ]
  
  labels = {
    managed_by  = "terraform"
    environment = local.workspace
  }
}


