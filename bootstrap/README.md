# Bootstrap Terraform State Bucket

Modul ini digunakan untuk membuat bucket Google Cloud Storage (GCS) yang akan menyimpan state Terraform/Terragrunt. Bucket ini perlu dibuat sebelum kita dapat menggunakan remote state untuk infrastruktur lainnya.

## Cara Penggunaan

1. Salin file `terraform.tfvars.example` ke `terraform.tfvars` dan sesuaikan nilai-nilainya:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. Edit file `terraform.tfvars` untuk mengisi:
   - `project_id`: ID project GCP Anda
   - `region`: Region GCP yang diinginkan
   - `admin_members`: List IAM members yang memiliki akses admin ke bucket
   - `viewer_members`: List IAM members yang memiliki akses read-only ke bucket

3. Inisialisasi Terraform:
   ```bash
   terraform init
   ```

4. Lihat perubahan yang akan diterapkan:
   ```bash
   terraform plan
   ```

5. Terapkan perubahan:
   ```bash
   terraform apply
   ```

## Setelah Bucket Dibuat

Setelah bucket state dibuat, Anda perlu memperbarui file `terragrunt.hcl` utama dengan nama bucket yang benar. Bucket name akan ditampilkan di output setelah `terraform apply` berhasil dijalankan.

Perbarui bagian `remote_state` di file `terragrunt.hcl` dengan nama bucket yang benar:

```hcl
remote_state {
  backend = "gcs"
  
  config = {
    project  = local.project_configs[local.workspace].project_id
    location = local.project_configs[local.workspace].region
    bucket   = "<NAMA_BUCKET_YANG_DIBUAT>" # Perbarui dengan output state_bucket_name
    prefix   = "${path_relative_to_include()}/${local.workspace}/terraform.tfstate"
  }
}
```

## Catatan Penting

- Bucket state adalah komponen kritis dalam infrastruktur Terraform/Terragrunt. Pastikan untuk mengatur akses dengan benar.
- Bucket state memiliki `prevent_destroy = true` untuk mencegah penghapusan yang tidak disengaja.
- Versioning diaktifkan untuk melindungi state dari perubahan yang tidak disengaja.
- Uniform bucket-level access diaktifkan untuk keamanan yang lebih baik.
