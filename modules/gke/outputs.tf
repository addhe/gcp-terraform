/**
 * # GKE Module Outputs
 * 
 * Output variabel dari modul Google Kubernetes Engine (GKE)
 */

output "cluster_name" {
  description = "Nama dari cluster GKE"
  value       = google_container_cluster.primary.name
}

output "cluster_id" {
  description = "Unique ID dari cluster GKE"
  value       = google_container_cluster.primary.id
}

output "cluster_endpoint" {
  description = "Endpoint untuk Kubernetes master"
  value       = google_container_cluster.primary.endpoint
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "CA certificate yang digunakan untuk mengautentikasi ke cluster"
  value       = base64decode(google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
  sensitive   = true
}

output "node_pools" {
  description = "List dari node pools yang dibuat"
  value       = [for np in google_container_node_pool.primary_nodes : np.name]
}

output "cluster_location" {
  description = "Lokasi dari cluster (region atau zone)"
  value       = google_container_cluster.primary.location
}

output "kubernetes_version" {
  description = "Versi Kubernetes yang digunakan"
  value       = google_container_cluster.primary.master_version
}

output "service_account" {
  description = "Service account yang digunakan GKE nodes"
  value       = var.service_account
}
