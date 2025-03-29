variable "project_id" {
  description = "The ID of the project where the VPC will be created"
  type        = string
}

variable "network_name" {
  description = "The name of the VPC network"
  type        = string
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
  description = "List of firewall rules to create"
  type = list(object({
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
  }))
  default = []
}
