variable "instance_name" {
  description = "The name of the Redis instance"
  type        = string
}

variable "region" {
  description = "The region where the Redis instance will be created"
  type        = string
}

variable "tier" {
  description = "The service tier of the instance. Must be one of: BASIC, STANDARD_HA"
  type        = string
  default     = "STANDARD_HA"
}

variable "memory_size_gb" {
  description = "Redis memory size in GiB"
  type        = number
  default     = 5
}

variable "redis_version" {
  description = "The version of Redis software"
  type        = string
  default     = "REDIS_6_X"
}

variable "authorized_network" {
  description = "The full name of the Google Compute Engine network to which the instance is connected"
  type        = string
}

variable "connect_mode" {
  description = "The connection mode of the Redis instance. Must be one of: DIRECT_PEERING, PRIVATE_SERVICE_ACCESS"
  type        = string
  default     = "PRIVATE_SERVICE_ACCESS"
}

variable "auth_enabled" {
  description = "Indicates whether OSS Redis AUTH is enabled"
  type        = bool
  default     = true
}

variable "transit_encryption_mode" {
  description = "The TLS mode of the Redis instance. Must be one of: DISABLED, SERVER_AUTHENTICATION"
  type        = string
  default     = "SERVER_AUTHENTICATION"
}

variable "replica_count" {
  description = "The number of replica nodes. Only applicable for STANDARD_HA tier"
  type        = number
  default     = 2
}

variable "read_replicas_mode" {
  description = "Read replicas mode. Must be one of: READ_REPLICAS_DISABLED, READ_REPLICAS_ENABLED"
  type        = string
  default     = "READ_REPLICAS_ENABLED"
}

variable "maintenance_window" {
  description = "Maintenance window for this instance"
  type = object({
    day          = string
    hour         = number
  })
  default = {
    day          = "SUNDAY"  # Sunday
    hour         = 2  # 2 AM
  }
}

variable "user_labels" {
  description = "Resource labels to represent user-provided metadata"
  type        = map(string)
  default     = {}
}