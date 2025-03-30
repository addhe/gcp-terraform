resource "random_id" "db_name_suffix" {
  byte_length = 4
}

resource "random_password" "user_password" {
  count   = var.user_password == "" ? 1 : 0
  length  = 16
  special = true
}

resource "google_sql_database_instance" "instance" {
  name                = "${var.instance_name}-${random_id.db_name_suffix.hex}"
  region              = var.region
  database_version    = var.database_version
  deletion_protection = var.deletion_protection

  settings {
    tier              = var.tier
    availability_type = var.availability_type
    disk_type         = var.disk_type
    disk_size         = var.disk_size
    disk_autoresize   = true

    backup_configuration {
      enabled                        = var.backup_configuration.enabled
      binary_log_enabled            = var.backup_configuration.binary_log_enabled
      start_time                    = var.backup_configuration.start_time
      location                      = var.backup_configuration.location
      transaction_log_retention_days = var.backup_configuration.transaction_log_retention_days
      backup_retention_settings {
        retained_backups = var.backup_configuration.retained_backups
        retention_unit   = var.backup_configuration.retention_unit
      }
    }

    maintenance_window {
      day          = var.maintenance_window.day
      hour         = var.maintenance_window.hour
      update_track = var.maintenance_window.update_track
    }

    ip_configuration {
      ipv4_enabled        = var.ip_configuration.ipv4_enabled
      private_network     = var.ip_configuration.private_network
      require_ssl         = var.ip_configuration.require_ssl
      allocated_ip_range  = var.ip_configuration.allocated_ip_range
      dynamic "authorized_networks" {
        for_each = var.ip_configuration.authorized_networks
        content {
          name  = authorized_networks.value["name"]
          value = authorized_networks.value["value"]
        }
      }
    }

    dynamic "database_flags" {
      for_each = var.database_flags
      content {
        name  = database_flags.value["name"]
        value = database_flags.value["value"]
      }
    }

    user_labels = var.user_labels
  }

  encryption_key_name = var.encryption_key_name
}

resource "google_sql_database" "database" {
  name     = var.database_name
  instance = google_sql_database_instance.instance.name
}

resource "google_sql_user" "user" {
  name     = var.user_name
  instance = google_sql_database_instance.instance.name
  password = var.user_password == "" ? random_password.user_password[0].result : var.user_password
}
