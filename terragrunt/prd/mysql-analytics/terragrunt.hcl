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
  instance_name     = "awanmasterpiece-prd-mysql-analytics"
  database_version  = "MYSQL_8_0"
  region           = "asia-southeast2"
  tier             = "db-custom-4-4096"
  disk_size        = 20  # Lebih besar untuk analytics
  disk_type        = "PD_SSD"
  database_name    = "analytics_database"
  user_name        = "admin"

  availability_type = "REGIONAL"
  
  backup_configuration = {
    enabled                        = true
    binary_log_enabled            = true
    start_time                    = "03:00"  # Berbeda dengan app database
    location                      = "asia-southeast2"
    transaction_log_retention_days = 7
    retained_backups              = 7
    retention_unit                = "COUNT"
  }
  
  maintenance_window = {
    day          = 6  # Saturday
    hour         = 3  # 3 AM
    update_track = "stable"
  }
  
  database_flags = [
    {
      name  = "slow_query_log"
      value = "on"
    },
    {
      name  = "long_query_time"
      value = "2"  # Lebih longgar untuk analytics queries
    },
    {
      name  = "innodb_buffer_pool_size"
      value = "858993459"  # 819MB untuk analytics
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
    purpose     = "analytics"
  }
  
  deletion_protection = true
  encryption_key_name = dependency.kms.outputs.cloudsql_crypto_key_id
}
