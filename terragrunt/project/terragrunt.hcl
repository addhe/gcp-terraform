include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../modules/project"
}

# Konfigurasi spesifik untuk modul project
inputs = {
  project_services = [
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
    terraform_workspace = terraform.workspace
  }
}

# Tambahkan hook untuk memastikan workspace yang benar digunakan
terraform {
  before_hook "workspace_select" {
    commands = ["init", "plan", "apply", "destroy"]
    execute  = ["terraform", "workspace", "select", get_env("TF_WORKSPACE", "dev"), "-or-create"]
  }
}
