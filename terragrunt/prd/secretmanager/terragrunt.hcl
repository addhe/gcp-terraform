include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/secretmanager"
}

locals {
  environment = "prd"
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
        automatic = true
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
      email   = "cloudsql-sa@awanmasterpiece-prd.iam.gserviceaccount.com"
      role    = "roles/secretmanager.secretAccessor"
      secrets = ["mysql-app-password"]
    }
  ]
}
