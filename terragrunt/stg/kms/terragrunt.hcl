include "root" {
  path = find_in_parent_folders()
}

locals {
  environment = "stg"
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
    project_id     = "awanmasterpiece-stg"
    project_number = "123456789002"
  }
}

# Konfigurasi input untuk modul KMS
inputs = {
  # Environment diambil dari local
  environment = local.environment
  
  # Project ID dan number dari output modul project
  project_id     = dependency.project.outputs.project_id
  project_number = dependency.project.outputs.project_number
  
  # Konfigurasi khusus untuk staging
  algorithm        = "GOOGLE_SYMMETRIC_ENCRYPTION"
  protection_level = "SOFTWARE"
  
  # Crypto keys yang akan dibuat untuk staging
  # Untuk staging, mirip dengan production untuk testing
  crypto_key_names = [
    "gke-etcd",        # Untuk enkripsi data etcd GKE
    "gke-app-secrets", # Untuk enkripsi secrets aplikasi
    "compute-disk"     # Untuk enkripsi persistent disks
  ]
}
