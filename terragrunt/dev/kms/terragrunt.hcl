include "root" {
  path = find_in_parent_folders()
}

locals {
  environment = "dev"
}

# Menggunakan modul KMS
terraform {
  source = "${get_parent_terragrunt_dir()}/modules//kms"
}

# Dependency pada project
dependency "project" {
  config_path = "../project"
  
  # Ini memungkinkan terragrunt plan tanpa harus apply project terlebih dahulu
  mock_outputs = {
    project_id     = "awanmasterpiece-dev"
    project_number = "123456789001"
  }
}

# Konfigurasi input untuk modul KMS
inputs = {
  # Environment diambil dari local
  environment = local.environment
  
  # Project ID dan number dari output modul project
  project_id     = dependency.project.outputs.project_id
  project_number = dependency.project.outputs.project_number
  
  # Konfigurasi khusus untuk development
  # Untuk development, cukup menggunakan enkripsi standard
  algorithm        = "GOOGLE_SYMMETRIC_ENCRYPTION"
  protection_level = "SOFTWARE"
  
  # Crypto keys yang akan dibuat untuk development
  # Untuk dev, cukup satu key untuk GKE dan satu untuk compute disk
  crypto_key_names = [
    "gke-etcd",    # Untuk enkripsi data etcd GKE
    "compute-disk" # Untuk enkripsi persistent disks
  ]
}
