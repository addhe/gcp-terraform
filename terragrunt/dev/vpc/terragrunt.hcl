include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/vpc"
}

# Pastikan modul project dijalankan terlebih dahulu
dependency "project" {
  config_path = "../project"
}

inputs = {
  # Inputs untuk modul VPC
  project_id   = dependency.project.outputs.project_id
  network_name = "${dependency.project.outputs.project_id}-vpc"
  description  = "dev VPC network for ${dependency.project.outputs.project_name}"
}


