/**
 * # Google Cloud IAM Module
 *
 * Modul ini mengatur IAM permissions untuk berbagai service di GCP
 */

# IAM binding untuk KMS Crypto Key
resource "google_kms_crypto_key_iam_binding" "crypto_key" {
  crypto_key_id = var.kms_key_id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  members       = var.service_accounts
}

# IAM binding untuk KMS Key Ring
resource "google_kms_key_ring_iam_binding" "key_ring" {
  key_ring_id = var.kms_key_ring_id
  role        = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  members     = var.service_accounts
}
