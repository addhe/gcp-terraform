/**
 * # KMS Module Outputs
 * 
 * Output variabel dari modul Google KMS
 */

output "key_ring_id" {
  description = "ID dari key ring"
  value       = google_kms_key_ring.key_ring.id
}

output "key_ring_name" {
  description = "Nama dari key ring"
  value       = google_kms_key_ring.key_ring.name
}

output "crypto_key_ids" {
  description = "Map dari crypto key names ke ID-nya"
  value       = { for k, v in google_kms_crypto_key.crypto_keys : k => v.id }
}

# Google KMS tidak ekspos version info di state resource, jadi kita hanya expose name saja
output "crypto_key_names" {
  description = "Map dari crypto key names ke nama lengkap mereka"
  value       = { for k, v in google_kms_crypto_key.crypto_keys : k => v.name }
}

output "gke_crypto_key_id" {
  description = "ID dari crypto key untuk GKE etcd encryption"
  value       = contains(var.crypto_key_names, "gke-etcd") ? google_kms_crypto_key.crypto_keys["gke-etcd"].id : null
}

output "gke_app_secrets_crypto_key_id" {
  description = "ID dari crypto key untuk GKE app secrets"
  value       = contains(var.crypto_key_names, "gke-app-secrets") ? google_kms_crypto_key.crypto_keys["gke-app-secrets"].id : null
}

output "compute_disk_crypto_key_id" {
  description = "ID dari crypto key untuk Compute disk encryption"
  value       = contains(var.crypto_key_names, "compute-disk") ? google_kms_crypto_key.crypto_keys["compute-disk"].id : null
}
