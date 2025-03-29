/**
 * Variables for Bootstrap Terraform State Bucket
 */

variable "project_id" {
  description = "ID project GCP yang akan digunakan untuk bucket state"
  type        = string
}

variable "region" {
  description = "Region GCP untuk menyimpan bucket state"
  type        = string
  default     = "asia-southeast1"
}

variable "admin_members" {
  description = "List IAM members yang memiliki akses admin ke bucket state"
  type        = list(string)
  default     = ["user:admin@example.com"] # Ganti dengan email admin Anda
}

variable "viewer_members" {
  description = "List IAM members yang memiliki akses read-only ke bucket state"
  type        = list(string)
  default     = [] # Isi dengan email user yang perlu akses read-only
}
