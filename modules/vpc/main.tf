resource "google_compute_network" "vpc" {
  project                         = var.project_id
  name                            = var.network_name
  description                     = var.description
  auto_create_subnetworks         = var.auto_create_subnetworks
  routing_mode                    = var.routing_mode
  delete_default_routes_on_create = var.delete_default_routes_on_create
}

# Menggunakan variabel environment dari Terragrunt (folder-based)
resource "google_compute_subnetwork" "subnets" {
  for_each = { for subnet in var.subnet_configs[var.environment] : subnet.name => subnet }

  project                  = var.project_id
  name                     = each.value.name
  ip_cidr_range           = each.value.ip_cidr_range
  region                   = each.value.region
  network                  = google_compute_network.vpc.id
  private_ip_google_access = true
  purpose                  = "PRIVATE"
  role                     = null

  dynamic "secondary_ip_range" {
    for_each = each.value.secondary_ip_ranges
    content {
      range_name    = secondary_ip_range.value.range_name
      ip_cidr_range = secondary_ip_range.value.ip_cidr_range
    }
  }
}

# Private Services Connection
resource "google_compute_global_address" "private_ip_alloc" {
  project       = var.project_id
  name          = "${var.network_name}-private-ip-alloc"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.vpc.id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_alloc.name]
}

resource "google_compute_firewall" "rules" {
  for_each = { for rule in var.firewall_rules[var.environment] : rule.name => rule }

  project     = var.project_id
  name        = each.value.name
  description = each.value.description
  network     = google_compute_network.vpc.id
  direction   = each.value.direction
  priority    = each.value.priority

  source_ranges      = each.value.direction == "INGRESS" ? each.value.ranges : null
  destination_ranges = each.value.direction == "EGRESS" ? each.value.ranges : null

  source_tags             = length(each.value.source_tags) > 0 ? each.value.source_tags : null
  source_service_accounts = length(each.value.source_service_accounts) > 0 ? each.value.source_service_accounts : null
  target_tags             = length(each.value.target_tags) > 0 ? each.value.target_tags : null
  target_service_accounts = length(each.value.target_service_accounts) > 0 ? each.value.target_service_accounts : null

  dynamic "allow" {
    for_each = each.value.allow
    content {
      protocol = allow.value.protocol
      ports    = allow.value.ports
    }
  }

  dynamic "deny" {
    for_each = each.value.deny
    content {
      protocol = deny.value.protocol
      ports    = deny.value.ports
    }
  }
}
