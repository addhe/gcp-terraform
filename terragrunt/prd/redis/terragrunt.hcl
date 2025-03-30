include "root" {
  path = find_in_parent_folders()
}

dependency "vpc" {
  config_path = "../vpc"
  
  mock_outputs = {
    network_id = "projects/awanmasterpiece-prd/global/networks/awanmasterpiece-prd-vpc"
  }
}

locals {
  environment = "prd"
}

terraform {
  source = "${get_parent_terragrunt_dir()}/modules//memorystore"
}

inputs = {
  instance_name     = "awanmasterpiece-prd-redis"
  region           = "asia-southeast2"
  tier             = "STANDARD_HA"
  memory_size_gb   = 5
  redis_version    = "REDIS_6_X"
  
  authorized_network = dependency.vpc.outputs.network_id
  connect_mode      = "PRIVATE_SERVICE_ACCESS"
  
  auth_enabled            = true
  transit_encryption_mode = "SERVER_AUTHENTICATION"
  
  replica_count      = 2
  read_replicas_mode = "READ_REPLICAS_ENABLED"
  
  maintenance_window = {
    day  = "SUNDAY"  # Sunday
    hour = 2  # 2 AM
  }
  
  user_labels = {
    environment = local.environment
    managed_by  = "terragrunt"
    purpose     = "cache"
  }
}
