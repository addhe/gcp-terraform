variable "project_id" {
  description = "The ID of the project"
  type        = string
}

variable "project_name" {
  description = "The name of the project"
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

variable "services" {
  description = "List of services to enable on the project"
  type        = list(string)
  default     = []
}

variable "labels" {
  description = "Labels to apply to the project"
  type        = map(string)
  default     = {}
}
