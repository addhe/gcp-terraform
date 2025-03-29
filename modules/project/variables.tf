variable "project_id" {
  description = "The ID of the project based on environment"
  type        = map(string)
  default = {
    dev = "awanmasterpiece-dev"
    stg = "awanmasterpiece-stg"
    prd = "awanmasterpiece-prd"
  }
  
  # Validation will be done at the resource level
}

variable "project_name" {
  description = "The name of the project based on environment"
  type        = map(string)
  default = {
    dev = "Awan Masterpiece Dev"
    stg = "Awan Masterpiece Staging"
    prd = "Awan Masterpiece Production"
  }
}

variable "labels" {
  description = "Labels to apply to the project"
  type        = map(string)
  default     = {}
}

variable "billing_account" {
  description = "The ID of the billing account to associate with the project"
  type        = string
}

variable "organization_id" {
  description = "The ID of the organization"
  type        = string
  default     = ""
}

variable "folder_id" {
  description = "The ID of the folder to create the project in"
  type        = string
  default     = ""
}

variable "services" {
  description = "List of services to enable on the project"
  type        = list(string)
  default     = []
}

variable "environment" {
  description = "Environment (dev, stg, prd)"
  type        = string
  default     = "dev"
  
  validation {
    condition     = contains(["dev", "stg", "prd"], var.environment)
    error_message = "Environment must be one of: dev, stg, prd."
  }
}



variable "resource_limits" {
  description = "Resource limits based on environment"
  type = object({
    cpu_limit    = number
    memory_limit = number
    disk_size_gb = number
  })
  default = null
}

variable "environment_configs" {
  description = "Configuration maps for different environments"
  type = map(object({
    project_prefix = string
    resource_limits = object({
      cpu_limit    = number
      memory_limit = number
      disk_size_gb = number
    })
    auto_create_network = bool
    allowed_apis        = list(string)
  }))
  
  default = {
    dev = {
      project_prefix     = "dev"
      resource_limits    = {
        cpu_limit    = 4
        memory_limit = 16
        disk_size_gb = 100
      }
      auto_create_network = true
      allowed_apis        = ["compute.googleapis.com", "container.googleapis.com", "iam.googleapis.com"]
    },
    stg = {
      project_prefix     = "stg"
      resource_limits    = {
        cpu_limit    = 8
        memory_limit = 32
        disk_size_gb = 200
      }
      auto_create_network = false
      allowed_apis        = ["compute.googleapis.com", "container.googleapis.com", "iam.googleapis.com", "monitoring.googleapis.com"]
    },
    prd = {
      project_prefix     = "prd"
      resource_limits    = {
        cpu_limit    = 16
        memory_limit = 64
        disk_size_gb = 500
      }
      auto_create_network = false
      allowed_apis        = ["compute.googleapis.com", "container.googleapis.com", "iam.googleapis.com", "monitoring.googleapis.com", "logging.googleapis.com", "cloudkms.googleapis.com"]
    }
  }
}
