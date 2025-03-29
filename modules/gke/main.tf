/**
 * # GKE Module
 * 
 * Module untuk membuat dan mengelola Google Kubernetes Engine (GKE) cluster
 * dengan konfigurasi berdasarkan environment (dev, stg, prd)
 */

resource "google_container_cluster" "primary" {
  name     = "${var.cluster_name_prefix}-${var.environment}"
  location = var.regional ? var.region : "${var.region}-${var.cluster_zone_suffix}"
  project  = var.project_id

  # Jika regional, gunakan semua zone, jika zonal gunakan zona spesifik
  node_locations = var.regional ? null : null

  # Kita menggunakan separately managed node pools
  remove_default_node_pool = true
  initial_node_count       = 1

  # Konfigurasi networking
  network    = var.network_name
  subnetwork = var.subnet_name

  # Konfigurasi private cluster
  private_cluster_config {
    enable_private_nodes    = var.cluster_configs[var.environment].private_cluster
    enable_private_endpoint = var.cluster_configs[var.environment].private_endpoint
    master_ipv4_cidr_block  = var.cluster_configs[var.environment].master_ipv4_cidr_block
  }

  # Menghubungkan ke Pod & Service secondary ranges dari VPC subnet
  ip_allocation_policy {
    cluster_secondary_range_name  = "pods"
    services_secondary_range_name = "services"
  }

  # Proteksi network policy
  network_policy {
    enabled  = var.cluster_configs[var.environment].network_policy_enabled
    provider = var.cluster_configs[var.environment].network_policy_provider
  }
  
  # Aktifkan workload identity jika diperlukan
  workload_identity_config {
    workload_pool = var.cluster_configs[var.environment].workload_identity_enabled ? "${var.project_id}.svc.id.goog" : null
  }
  
  # Konfigurasi enkripsi database (etcd) dengan CMEK
  database_encryption {
    state    = var.database_encryption_key_name != "" ? "ENCRYPTED" : "DECRYPTED"
    key_name = var.database_encryption_key_name
  }

  # Konfigurasi keamanan
  master_authorized_networks_config {
    dynamic "cidr_blocks" {
      for_each = var.master_authorized_networks
      content {
        cidr_block   = cidr_blocks.value.cidr_block
        display_name = cidr_blocks.value.display_name
      }
    }
  }

  # Monitoring dan logging
  logging_service    = var.cluster_configs[var.environment].logging_service
  monitoring_service = var.cluster_configs[var.environment].monitoring_service

  # Mengijinkan auto-upgrade dan auto-repair
  maintenance_policy {
    daily_maintenance_window {
      start_time = "03:00"
    }
  }
  
  # Labels
  resource_labels = {
    environment = var.environment
    managed_by  = "terraform"
  }
}

# Node Pools
resource "google_container_node_pool" "primary_nodes" {
  for_each = var.node_pools[var.environment]
  
  name       = each.key
  location   = google_container_cluster.primary.location
  cluster    = google_container_cluster.primary.name
  node_count = each.value.node_count
  project    = var.project_id

  node_config {
    preemptible  = each.value.preemptible
    machine_type = each.value.machine_type
    disk_size_gb = each.value.disk_size_gb
    disk_type    = each.value.disk_type
    
    # Google recommends custom service accounts with minimal permissions
    service_account = var.service_account
    oauth_scopes    = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
    
    # Labels untuk nodes
    labels = {
      env            = var.environment
      pool           = each.key
    }
    
    # Taints jika diperlukan
    dynamic "taint" {
      for_each = each.value.taints
      content {
        key    = taint.value.key
        value  = taint.value.value
        effect = taint.value.effect
      }
    }
  }

  # Auto-scaling jika enabled
  dynamic "autoscaling" {
    for_each = each.value.enable_autoscaling ? [1] : []
    content {
      min_node_count = each.value.min_node_count
      max_node_count = each.value.max_node_count
    }
  }

  # Auto-upgrade dan auto-repair
  management {
    auto_repair  = each.value.auto_repair
    auto_upgrade = each.value.auto_upgrade
  }
}
