include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/secretmanager"
}

dependency "cloudsql" {
  config_path = "../cloudsql"
  
  mock_outputs = {
    db_instance_name = "mock-db-instance"
    user_password    = "mock-password"
  }
}

dependency "redis" {
  config_path = "../redis"
  
  mock_outputs = {
    auth_string = "mock-auth-string"
  }
}

locals {
  environment = "stg"
}

inputs = {
  environment = local.environment

  secrets = {
    mysql_app = {
      secret_id   = "mysql-app-password"
      secret_data = dependency.cloudsql.outputs.user_password
      labels = {
        app     = "mysql"
        purpose = "app-database"
      }
      replication = {
        automatic = true  # For staging, we can use automatic replication
      }
    }
    
    redis_auth = {
      secret_id   = "redis-auth-string"
      secret_data = dependency.redis.outputs.auth_string
      labels = {
        app     = "redis"
        purpose = "cache"
      }
      replication = {
        automatic = true
      }
    }
  }

  service_accounts = [
    {
      email   = "cloudsql-sa@awanmasterpiece-stg.iam.gserviceaccount.com"
      role    = "roles/secretmanager.secretAccessor"
      secrets = ["mysql-app-password"]
    }
  ]
}
