variable "project_id" {
  description = "The ID of the project where resources will be created"
  type        = string
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

variable "region" {
  description = "The default region to use for resources"
  type        = string
  default     = "asia-southeast1"
}

variable "project_name" {
  description = "The name of the project"
  type        = string
}

variable "project_services" {
  description = "List of services to enable on the project"
  type        = list(string)
  default = [
    "compute.googleapis.com",
    "iam.googleapis.com",
    "container.googleapis.com",
    "servicenetworking.googleapis.com",
    "cloudresourcemanager.googleapis.com"
  ]
}
