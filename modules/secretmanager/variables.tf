variable "environment" {
  description = "Environment (dev/stg/prd)"
  type        = string
}

variable "secrets" {
  description = "Map of secrets to create"
  type = map(object({
    secret_id     = string
    secret_data   = string
    labels        = map(string)
    replication   = object({
      automatic = bool
      user_managed = optional(object({
        replicas = list(object({
          location = string
          customer_managed_encryption = optional(object({
            kms_key_name = string
          }))
        }))
      }))
    })
  }))
}

variable "service_accounts" {
  description = "List of service accounts that need access to secrets"
  type = list(object({
    email     = string
    role      = string
    secrets   = list(string)  # List of secret IDs this SA needs access to
  }))
  default = []
}
