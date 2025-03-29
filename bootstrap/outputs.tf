/**
 * Outputs for Bootstrap Terraform State Bucket
 */

output "state_bucket_name" {
  description = "Nama bucket GCS yang dibuat untuk menyimpan state Terraform"
  value       = google_storage_bucket.terraform_state.name
}

output "state_bucket_url" {
  description = "URL bucket GCS yang dibuat untuk menyimpan state Terraform"
  value       = google_storage_bucket.terraform_state.url
}

output "state_bucket_self_link" {
  description = "Self link bucket GCS yang dibuat untuk menyimpan state Terraform"
  value       = google_storage_bucket.terraform_state.self_link
}
