/**
 * Bootstrap Terraform State Bucket
 * 
 * File ini membuat bucket GCS yang akan digunakan untuk menyimpan state Terraform/Terragrunt.
 * Bucket ini perlu dibuat sebelum kita dapat menggunakan remote state.
 */

terraform {
  required_version = ">= 1.0.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.80.0"
    }
  }
  
  # Gunakan local state untuk bootstrap
  backend "local" {
    path = "terraform.tfstate"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# Aktifkan API yang diperlukan
resource "google_project_service" "storage_api" {
  project = var.project_id
  service = "storage.googleapis.com"
  
  disable_dependent_services = false
  disable_on_destroy         = false
}

# Buat bucket untuk menyimpan state
resource "google_storage_bucket" "terraform_state" {
  name          = "${var.project_id}-terraform-state"
  project       = var.project_id
  location      = var.region
  force_destroy = false
  
  # Gunakan Standard storage class
  storage_class = "STANDARD"
  
  # Aktifkan versioning untuk melindungi state
  versioning {
    enabled = true
  }
  
  # Enkripsi default
  encryption {
    default_kms_key_name = ""
  }
  
  # Atur lifecycle untuk mencegah penghapusan yang tidak disengaja
  lifecycle {
    prevent_destroy = true
  }
  
  # Uniform bucket-level access
  uniform_bucket_level_access = true
  
  # Atur aturan retensi untuk mencegah penghapusan objek
  retention_policy {
    is_locked        = false
    retention_period = 864000 # 10 hari dalam detik
  }
  
  depends_on = [google_project_service.storage_api]
}

# Buat IAM binding untuk mengatur akses ke bucket
resource "google_storage_bucket_iam_binding" "terraform_state_admin" {
  bucket = google_storage_bucket.terraform_state.name
  role   = "roles/storage.admin"
  
  members = var.admin_members
  
  depends_on = [google_storage_bucket.terraform_state]
}

# Buat IAM binding untuk akses read-only
resource "google_storage_bucket_iam_binding" "terraform_state_viewer" {
  bucket = google_storage_bucket.terraform_state.name
  role   = "roles/storage.objectViewer"
  
  members = var.viewer_members
  
  depends_on = [google_storage_bucket.terraform_state]
}
