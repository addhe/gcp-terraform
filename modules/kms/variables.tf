/**
 * # KMS Module Variables
 * 
 * Konfigurasi variabel untuk modul Google KMS
 */

variable "environment" {
  description = "Environment yang digunakan (dev, stg, prd)"
  type        = string
}

variable "project_id" {
  description = "ID dari project GCP"
  type        = string
}

variable "project_number" {
  description = "Nomor project GCP, digunakan untuk service account"
  type        = string
}

variable "region" {
  description = "Region untuk key ring"
  type        = string
  default     = "asia-southeast2" # Jakarta
}

variable "key_ring_prefix" {
  description = "Prefix untuk nama key ring"
  type        = string
  default     = "awanmasterpiece"
}

variable "crypto_key_names" {
  description = "List nama crypto keys yang akan dibuat"
  type        = list(string)
  default     = ["gke-etcd", "gke-app-secrets", "compute-disk"]
}

variable "rotation_period" {
  description = "Periode rotasi untuk crypto keys (dalam detik). Default 90 hari"
  type        = string
  default     = "7776000s" # 90 days
}

variable "algorithm" {
  description = "Algoritma enkripsi yang digunakan"
  type        = string
  default     = "GOOGLE_SYMMETRIC_ENCRYPTION"
}

variable "protection_level" {
  description = "Tingkat perlindungan untuk keys"
  type        = string
  default     = "SOFTWARE" # Alternatif: HSM untuk level keamanan lebih tinggi
}

variable "crypto_key_destroy_scheduled_duration" {
  description = "Periode penundaan sebelum menghancurkan crypto key (dalam detik)"
  type        = string
  default     = "86400s" # 24 hours
}

variable "enable_gke_encryption" {
  description = "Apakah mengaktifkan CMEK untuk GKE"
  type        = bool
  default     = true
}

variable "enable_compute_encryption" {
  description = "Apakah mengaktifkan CMEK untuk Compute disks"
  type        = bool
  default     = true
}
