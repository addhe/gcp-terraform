# Root terragrunt.hcl file
# This is the root terragrunt configuration that all stacks will inherit from

# Configure Terragrunt to automatically store tfstate files in GCS
remote_state {
  backend = "gcs"
  
  config = {
    project  = local.project_configs[local.workspace].project_id
    location = local.project_configs[local.workspace].region
    bucket   = "${local.project_configs[local.workspace].project_id}-terraform-state"
    prefix   = "${path_relative_to_include()}/${local.workspace}/terraform.tfstate"
    
    # Enable encryption
    encryption_key = ""
    
    # Enable versioning
    enable_bucket_policy_only = true
  }
  
  # Automatically create the GCS bucket if it doesn't exist
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
  project = "${local.project_configs[terraform.workspace].project_id}"
  region  = "${local.project_configs[terraform.workspace].region}"
}

provider "google-beta" {
  project = "${local.project_configs[terraform.workspace].project_id}"
  region  = "${local.project_configs[terraform.workspace].region}"
}
EOF
}

# Load common variables to be used across all modules
locals {
  # Get the current Terraform workspace
  workspace = get_env("TF_WORKSPACE", "dev")
  
  # Define configuration for each workspace/environment
  project_configs = {
    dev = {
      environment    = "dev"
      project_id     = "my-company-dev"
      project_name   = "My Company Dev"
      region         = "asia-southeast1"
      billing_account = ""
      organization_id = ""
      folder_id       = ""
    }
    staging = {
      environment    = "staging"
      project_id     = "my-company-staging"
      project_name   = "My Company Staging"
      region         = "asia-southeast1"
      billing_account = ""
      organization_id = ""
      folder_id       = ""
    }
    prod = {
      environment    = "prod"
      project_id     = "my-company-prod"
      project_name   = "My Company Production"
      region         = "asia-southeast1"
      billing_account = ""
      organization_id = ""
      folder_id       = ""
    }
  }
}

# Configure root level variables that all resources can inherit
inputs = {
  environment     = local.project_configs[local.workspace].environment
  project_id      = local.project_configs[local.workspace].project_id
  project_name    = local.project_configs[local.workspace].project_name
  region          = local.project_configs[local.workspace].region
  billing_account = local.project_configs[local.workspace].billing_account
  organization_id = local.project_configs[local.workspace].organization_id
  folder_id       = local.project_configs[local.workspace].folder_id
}
