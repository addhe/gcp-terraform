# Root terragrunt.hcl file
# This is the root terragrunt configuration that all stacks will inherit from

# Configure Terragrunt to automatically store tfstate files in GCS
remote_state {
  backend = "gcs"
  
  config = {
    project  = "awanmasterpiece-${local.workspace}"
    location = local.region
    bucket   = "awanmasterpiece-terraform-state" # Menggunakan bucket yang sudah dibuat
    prefix   = "${path_relative_to_include()}/${local.workspace}/terraform.tfstate"
    
    # Enable encryption
    encryption_key = ""
    
    # Enable versioning
    enable_bucket_policy_only = true
  }
  
  # Bucket sudah dibuat, jadi kita tidak perlu generate lagi
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

# Generate provider configuration for all child terragrunt configurations
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.80.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 4.80.0"
    }
  }
}

provider "google" {
  project = "awanmasterpiece-${local.workspace}"
  region  = "${local.region}"
}

provider "google-beta" {
  project = "awanmasterpiece-${local.workspace}"
  region  = "${local.region}"
}
EOF
}

# Load common variables to be used across all modules
locals {
  # Mendapatkan workspace dari command-line argument atau TF_WORKSPACE
  workspace = get_env("TF_WORKSPACE", "dev")
  
  # Region yang sama untuk semua environment
  region = "asia-southeast2"
  
  # Billing account yang sama untuk semua environment
  billing_account = "013A89-4FE496-09FAF2" # My Billing Account Oct 2024 (aktif)
}

# Configure root level variables that all resources can inherit
inputs = {
  environment     = local.workspace
  region          = local.region
  billing_account = local.billing_account
  organization_id = ""
  folder_id       = ""
}
