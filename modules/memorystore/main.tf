resource "random_id" "redis_name_suffix" {
  byte_length = 4
}

resource "random_password" "auth_string" {
  length  = 32
  special = true
}

resource "google_redis_instance" "cache" {
  name           = "${var.instance_name}-${random_id.redis_name_suffix.hex}"
  tier           = var.tier
  memory_size_gb = var.memory_size_gb
  region         = var.region
  redis_version  = var.redis_version

  authorized_network = var.authorized_network
  connect_mode      = var.connect_mode

  auth_enabled            = var.auth_enabled
  transit_encryption_mode = var.transit_encryption_mode

  replica_count     = var.tier == "STANDARD_HA" ? var.replica_count : null
  read_replicas_mode = var.tier == "STANDARD_HA" ? var.read_replicas_mode : null

  maintenance_policy {
    weekly_maintenance_window {
      day = var.maintenance_window.day
      start_time {
        hours   = var.maintenance_window.hour
        minutes = 0
        seconds = 0
        nanos   = 0
      }
    }
  }

  labels = var.user_labels

  lifecycle {
    prevent_destroy = true
  }
}