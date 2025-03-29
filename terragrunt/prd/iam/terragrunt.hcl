include "root" {
  path = find_in_parent_folders()
}

# Menggunakan modul IAM
terraform {
  source = "${get_parent_terragrunt_dir()}/modules//iam"
}

# Dependency pada KMS
dependency "kms" {
  config_path = "../kms"
  
  # Mock outputs untuk terragrunt plan
  mock_outputs = {
    key_ring_id = "projects/awanmasterpiece-prd/locations/asia-southeast2/keyRings/awanmasterpiece-prd"
    compute_disk_crypto_key_id = "projects/awanmasterpiece-prd/locations/asia-southeast2/keyRings/awanmasterpiece-prd/cryptoKeys/compute-disk"
  }
  
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
}

# Dependency pada GCE untuk mendapatkan service account
dependency "gce" {
  config_path = "../gce"
  
  # Mock outputs untuk terragrunt plan
  mock_outputs = {
    vm_instance_service_accounts = []
  }
  
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
}

# Konfigurasi input
inputs = {
  kms_key_id = dependency.kms.outputs.compute_disk_crypto_key_id
  kms_key_ring_id = dependency.kms.outputs.key_ring_id
  service_accounts = dependency.gce.outputs.vm_instance_service_accounts
}
