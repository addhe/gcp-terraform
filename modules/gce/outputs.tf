/**
 * # Google Compute Engine Module Outputs
 *
 * Output yang dihasilkan dari modul GCE
 */

output "vm_instance_ids" {
  description = "ID dari VM instances yang dibuat"
  value       = { for k, v in google_compute_instance.vm_instances : k => v.id }
}

output "vm_instance_names" {
  description = "Nama VM instances yang dibuat"
  value       = { for k, v in google_compute_instance.vm_instances : k => v.name }
}

output "vm_instance_self_links" {
  description = "Self link dari VM instances yang dibuat"
  value       = { for k, v in google_compute_instance.vm_instances : k => v.self_link }
}

output "vm_instance_internal_ips" {
  description = "Internal IP dari VM instances yang dibuat"
  value       = { for k, v in google_compute_instance.vm_instances : k => v.network_interface.0.network_ip }
}

output "data_disk_ids" {
  description = "ID dari data disks yang dibuat"
  value       = { for k, v in google_compute_disk.data_disk : k => v.id }
}

output "data_disk_names" {
  description = "Nama data disks yang dibuat"
  value       = { for k, v in google_compute_disk.data_disk : k => v.name }
}

output "data_disk_self_links" {
  description = "Self link dari data disks yang dibuat" 
  value       = { for k, v in google_compute_disk.data_disk : k => v.self_link }
}

output "vm_instance_service_accounts" {
  description = "List of service account emails used by VM instances"
  value       = [for vm in google_compute_instance.vm_instances : "serviceAccount:${vm.service_account[0].email}"]
}
