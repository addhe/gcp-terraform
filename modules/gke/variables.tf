/**
 * # GKE Module Variables
 * 
 * Konfigurasi variabel untuk modul Google Kubernetes Engine (GKE)
 */

variable "environment" {
  description = "Environment yang digunakan (dev, stg, prd)"
  type        = string
}

variable "project_id" {
  description = "ID dari project GCP"
  type        = string
}

variable "region" {
  description = "Region untuk cluster GKE"
  type        = string
  default     = "asia-southeast2" # Jakarta
}

variable "cluster_zone_suffix" {
  description = "Zone suffix untuk cluster GKE jika tidak regional (a, b, atau c)"
  type        = string
  default     = "a"
}

variable "regional" {
  description = "Apakah cluster bersifat regional (true) atau zonal (false)"
  type        = bool
  default     = true
}

variable "cluster_name_prefix" {
  description = "Prefix untuk nama cluster"
  type        = string
  default     = "awanmasterpiece"
}

variable "network_name" {
  description = "Nama VPC network untuk cluster GKE"
  type        = string
}

variable "subnet_name" {
  description = "Nama subnet untuk cluster GKE"
  type        = string
}

variable "service_account" {
  description = "Service account untuk GKE nodes"
  type        = string
  default     = ""
}

variable "master_authorized_networks" {
  description = "List CIDR blocks yang diizinkan untuk mengakses Kubernetes master"
  type = list(object({
    cidr_block   = string
    display_name = string
  }))
  default = []
}

variable "database_encryption_key_name" {
  description = "Nama resource dari KMS key yang digunakan untuk enkripsi database cluster (etcd). Format: projects/<project-id>/locations/<region>/keyRings/<keyring-name>/cryptoKeys/<key-name>"
  type        = string
  default     = ""
}

variable "cluster_configs" {
  description = "Konfigurasi cluster berdasarkan environment"
  type = map(object({
    private_cluster       = bool
    private_endpoint      = bool
    master_ipv4_cidr_block = string
    pod_cidr_block        = string
    service_cidr_block    = string
    network_policy_enabled = bool
    network_policy_provider = string
    workload_identity_enabled = bool
    logging_service       = string
    monitoring_service    = string
  }))
  default = {
    dev = {
      private_cluster        = true
      private_endpoint       = false
      master_ipv4_cidr_block = "172.16.0.0/28"
      pod_cidr_block         = "10.100.0.0/16"
      service_cidr_block     = "10.101.0.0/16"
      network_policy_enabled = true
      network_policy_provider = "CALICO"
      workload_identity_enabled = true
      logging_service        = "logging.googleapis.com/kubernetes"
      monitoring_service     = "monitoring.googleapis.com/kubernetes"
    },
    stg = {
      private_cluster        = true
      private_endpoint       = false
      master_ipv4_cidr_block = "172.16.0.16/28"
      pod_cidr_block         = "10.200.0.0/16"
      service_cidr_block     = "10.201.0.0/16"
      network_policy_enabled = true
      network_policy_provider = "CALICO"
      workload_identity_enabled = true
      logging_service        = "logging.googleapis.com/kubernetes"
      monitoring_service     = "monitoring.googleapis.com/kubernetes"
    },
    prd = {
      private_cluster        = true
      private_endpoint       = false
      master_ipv4_cidr_block = "172.16.0.32/28"
      pod_cidr_block         = "10.1.0.0/16" # Menggunakan Secondary Range dari VPC
      service_cidr_block     = "10.2.0.0/20" # Menggunakan Secondary Range dari VPC
      network_policy_enabled = true
      network_policy_provider = "CALICO"
      workload_identity_enabled = true
      logging_service        = "logging.googleapis.com/kubernetes"
      monitoring_service     = "monitoring.googleapis.com/kubernetes"
    }
  }
}

variable "node_pools" {
  description = "Konfigurasi node pools berdasarkan environment"
  type = map(map(object({
    node_count        = number
    machine_type      = string
    disk_size_gb      = number
    disk_type         = string
    preemptible       = bool
    enable_autoscaling = bool
    min_node_count    = optional(number)
    max_node_count    = optional(number)
    auto_repair       = bool
    auto_upgrade      = bool
    taints            = list(object({
      key             = string
      value           = string
      effect          = string
    }))
  })))
  default = {
    dev = {
      default = {
        node_count        = 1
        machine_type      = "e2-standard-2"
        disk_size_gb      = 100
        disk_type         = "pd-standard"
        preemptible       = true
        enable_autoscaling = true
        min_node_count    = 1
        max_node_count    = 3
        auto_repair       = true
        auto_upgrade      = true
        taints            = []
      }
    },
    stg = {
      default = {
        node_count        = 2
        machine_type      = "e2-standard-2"
        disk_size_gb      = 100
        disk_type         = "pd-standard"
        preemptible       = true
        enable_autoscaling = true
        min_node_count    = 2
        max_node_count    = 4
        auto_repair       = true
        auto_upgrade      = true
        taints            = []
      }
    },
    prd = {
      default = {
        node_count        = 1
        machine_type      = "e2-standard-2"  # 2 vCPUs
        disk_size_gb      = 20
        disk_type         = "pd-standard"
        preemptible       = false
        enable_autoscaling = true
        min_node_count    = 1
        max_node_count    = 3
        auto_repair       = true
        auto_upgrade      = true
        taints            = []
      },
      workloads = {
        node_count        = 1
        machine_type      = "e2-small"  # 2 vCPUs
        disk_size_gb      = 20
        disk_type         = "pd-standard"
        preemptible       = false
        enable_autoscaling = true
        min_node_count    = 1
        max_node_count    = 3
        auto_repair       = true
        auto_upgrade      = true
        taints            = []
      }
    }
  }
}
