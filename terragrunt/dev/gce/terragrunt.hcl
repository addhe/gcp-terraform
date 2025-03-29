include "root" {
  path = find_in_parent_folders()
}

locals {
  environment = "dev"
  
  # Definisi VM instances untuk environment dev
  vm_instances = [
    {
      name                  = "dev-app-vm-1"
      machine_type          = "e2-small"
      zone                  = "asia-southeast2-a"
      service_account_email = ""
      service_account_scopes = [
        "https://www.googleapis.com/auth/cloud-platform"
      ]
      boot_disk_image       = "ubuntu-os-cloud/ubuntu-2204-lts"
      boot_disk_size_gb     = 10
      boot_disk_type        = "pd-standard"
      public_ip             = false
      metadata              = {}
      network_tags          = ["app-server", "dev"]
      startup_script        = ""
      preemptible           = false
      spot                  = true
    }
  ]
  
  # Definisi additional disks untuk environment dev
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
}

# Menggunakan modul GCE
terraform {
  source = "${get_parent_terragrunt_dir()}/modules//gce"
}

# Dependency pada VPC dan project
dependency "vpc" {
  config_path = "../vpc"
  
  # Mock outputs untuk terragrunt plan
  mock_outputs = {
    network_name = "awanmasterpiece-dev-vpc"
    network_id   = "projects/awanmasterpiece-dev/global/networks/awanmasterpiece-dev-vpc"
    subnet_ids = {
      "subnet-01" = "projects/awanmasterpiece-dev/regions/asia-southeast2/subnetworks/subnet-01"
    }
  }
}

# Dependency pada KMS untuk CMEK (opsional)
dependency "kms" {
  config_path = "../kms"
  
  # Mock outputs untuk terragrunt plan
  mock_outputs = {
    gke_crypto_key_id = "projects/awanmasterpiece-dev/locations/asia-southeast2/keyRings/awanmasterpiece-dev/cryptoKeys/gce-dev"
  }
  
  # Jika KMS belum di-deploy, plan tetap bisa dilakukan
  skip_outputs = true
}

# Konfigurasi input
inputs = {
  # Menggunakan konfigurasi VM dari locals
  vm_instances = [
    for vm in local.vm_instances : {
      name                  = vm.name
      machine_type          = vm.machine_type
      zone                  = vm.zone
      service_account_email = vm.service_account_email
      service_account_scopes = vm.service_account_scopes
      boot_disk_image       = vm.boot_disk_image
      boot_disk_size_gb     = vm.boot_disk_size_gb
      boot_disk_type        = vm.boot_disk_type
      network               = dependency.vpc.outputs.network_id
      subnetwork            = dependency.vpc.outputs.subnets["subnet-01"]
      public_ip             = vm.public_ip
      metadata              = vm.metadata
      network_tags          = vm.network_tags
      startup_script        = vm.startup_script
      preemptible           = vm.preemptible
      provisioning_model    = vm.spot ? "SPOT" : "STANDARD"
      instance_termination_action = vm.spot ? "STOP" : "DELETE"
      spot                  = vm.spot
    }
  ]
  
  # Menggunakan konfigurasi additional disks dari locals dengan KMS key jika ada
  additional_disks = [
    for disk in local.additional_disks : {
      instance_name     = disk.instance_name
      disk_name         = disk.disk_name
      disk_type         = disk.disk_type
      zone              = disk.zone
      disk_size_gb      = disk.disk_size_gb
      disk_image        = disk.disk_image
      kms_key_self_link = try(dependency.kms.outputs.gke_crypto_key_id, "")
      device_name       = disk.device_name
      mode              = disk.mode
    }
  ]
}
