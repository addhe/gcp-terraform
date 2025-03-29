output "network_id" {
  description = "The ID of the VPC network"
  value       = google_compute_network.vpc.id
}

output "network_name" {
  description = "The name of the VPC network"
  value       = google_compute_network.vpc.name
}

output "network_self_link" {
  description = "The self-link of the VPC network"
  value       = google_compute_network.vpc.self_link
}

output "subnets" {
  description = "A map of subnet names to subnet self_links"
  value       = { for name, subnet in google_compute_subnetwork.subnets : name => subnet.self_link }
}

output "subnet_regions" {
  description = "A map of subnet names to the regions they are in"
  value       = { for name, subnet in google_compute_subnetwork.subnets : name => subnet.region }
}

output "subnet_ips" {
  description = "A map of subnet names to their primary IP CIDR ranges"
  value       = { for name, subnet in google_compute_subnetwork.subnets : name => subnet.ip_cidr_range }
}

output "subnet_secondary_ranges" {
  description = "A map of subnet names to their secondary IP ranges"
  value = {
    for name, subnet in google_compute_subnetwork.subnets : name => {
      for range in subnet.secondary_ip_range : range.range_name => range.ip_cidr_range
    }
  }
}
