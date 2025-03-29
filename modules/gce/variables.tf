/**
 * # Google Compute Engine Module Variables
 *
 * Definisi variabel untuk modul Google Compute Engine
 */

variable "vm_configs" {
  description = "Konfigurasi VM berdasarkan environment (dev, stg, prd)"
  type = map(object({
    vm_instances = list(object({
      name                  = string
      machine_type          = string
      zone                  = string
      service_account_email = string
      service_account_scopes = list(string)
      boot_disk_image       = string
      boot_disk_size_gb     = number
      boot_disk_type        = string
      network               = string
      subnetwork            = string
      public_ip             = bool
      metadata              = map(string)
      network_tags          = list(string)
      startup_script        = string
      preemptible           = bool
      provisioning_model    = string
      instance_termination_action = string
      spot                  = bool
    }))
    additional_disks = list(object({
      instance_name     = string
      disk_name         = string
      disk_type         = string
      zone              = string
      disk_size_gb      = number
      disk_image        = string
      kms_key_self_link = string
      device_name       = string
      mode              = string
    }))
  }))
  
  default = {
    dev = {
      vm_instances = [
        {
          name                  = "dev-app-vm-1"
          machine_type          = "e2-small"
          zone                  = "asia-southeast2-a"
          service_account_email = ""
          service_account_scopes = [
            "https://www.googleapis.com/auth/cloud-platform"
          ]
          boot_disk_image      = "ubuntu-os-cloud/ubuntu-2204-lts"
          boot_disk_size_gb    = 10
          boot_disk_type       = "pd-standard"
          network              = ""
          subnetwork           = ""
          public_ip            = false
          metadata             = {}
          network_tags         = ["app-server", "dev"]
          startup_script       = ""
          preemptible          = false
          provisioning_model   = "STANDARD"
          instance_termination_action = "DELETE"
          spot                = true
        }
      ],
      additional_disks = [
        {
          instance_name     = "dev-app-vm-1"
          disk_name         = "dev-app-data-disk-1"
          disk_type         = "pd-standard"
          zone              = "asia-southeast2-a"
          disk_size_gb      = 50
          disk_image        = ""
          kms_key_self_link = ""
          device_name       = "data-disk"
          mode              = "READ_WRITE"
        }
      ]
    },
    stg = {
      vm_instances = [
        {
          name                  = "stg-app-vm-1"
          machine_type          = "e2-medium"
          zone                  = "asia-southeast2-a"
          service_account_email = ""
          service_account_scopes = [
            "https://www.googleapis.com/auth/cloud-platform"
          ]
          boot_disk_image      = "ubuntu-os-cloud/ubuntu-2204-lts"
          boot_disk_size_gb    = 10
          boot_disk_type       = "pd-standard"
          network              = ""
          subnetwork           = ""
          public_ip            = false
          metadata             = {}
          network_tags         = ["app-server", "stg"]
          startup_script       = ""
          preemptible          = false
          provisioning_model   = "STANDARD"
          instance_termination_action = "DELETE"
          spot                = true
        }
      ],
      additional_disks = [
        {
          instance_name     = "stg-app-vm-1"
          disk_name         = "stg-app-data-disk-1"
          disk_type         = "pd-standard"
          zone              = "asia-southeast2-a"
          disk_size_gb      = 100
          disk_image        = ""
          kms_key_self_link = ""
          device_name       = "data-disk"
          mode              = "READ_WRITE"
        }
      ]
    },
    prd = {
      vm_instances = [
        {
          name                  = "prd-app-vm-1"
          machine_type          = "e2-standard-2"
          zone                  = "asia-southeast2-a"
          service_account_email = ""
          service_account_scopes = [
            "https://www.googleapis.com/auth/cloud-platform"
          ]
          boot_disk_image      = "ubuntu-os-cloud/ubuntu-2204-lts"
          boot_disk_size_gb    = 10
          boot_disk_type       = "pd-standard"
          network              = ""
          subnetwork           = ""
          public_ip            = false
          metadata             = {}
          network_tags         = ["app-server", "prd"]
          startup_script       = ""
          preemptible          = false
          provisioning_model   = "STANDARD"
          instance_termination_action = "DELETE"
          spot                = false
        },
        {
          name                  = "prd-app-vm-2"
          machine_type          = "e2-standard-2"
          zone                  = "asia-southeast2-b"
          service_account_email = ""
          service_account_scopes = [
            "https://www.googleapis.com/auth/cloud-platform"
          ]
          boot_disk_image      = "ubuntu-os-cloud/ubuntu-2204-lts"
          boot_disk_size_gb    = 10
          boot_disk_type       = "pd-standard"
          network              = ""
          subnetwork           = ""
          public_ip            = false
          metadata             = {}
          network_tags         = ["app-server", "prd"]
          startup_script       = ""
          preemptible          = false
          provisioning_model   = "STANDARD"
          instance_termination_action = "DELETE"
          spot                = false
        }
      ],
      additional_disks = [
        {
          instance_name     = "prd-app-vm-1"
          disk_name         = "prd-app-data-disk-1"
          disk_type         = "pd-ssd"
          zone              = "asia-southeast2-a"
          disk_size_gb      = 200
          disk_image        = ""
          kms_key_self_link = ""
          device_name       = "data-disk"
          mode              = "READ_WRITE"
        },
        {
          instance_name     = "prd-app-vm-2"
          disk_name         = "prd-app-data-disk-2"
          disk_type         = "pd-ssd"
          zone              = "asia-southeast2-b"
          disk_size_gb      = 200
          disk_image        = ""
          kms_key_self_link = ""
          device_name       = "data-disk"
          mode              = "READ_WRITE"
        }
      ]
    }
  }
}

# VM Instances
variable "vm_instances" {
  description = "List of VM instances to dibuat (diambil dari vm_configs berdasarkan environment)"
  type = list(object({
    name                  = string
    machine_type          = string
    zone                  = string
    service_account_email = string
    service_account_scopes = list(string)
    boot_disk_image       = string
    boot_disk_size_gb     = number
    boot_disk_type        = string
    network               = string
    subnetwork            = string
    public_ip             = bool
    metadata              = map(string)
    network_tags          = list(string)
    startup_script        = string
    preemptible           = bool
    provisioning_model    = string
    instance_termination_action = string
  }))
  default = []
}

# Additional Disks
variable "additional_disks" {
  description = "List of additional disks untuk di-attach ke VM (diambil dari vm_configs berdasarkan environment)"
  type = list(object({
    instance_name     = string
    disk_name         = string
    disk_type         = string
    zone              = string
    disk_size_gb      = number
    disk_image        = string
    kms_key_self_link = string
    device_name       = string
    mode              = string
  }))
  default = []
}
