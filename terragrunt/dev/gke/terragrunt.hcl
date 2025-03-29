include "root" {
  path = find_in_parent_folders()
}

locals {
  environment = "dev"
}

# Menggunakan modul GKE
terraform {
  source = "${get_parent_terragrunt_dir()}/modules//gke"
}

# Dependency pada VPC dan project
dependency "vpc" {
  config_path = "../vpc"
  
  # Ini memungkinkan terragrunt plan tanpa harus apply vpc terlebih dahulu
  mock_outputs = {
    network_name = "awanmasterpiece-dev-vpc"
    network_id   = "projects/awanmasterpiece-dev/global/networks/awanmasterpiece-dev-vpc"
    subnet_ips = {
      "subnet-01" = "10.10.0.0/24"
    }
    subnet_secondary_ranges = {
      "subnet-01" = {
        "pods"     = "10.100.0.0/16"
        "services" = "10.101.0.0/20"
      }
    }
    subnets = {
      "subnet-01" = "https://www.googleapis.com/compute/v1/projects/awanmasterpiece-dev/regions/asia-southeast2/subnetworks/subnet-01"
    }
  }
}

dependency "project" {
  config_path = "../project"
  
  # Ini memungkinkan terragrunt plan tanpa harus apply project terlebih dahulu
  mock_outputs = {
    project_id = "awanmasterpiece-dev"
    project_number = "123456789012"
  }
}

# Dependency pada KMS untuk CMEK
dependency "kms" {
  config_path = "../kms"
  
  # Ini memungkinkan terragrunt plan tanpa harus apply kms terlebih dahulu
  mock_outputs = {
    gke_crypto_key_id = "projects/awanmasterpiece-dev/locations/asia-southeast2/keyRings/awanmasterpiece-dev/cryptoKeys/gke-etcd-dev"
  }
  skip_outputs = false
}

# Konfigurasi input untuk modul GKE
inputs = {
  # Environment diambil dari local
  environment = local.environment
  
  # Project ID dari output modul project
  project_id = dependency.project.outputs.project_id
  
  # Konfigurasi network dari output modul VPC
  network_name = dependency.vpc.outputs.network_name
  subnet_name  = "subnet-01"  # Menggunakan subnet-01 yang memiliki secondary range untuk pods & services
  
  # Service account untuk nodes (menggunakan compute default service account untuk saat ini)
  service_account = "${dependency.project.outputs.project_number}-compute@developer.gserviceaccount.com"
  
  # CIDR blocks yang boleh akses ke Kubernetes master endpoint
  master_authorized_networks = [
    {
      cidr_block   = "10.10.0.0/24"  # Subnet-01 CIDR
      display_name = "VPC subnet-01"
    },
    {
      cidr_block   = "35.235.240.0/20"  # IAP CIDR range
      display_name = "Cloud IAP for SSH"
    }
  ]
  
  # Konfigurasi khusus untuk development
  regional = false  # Gunakan zonal cluster untuk dev untuk menghemat biaya
  
  # Menggunakan KMS key untuk enkripsi database GKE (etcd)
  database_encryption_key_name = dependency.kms.outputs.gke_crypto_key_id
}
