# Uncomment this block after creating a GCS bucket for storing Terraform state
# terraform {
#   backend "gcs" {
#     bucket = "YOUR_TERRAFORM_STATE_BUCKET_NAME"
#     prefix = "terraform/state"
#   }
# }

# For now, we'll use local state
terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}
