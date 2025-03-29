include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/project"
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
    "logging.googleapis.com"
  ]
  
  labels = {
    managed_by  = "terraform"
    environment = "dev"
  }
}


