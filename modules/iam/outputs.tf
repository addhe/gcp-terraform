/**
 * # IAM Module Outputs
 *
 * Output dari modul IAM
 */

output "crypto_key_iam_binding_id" {
  description = "ID dari IAM binding untuk crypto key"
  value       = google_kms_crypto_key_iam_binding.crypto_key.id
}

output "key_ring_iam_binding_id" {
  description = "ID dari IAM binding untuk key ring"
  value       = google_kms_key_ring_iam_binding.key_ring.id
}
