/**
 * # IAM Module Variables
 *
 * Definisi variabel untuk modul IAM
 */

variable "kms_key_id" {
  description = "ID dari KMS Crypto Key yang akan diberikan permission"
  type        = string
}

variable "kms_key_ring_id" {
  description = "ID dari KMS Key Ring yang akan diberikan permission"
  type        = string
}

variable "service_accounts" {
  description = "List of service account members yang akan diberikan akses ke KMS key"
  type        = list(string)
}
