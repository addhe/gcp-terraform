include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/project"
}

# Definisi environment secara eksplisit
locals {
  environment = "prd"
}

inputs = {
  services = [
    "compute.googleapis.com",
    "iam.googleapis.com",
    "container.googleapis.com",
    "servicenetworking.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "cloudbilling.googleapis.com",
    "cloudkms.googleapis.com",
    "monitoring.googleapis.com",
    "logging.googleapis.com",
    "sqladmin.googleapis.com",
    "redis.googleapis.com",
    "secretmanager.googleapis.com"
  ]
  
  labels = {
    managed_by  = "terraform"
    environment = "prd"
  }
}


