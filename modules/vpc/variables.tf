variable "project_id" {
  description = "The ID of the project where the VPC will be created"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, stg, prd) passed from terragrunt"
  type        = string
  # Default tidak diperlukan, karena Terragrunt akan selalu mengirimkan nilai
}

variable "network_name" {
  description = "The name of the VPC network"
  type        = string
}

variable "vpc_configs" {
  description = "Map of VPC configurations based on environment"
  type = map(object({
    subnet_cidr_blocks = map(string)
    region            = string
  }))
  default = {
    dev = {
      subnet_cidr_blocks = {
        subnet-01 = "10.10.0.0/24"
        subnet-02 = "10.10.1.0/24"
      }
      region = "asia-southeast2"
    }
    stg = {
      subnet_cidr_blocks = {
        subnet-01 = "10.20.0.0/24"
        subnet-02 = "10.20.1.0/24"
      }
      region = "asia-southeast2"
    }
    prd = {
      subnet_cidr_blocks = {
        subnet-01 = "10.30.0.0/24"
        subnet-02 = "10.30.1.0/24"
      }
      region = "asia-southeast2"
    }
  }
}

variable "subnet_configs" {
  description = "Map of subnet configurations based on environment"
  type = map(list(object({
    name          = string
    ip_cidr_range = string
    region        = string
    secondary_ip_ranges = list(object({
      range_name    = string
      ip_cidr_range = string
    }))
  })))
  default = {
    dev = [
      {
        name          = "subnet-01"
        ip_cidr_range = "10.10.0.0/24"
        region        = "asia-southeast2"
        secondary_ip_ranges = [
          {
            range_name    = "pods"
            ip_cidr_range = "10.1.0.0/16"
          },
          {
            range_name    = "services"
            ip_cidr_range = "10.2.0.0/20"
          }
        ]
      },
      {
        name          = "subnet-02"
        ip_cidr_range = "10.10.1.0/24"
        region        = "asia-southeast2"
        secondary_ip_ranges = []
      }
    ],
    stg = [
      {
        name          = "subnet-01"
        ip_cidr_range = "10.20.0.0/24"
        region        = "asia-southeast2"
        secondary_ip_ranges = [
          {
            range_name    = "pods"
            ip_cidr_range = "10.1.0.0/16"
          },
          {
            range_name    = "services"
            ip_cidr_range = "10.2.0.0/20"
          }
        ]
      },
      {
        name          = "subnet-02"
        ip_cidr_range = "10.20.1.0/24"
        region        = "asia-southeast2"
        secondary_ip_ranges = []
      }
    ],
    prd = [
      {
        name          = "subnet-01"
        ip_cidr_range = "10.30.0.0/24"
        region        = "asia-southeast2"
        secondary_ip_ranges = [
          {
            range_name    = "pods"
            ip_cidr_range = "10.1.0.0/16"
          },
          {
            range_name    = "services"
            ip_cidr_range = "10.2.0.0/20"
          }
        ]
      },
      {
        name          = "subnet-02"
        ip_cidr_range = "10.30.1.0/24"
        region        = "asia-southeast2"
        secondary_ip_ranges = []
      }
    ]
  }
}

variable "description" {
  description = "Description of the VPC network"
  type        = string
  default     = "VPC Network created by Terraform"
}

variable "auto_create_subnetworks" {
  description = "Whether to create default subnets or not"
  type        = bool
  default     = false
}

variable "routing_mode" {
  description = "The network routing mode (REGIONAL or GLOBAL)"
  type        = string
  default     = "GLOBAL"
}

variable "delete_default_routes_on_create" {
  description = "Whether to delete the default routes when the network is created"
  type        = bool
  default     = false
}

variable "subnets" {
  description = "List of subnets to create in the VPC"
  type = list(object({
    name          = string
    ip_cidr_range = string
    region        = string
    secondary_ip_ranges = optional(list(object({
      range_name    = string
      ip_cidr_range = string
    })), [])
    private_ip_google_access = optional(bool, true)
    purpose                  = optional(string, "PRIVATE")
    role                     = optional(string, null)
  }))
  default = []
}

variable "firewall_rules" {
  description = "Map of firewall rules to create based on environment"
  type = map(list(object({
    name        = string
    description = optional(string, "")
    direction   = optional(string, "INGRESS")
    priority    = optional(number, 1000)
    ranges      = list(string)
    allow = optional(list(object({
      protocol = string
      ports    = optional(list(string), [])
    })), [])
    deny = optional(list(object({
      protocol = string
      ports    = optional(list(string), [])
    })), [])
    source_tags             = optional(list(string), [])
    source_service_accounts = optional(list(string), [])
    target_tags             = optional(list(string), [])
    target_service_accounts = optional(list(string), [])
  })))
  default = {
    dev = [
      {
        name        = "allow-internal"
        description = "Allow internal traffic"
        ranges      = ["10.10.0.0/24", "10.10.1.0/24"]
        allow = [
          {
            protocol = "tcp"
            ports    = ["0-65535"]
          },
          {
            protocol = "udp"
            ports    = ["0-65535"]
          },
          {
            protocol = "icmp"
          }
        ]
      },
      {
        name        = "allow-ssh"
        description = "Allow SSH from IAP"
        ranges      = ["35.235.240.0/20"] # Google Cloud IAP IP range
        allow = [
          {
            protocol = "tcp"
            ports    = ["22"]
          }
        ]
      }
    ],
    stg = [
      {
        name        = "allow-internal"
        description = "Allow internal traffic"
        ranges      = ["10.20.0.0/24", "10.20.1.0/24"]
        allow = [
          {
            protocol = "tcp"
            ports    = ["0-65535"]
          },
          {
            protocol = "udp"
            ports    = ["0-65535"]
          },
          {
            protocol = "icmp"
          }
        ]
      },
      {
        name        = "allow-ssh"
        description = "Allow SSH from IAP"
        ranges      = ["35.235.240.0/20"] # Google Cloud IAP IP range
        allow = [
          {
            protocol = "tcp"
            ports    = ["22"]
          }
        ]
      }
    ],
    prd = [
      {
        name        = "allow-internal"
        description = "Allow internal traffic"
        ranges      = ["10.30.0.0/24", "10.30.1.0/24"]
        allow = [
          {
            protocol = "tcp"
            ports    = ["0-65535"]
          },
          {
            protocol = "udp"
            ports    = ["0-65535"]
          },
          {
            protocol = "icmp"
          }
        ]
      },
      {
        name        = "allow-ssh"
        description = "Allow SSH from IAP"
        ranges      = ["35.235.240.0/20"] # Google Cloud IAP IP range
        allow = [
          {
            protocol = "tcp"
            ports    = ["22"]
          }
        ]
      }
    ]
  }
}
