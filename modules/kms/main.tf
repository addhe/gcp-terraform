/**
 * # KMS Module
 * 
 * Module untuk membuat dan mengelola Google KMS Key Ring dan Crypto Keys
 * untuk digunakan dengan CMEK (Customer-Managed Encryption Keys)
 */

resource "google_kms_key_ring" "key_ring" {
  name     = "${var.key_ring_prefix}-${var.environment}-2"
  location = var.region
  project  = var.project_id
}

resource "google_kms_crypto_key" "crypto_keys" {
  for_each = toset(var.crypto_key_names)
  
  name            = "${each.value}-${var.environment}-2"
  key_ring        = google_kms_key_ring.key_ring.id
  rotation_period = var.rotation_period
  
  # Menggunakan purpose ENCRYPT_DECRYPT untuk CMEK
  purpose = "ENCRYPT_DECRYPT"
  
  # Versi otomatis 
  version_template {
    algorithm        = var.algorithm
    protection_level = var.protection_level
  }
  
  # Mencegah penghapusan yang tidak disengaja
  destroy_scheduled_duration = var.crypto_key_destroy_scheduled_duration
  
  # Labels
  labels = {
    environment = var.environment
    managed_by  = "terraform"
    purpose     = "cmek"
  }
}

# Memberikan izin Service Agent GKE untuk menggunakan CMEK
resource "google_kms_crypto_key_iam_member" "gke_encrypt_decrypt" {
  for_each = {
    for idx, key in var.crypto_key_names : idx => key
    if var.enable_gke_encryption
  }
  
  crypto_key_id = google_kms_crypto_key.crypto_keys[each.value].id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:service-${var.project_number}@container-engine-robot.iam.gserviceaccount.com"
}

# Memberikan izin Compute Service Agent untuk menggunakan CMEK
resource "google_kms_crypto_key_iam_member" "compute_encrypt_decrypt" {
  for_each = {
    for idx, key in var.crypto_key_names : idx => key
    if var.enable_compute_encryption
  }
  
  crypto_key_id = google_kms_crypto_key.crypto_keys[each.value].id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:service-${var.project_number}@compute-system.iam.gserviceaccount.com"
}
