include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/vpc"
}

# Definisi environment secara eksplisit
locals {
  environment = "prd"
}

# Pastikan modul project dijalankan terlebih dahulu
dependency "project" {
  config_path = "../project"
  
  # Mock outputs untuk memungkinkan terragrunt plan tanpa menerapkan project
  mock_outputs = {
    project_id   = "awanmasterpiece-prd"
    project_name = "Awan Masterpiece Production"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

inputs = {
  # Inputs untuk modul VPC
  project_id   = dependency.project.outputs.project_id
  network_name = "${dependency.project.outputs.project_id}-vpc"
  description  = "prd VPC network for ${dependency.project.outputs.project_name}"
}


