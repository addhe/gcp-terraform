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
  environment = "dev"
}

inputs = {
  instance_name = "awanmasterpiece-dev-redis"
  region        = "asia-southeast2"
  
  tier           = "BASIC"  # Using BASIC tier for dev to save costs
  memory_size_gb = 1        # Smaller memory size for dev
  redis_version  = "REDIS_6_X"
  
  authorized_network = dependency.vpc.outputs.network_id
  connect_mode      = "PRIVATE_SERVICE_ACCESS"
  
  auth_enabled            = true
  transit_encryption_mode = "SERVER_AUTHENTICATION"
  
  replica_count       = 0  # No replicas in dev
  read_replicas_mode = "READ_REPLICAS_DISABLED"
  
  maintenance_window = {
    day  = "SUNDAY"  # Sunday
    hour = 2  # 2 AM
  }
  
  labels = {
    environment = "dev"
    managed_by  = "terragrunt"
    purpose     = "cache"
  }
}
