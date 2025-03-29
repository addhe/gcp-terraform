/**
 * # Google Compute Engine Module
 *
 * Modul ini membuat instance Google Compute Engine (VM) dengan konfigurasi berikut:
 * - Support untuk multiple VM instances
 * - Boot disk kecil untuk OS
 * - Additional disk terpisah untuk data
 * - Network tags untuk firewall rules
 */

resource "google_compute_instance" "vm_instances" {
  for_each = { for vm in var.vm_instances : vm.name => vm }
  
  name         = each.value.name
  machine_type = each.value.machine_type
  zone         = each.value.zone
  
  # Menggunakan default service account dengan scope minimal yang diperlukan
  service_account {
    email  = each.value.service_account_email
    scopes = each.value.service_account_scopes
  }
  
  # Boot disk kecil hanya untuk OS
  boot_disk {
    initialize_params {
      image = each.value.boot_disk_image
      size  = each.value.boot_disk_size_gb
      type  = each.value.boot_disk_type
    }
  }
  
  # Network interface
  network_interface {
    network    = each.value.network
    subnetwork = each.value.subnetwork
    
    # Jika public_ip = true, maka berikan IP publik
    dynamic "access_config" {
      for_each = each.value.public_ip ? [1] : []
      content {
        # Ephemeral public IP
      }
    }
  }
  
  # Metadata untuk VM
  metadata = merge(
    each.value.metadata,
    {
      "enable-oslogin" = "TRUE"
    },
    each.value.startup_script != "" ? {
      "startup-script" = each.value.startup_script
    } : {}
  )
  
  # Tag untuk firewall
  tags = each.value.network_tags
  
  # Allow stopping for update
  allow_stopping_for_update = true
  
  # Konfigurasi scheduling untuk Spot VMs atau Standard VMs
  scheduling {
    # Preemptible harus true untuk backward compatibility
    preemptible       = each.value.preemptible
    # Menggunakan SPOT atau STANDARD sesuai dengan flag provisioning_model
    provisioning_model = each.value.provisioning_model
    # Automatic restart harus false untuk Spot VMs
    automatic_restart   = each.value.preemptible ? false : true
    # Maintenance behavior
    on_host_maintenance = each.value.preemptible ? "TERMINATE" : "MIGRATE"
    # Menentukan apa yang terjadi saat VM dihentikan
    instance_termination_action = each.value.instance_termination_action
  }
}

# Additional data disk untuk VM
resource "google_compute_disk" "data_disk" {
  for_each = { for disk in var.additional_disks : "${disk.instance_name}-${disk.disk_name}" => disk }
  
  name  = each.value.disk_name
  type  = each.value.disk_type
  zone  = each.value.zone
  size  = each.value.disk_size_gb
  
  # Jika image diperlukan untuk inisialisasi disk
  image = each.value.disk_image != "" ? each.value.disk_image : null
  
  # Enkripsi disk menggunakan default Google-managed key
  # TODO: Aktifkan CMEK setelah mendapatkan izin yang diperlukan
}

# Attach additional disk ke VM
resource "google_compute_attached_disk" "attached_disk" {
  for_each = { for disk in var.additional_disks : "${disk.instance_name}-${disk.disk_name}" => disk }
  
  disk     = google_compute_disk.data_disk[each.key].id
  instance = google_compute_instance.vm_instances[each.value.instance_name].id
  zone     = each.value.zone
  
  # Jika mode dan device_name diperlukan
  device_name = each.value.device_name != "" ? each.value.device_name : null
  mode        = each.value.mode != "" ? each.value.mode : "READ_WRITE"
}
