include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/memorystore"
}

dependency "vpc" {
  config_path = "../vpc"
  
  mock_outputs = {
    network_id = "mock-vpc-id"
  }
}

locals {
  environment = "stg"
}

inputs = {
  instance_name = "awanmasterpiece-stg-redis"
  region        = "asia-southeast2"
  
  tier           = "STANDARD_HA"  # Using HA tier for staging
  memory_size_gb = 3              # Medium memory size for staging
  redis_version  = "REDIS_6_X"
  
  authorized_network = dependency.vpc.outputs.network_id
  connect_mode      = "PRIVATE_SERVICE_ACCESS"
  
  auth_enabled            = true
  transit_encryption_mode = "SERVER_AUTHENTICATION"
  
  replica_count       = 1  # One replica in staging
  read_replicas_mode = "READ_REPLICAS_ENABLED"
  
  maintenance_window = {
    day  = "SUNDAY"  # Sunday
    hour = 2  # 2 AM
  }
  
  labels = {
    environment = "stg"
    managed_by  = "terragrunt"
    purpose     = "cache"
  }
}
