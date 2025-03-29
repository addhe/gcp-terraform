variable "instance_name" {
  description = "The name of the Cloud SQL instance"
  type        = string
}

variable "database_version" {
  description = "The MySQL version to use"
  type        = string
  default     = "MYSQL_8_0"
}

variable "region" {
  description = "The region of the Cloud SQL instance"
  type        = string
  default     = "asia-southeast2"
}

variable "tier" {
  description = "The machine type to use"
  type        = string
  default     = "db-f1-micro"
}

variable "disk_size" {
  description = "The size of data disk, in GB"
  type        = number
  default     = 10
}

variable "disk_type" {
  description = "The type of data disk"
  type        = string
  default     = "PD_SSD"
}

variable "availability_type" {
  description = "The availability type for the master instance"
  type        = string
  default     = "REGIONAL"
}

variable "backup_configuration" {
  description = "The backup configuration block"
  type = object({
    enabled                        = bool
    binary_log_enabled            = bool
    start_time                    = string
    location                      = string
    transaction_log_retention_days = number
    retained_backups              = number
    retention_unit                = string
  })
  default = {
    enabled                        = true
    binary_log_enabled            = true
    start_time                    = "02:00"
    location                      = "asia-southeast2"
    transaction_log_retention_days = 7
    retained_backups              = 7
    retention_unit                = "COUNT"
  }
}

variable "database_flags" {
  description = "List of Cloud SQL flags that are applied to the database server"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "maintenance_window" {
  description = "The maintenance window for this instance"
  type = object({
    day          = number
    hour         = number
    update_track = string
  })
  default = {
    day          = 7  # Sunday
    hour         = 3  # 3 AM
    update_track = "stable"
  }
}

variable "ip_configuration" {
  description = "The ip configuration for the master instances"
  type = object({
    ipv4_enabled        = bool
    private_network     = string
    require_ssl         = bool
    allocated_ip_range  = string
    authorized_networks = list(map(string))
  })
}

variable "user_labels" {
  description = "Labels to attach to the instance"
  type        = map(string)
  default     = {}
}

variable "deletion_protection" {
  description = "Used to block Terraform from deleting a SQL Instance"
  type        = bool
  default     = true
}

variable "encryption_key_name" {
  description = "The full path to the encryption key used for the CMEK disk encryption"
  type        = string
  default     = null
}

variable "database_name" {
  description = "Name of the default database to create"
  type        = string
}

variable "user_name" {
  description = "The name of the default user"
  type        = string
  default     = "admin"
}

variable "user_password" {
  description = "The password for the default user. If not set, a random one will be generated and available in the generated_user_password output variable"
  type        = string
  default     = ""
  sensitive   = true
}
