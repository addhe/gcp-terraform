module "project" {
  source = "../../modules/project"

  project_id      = var.project_id
  project_name    = var.project_name
  billing_account = var.billing_account
  organization_id = var.organization_id
  folder_id       = var.folder_id
  services        = var.project_services
  labels          = {
    environment = "dev"
    managed_by  = "terraform"
  }
}

module "vpc" {
  source = "../../modules/vpc"

  project_id   = module.project.project_id
  network_name = "${var.project_id}-vpc"
  description  = "Development VPC network for ${var.project_name}"

  subnets = [
    {
      name          = "subnet-01"
      ip_cidr_range = "10.0.0.0/24"
      region        = var.region
      secondary_ip_ranges = [
        {
          range_name    = "pods"
          ip_cidr_range = "10.1.0.0/16"
        },
        {
          range_name    = "services"
          ip_cidr_range = "10.2.0.0/20"
        }
      ]
    },
    {
      name          = "subnet-02"
      ip_cidr_range = "10.0.1.0/24"
      region        = var.region
    }
  ]

  firewall_rules = [
    {
      name        = "allow-internal"
      description = "Allow internal traffic"
      ranges      = ["10.0.0.0/24", "10.0.1.0/24"]
      allow = [
        {
          protocol = "tcp"
          ports    = ["0-65535"]
        },
        {
          protocol = "udp"
          ports    = ["0-65535"]
        },
        {
          protocol = "icmp"
        }
      ]
    },
    {
      name        = "allow-ssh"
      description = "Allow SSH from IAP"
      ranges      = ["35.235.240.0/20"] # Google Cloud IAP IP range
      allow = [
        {
          protocol = "tcp"
          ports    = ["22"]
        }
      ]
    }
  ]
}
