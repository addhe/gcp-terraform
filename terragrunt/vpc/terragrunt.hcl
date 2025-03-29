include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../modules/vpc"
}

# Pastikan modul project dijalankan terlebih dahulu
dependency "project" {
  config_path = "../project"
}

# Konfigurasi spesifik untuk modul vpc
inputs = {
  project_id   = dependency.project.outputs.project_id
  network_name = "${dependency.project.outputs.project_id}-vpc"
  description  = "${terraform.workspace} VPC network for ${dependency.project.outputs.project_name}"
  
  subnets = [
    {
      name          = "subnet-01"
      ip_cidr_range = "10.0.0.0/24"
      region        = local.project_configs[local.workspace].region
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
      region        = local.project_configs[local.workspace].region
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

# Tambahkan hook untuk memastikan workspace yang benar digunakan
terraform {
  before_hook "workspace_select" {
    commands = ["init", "plan", "apply", "destroy"]
    execute  = ["terraform", "workspace", "select", get_env("TF_WORKSPACE", "dev"), "-or-create"]
  }
}
