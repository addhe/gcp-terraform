include "root" {
  path = find_in_parent_folders()
}

# Dependency pada VPC dan project
dependency "vpc" {
  config_path = "../vpc"
  
  # Mock outputs untuk terragrunt plan
  mock_outputs = {
    network_name = "awanmasterpiece-prd-vpc"
    network_id   = "projects/awanmasterpiece-prd/global/networks/awanmasterpiece-prd-vpc"
    subnet_ids = {
      "subnet-01" = "projects/awanmasterpiece-prd/regions/asia-southeast2/subnetworks/subnet-01"
    }
  }
}

# Dependency pada KMS untuk CMEK
dependency "kms" {
  config_path = "../kms"
  
  # Mock outputs untuk terragrunt plan
  mock_outputs = {
    compute_disk_crypto_key_id = "projects/awanmasterpiece-prd/locations/asia-southeast2/keyRings/awanmasterpiece-prd-2/cryptoKeys/compute-disk-prd-2"
  }
  
  # Jika KMS belum di-deploy, plan tetap bisa dilakukan
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
}

locals {
  environment = "prd"
  
  # Definisi VM instances untuk environment prd
  vm_instances = [
    {
      name                  = "prd-app-vm-1"
      machine_type          = "e2-standard-2"
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
      network_tags          = ["app-server", "prd"]
      startup_script        = ""
      preemptible           = false
      spot                  = false
    },
    {
      name                  = "prd-app-vm-2"
      machine_type          = "e2-standard-2"
      zone                  = "asia-southeast2-b"
      service_account_email = ""
      service_account_scopes = [
        "https://www.googleapis.com/auth/cloud-platform"
      ]
      boot_disk_image       = "ubuntu-os-cloud/ubuntu-2204-lts"
      boot_disk_size_gb     = 10
      boot_disk_type        = "pd-standard"
      public_ip             = false
      metadata              = {}
      network_tags          = ["app-server", "prd"]
      startup_script        = ""
      preemptible           = false
      spot                  = false
    }
  ]
  

}

# Menggunakan modul GCE
terraform {
  source = "${get_parent_terragrunt_dir()}/modules//gce"
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
      instance_termination_action = vm.spot ? "STOP" : null
      spot                  = vm.spot
    }
  ]
  
  # Konfigurasi additional disks dengan KMS key
  additional_disks = [
    {
      instance_name     = "prd-app-vm-1"
      disk_name         = "prd-app-data-disk-1"
      disk_type         = "pd-standard"
      zone              = "asia-southeast2-a"
      disk_size_gb      = 200
      disk_image        = ""
      kms_key_self_link = try(dependency.kms.outputs.compute_disk_crypto_key_id, "")
      device_name       = "data-disk"
      mode              = "READ_WRITE"
    },
    {
      instance_name     = "prd-app-vm-2"
      disk_name         = "prd-app-data-disk-2"
      disk_type         = "pd-standard"
      zone              = "asia-southeast2-b"
      disk_size_gb      = 200
      disk_image        = ""
      kms_key_self_link = try(dependency.kms.outputs.compute_disk_crypto_key_id, "")
      device_name       = "data-disk"
      mode              = "READ_WRITE"
    }
  ]
}
