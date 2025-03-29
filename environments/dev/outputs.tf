output "project_id" {
  description = "The ID of the created project"
  value       = module.project.project_id
}

output "project_number" {
  description = "The number of the created project"
  value       = module.project.project_number
}

output "network_name" {
  description = "The name of the VPC network"
  value       = module.vpc.network_name
}

output "network_self_link" {
  description = "The self-link of the VPC network"
  value       = module.vpc.network_self_link
}

output "subnets" {
  description = "A map of subnet names to subnet self_links"
  value       = module.vpc.subnets
}

output "subnet_regions" {
  description = "A map of subnet names to the regions they are in"
  value       = module.vpc.subnet_regions
}

output "subnet_ips" {
  description = "A map of subnet names to their primary IP CIDR ranges"
  value       = module.vpc.subnet_ips
}
