include "root" {
  path = find_in_parent_folders()
}

dependency "vpc" {
  config_path = "../vpc"
  
  mock_outputs = {
    network_id = "projects/awanmasterpiece-prd/global/networks/awanmasterpiece-prd-vpc"
    subnets = {
      "subnet-01" = "projects/awanmasterpiece-prd/regions/asia-southeast2/subnetworks/subnet-01"
    }
  }
}

dependency "kms" {
  config_path = "../kms"
  
  mock_outputs = {
    cloudsql_crypto_key_id = "projects/awanmasterpiece-prd/locations/asia-southeast2/keyRings/awanmasterpiece-prd-2/cryptoKeys/cloudsql-prd-2"
  }
  
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
}

locals {
  environment = "prd"
}

terraform {
  source = "${get_parent_terragrunt_dir()}/modules//cloudsql"
}

inputs = {
  instance_name     = "awanmasterpiece-prd-postgresql"
  database_version  = "POSTGRES_15"
  region           = "asia-southeast2"
  tier             = "db-f1-micro"
  disk_size        = 15
  disk_type        = "PD_SSD"
  database_name    = "app_database"
  user_name        = "admin"

  availability_type = "REGIONAL"
  
  backup_configuration = {
    enabled                        = true
    binary_log_enabled            = false  # Not applicable for PostgreSQL
    start_time                    = "04:00"
    location                      = "asia-southeast2"
    transaction_log_retention_days = 7
    retained_backups              = 7
    retention_unit                = "COUNT"
  }
  
  maintenance_window = {
    day          = 5  # Friday
    hour         = 3  # 3 AM
    update_track = "stable"
  }
  
  database_flags = [
    {
      name  = "log_min_duration_statement"
      value = "1000"  # Log queries that run longer than 1 second
    },
    {
      name  = "max_connections"
      value = "100"
    }
  ]
  
  ip_configuration = {
    ipv4_enabled       = false
    private_network    = dependency.vpc.outputs.network_id
    require_ssl        = true
    allocated_ip_range = null
    authorized_networks = []
  }
  
  user_labels = {
    environment = local.environment
    managed_by  = "terragrunt"
    engine      = "postgresql"
  }
  
  deletion_protection = false
  encryption_key_name = dependency.kms.outputs.cloudsql_crypto_key_id
}
