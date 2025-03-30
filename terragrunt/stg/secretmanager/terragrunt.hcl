include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/secretmanager"
}

locals {
  environment = "stg"
}

inputs = {
  environment = local.environment

  secrets = {
    mysql_app = {
      secret_id   = "mysql-app-password"
      secret_data = "dummy-password-to-be-updated-later"  # Will be updated later
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
      secret_data = "dummy-auth-to-be-updated-later"  # Will be updated later
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
