# GCP Infrastructure Foundation dengan Terragrunt dan Folder-Based Environments

Repositori ini berisi konfigurasi Terragrunt dan Terraform untuk membuat dan mengelola infrastruktur dasar di Google Cloud Platform (GCP) menggunakan pendekatan folder-based untuk management lingkungan (environments).

## Struktur Direktori

```
.
├── modules/                  # Modul-modul Terraform yang dapat digunakan kembali
│   ├── project/              # Modul untuk membuat dan mengelola project GCP
│   ├── vpc/                  # Modul untuk membuat dan mengelola VPC
│   ├── kms/                  # Modul untuk Customer-Managed Encryption Keys (CMEK)
│   └── gke/                  # Modul untuk Google Kubernetes Engine clusters
├── terragrunt/               # Konfigurasi Terragrunt untuk komponen infrastruktur
│   ├── dev/                  # Konfigurasi untuk environment development
│   │   ├── project/          # Konfigurasi Terragrunt untuk project GCP (dev)
│   │   ├── vpc/              # Konfigurasi Terragrunt untuk VPC (dev)
│   │   ├── kms/              # Konfigurasi Terragrunt untuk KMS (dev)
│   │   └── gke/              # Konfigurasi Terragrunt untuk GKE (dev)
│   ├── stg/                  # Konfigurasi untuk environment staging
│   │   ├── project/          # Konfigurasi Terragrunt untuk project GCP (stg)
│   │   ├── vpc/              # Konfigurasi Terragrunt untuk VPC (stg)
│   │   ├── kms/              # Konfigurasi Terragrunt untuk KMS (stg)
│   │   └── gke/              # Konfigurasi Terragrunt untuk GKE (stg)
│   └── prd/                  # Konfigurasi untuk environment production
│       ├── project/          # Konfigurasi Terragrunt untuk project GCP (prd)
│       ├── vpc/              # Konfigurasi Terragrunt untuk VPC (prd)
│       ├── kms/              # Konfigurasi Terragrunt untuk KMS (prd)
│       └── gke/              # Konfigurasi Terragrunt untuk GKE (prd)
├── .gitignore                # File untuk mengabaikan file-file tertentu dalam Git
├── terragrunt.hcl            # Konfigurasi root Terragrunt yang digunakan oleh semua komponen
└── README.md                 # Dokumentasi proyek
```

## Prasyarat

- [Terraform](https://www.terraform.io/downloads.html) (v1.0.0+)
- [Terragrunt](https://terragrunt.gruntwork.io/docs/getting-started/install/) (v0.45.0+)
- [Google Cloud SDK](https://cloud.google.com/sdk/docs/install)
- Akun Google Cloud dengan akses yang sesuai

## Perubahan Terbaru

### Implementasi GCE dengan CMEK dan IAM (30 Maret 2025)

- **GCE dengan CMEK**: Mengimplementasikan Google Compute Engine (GCE) instances dengan Customer-Managed Encryption Keys (CMEK) untuk enkripsi disk.
- **IAM untuk KMS**: Menambahkan modul IAM untuk mengelola permission KMS key bagi service account VM instances.
- **Optimasi Disk**:
  - Menggunakan pd-standard untuk data disk (200GB) untuk mengatasi keterbatasan kuota SSD.
  - Mengkonfigurasi boot disk yang kecil (10GB) dengan Ubuntu 22.04 LTS.
  - Menerapkan CMEK untuk enkripsi data disk.
- **High Availability**: Mendistribusikan VM instances di multiple zones (asia-southeast2-a dan asia-southeast2-b).

### Implementasi GKE dengan CMEK dan Optimasi Resource (30 Maret 2025)

- **GKE dengan CMEK**: Mengimplementasikan Google Kubernetes Engine (GKE) cluster dengan Customer-Managed Encryption Keys (CMEK) untuk enkripsi database.
- **Zonal vs Regional**: Mengubah konfigurasi dari regional menjadi zonal (asia-southeast2-a) untuk optimasi kuota resource.
- **Optimasi Resource**:
  - Mengoptimalkan kebutuhan CPU: default node pool (e2-standard-2, 1 node), workload node pool (e2-small, 1 node), total 4 vCPUs.
  - Mengurangi disk size dari 50GB menjadi 20GB dan menggunakan pd-standard untuk mengatasi keterbatasan kuota SSD.
  - Mengkonfigurasi autoscaling dengan min_node_count=1 dan max_node_count yang lebih rendah.
- **Perbaikan Konfigurasi Jaringan**: Menggunakan ip_allocation_policy dengan secondary ranges untuk pods dan services.

### Migrasi ke Folder-Based Approach (29 Maret 2025)

- **Struktur Folder per Environment**: Mengubah pendekatan dari workspace-based menjadi folder-based dengan direktori terpisah untuk setiap environment (dev, stg, prd).
- **Eksplisit Environment**: Menggunakan variabel `environment` yang dideklarasikan secara eksplisit di setiap file `terragrunt.hcl` environment.
- **Dependency Management**: Menambahkan mock_outputs untuk dependency antar modul, memungkinkan plan tanpa apply dependencies.
- **Penyederhanaan Variable Reference**: Menggunakan `var.environment` instead of `terraform.workspace` di modul-modul Terraform.

## Cara Penggunaan dengan Folder-Based Approach

Repositori ini menggunakan Terragrunt dengan struktur folder untuk mengelola lingkungan yang berbeda (dev, stg, prd). Pendekatan folder-based memungkinkan Anda memiliki konfigurasi terpisah untuk setiap lingkungan dengan struktur direktori yang jelas.

1. Autentikasi ke Google Cloud:
   ```
   gcloud auth application-default login
   ```

2. Menjalankan untuk lingkungan production:
   ```
   cd terragrunt/prd/project
   terragrunt init
   terragrunt plan
   terragrunt apply
   ```

3. Menjalankan untuk lingkungan staging:
   ```
   cd terragrunt/stg/project
   terragrunt init
   terragrunt plan
   terragrunt apply
   ```

4. Menjalankan untuk lingkungan development:
   ```
   cd terragrunt/dev/project
   terragrunt init
   terragrunt plan
   terragrunt apply
   ```

5. Menjalankan semua modul dalam satu lingkungan:
   ```
   cd terragrunt/prd
   terragrunt run-all apply
   ```

## Komponen Infrastruktur

- **Project GCP**: Membuat dan mengonfigurasi project GCP dengan pengaturan billing dan API yang diperlukan.
- **VPC Network**: Membuat jaringan VPC dengan subnet, firewall rules, dan komponen networking lainnya.
- **KMS (Key Management Service)**: Mengelola Customer-Managed Encryption Keys (CMEK) untuk enkripsi database dan resources lainnya.
- **GKE (Google Kubernetes Engine)**: Membuat dan mengelola cluster Kubernetes dengan node pools teroptimasi dan enkripsi CMEK.
- **CloudSQL MySQL**: Database MySQL yang dikelola dengan high availability, backup otomatis, dan enkripsi CMEK.

## Implementasi Environment-Specific Variables

```hcl
# Di terragrunt/prd/project/terragrunt.hcl
locals {
  environment = "prd"
}

inputs = {
  environment = local.environment
}

# Di modules/project/main.tf
resource "google_project" "project" {
  name            = var.project_name[var.environment]
  project_id      = var.project_id[var.environment]
  billing_account = var.billing_account
  
  labels = {
    environment = var.environment
    managed_by  = "terraform"
  }
}
```

## Keuntungan Menggunakan Terragrunt dengan Folder-Based Approach

1. **Kejelasan Struktur**: Struktur direktori yang intuitif memperjelas environment mana yang sedang dikerjakan.
2. **Menghindari Kesalahan**: Tidak perlu khawatir salah memilih workspace karena environment sudah diatur di struktur folder.
3. **State Isolation**: Setiap environment memiliki state terpisah berdasarkan struktur folder.
4. **Dependency Management**: Terragrunt menangani dependensi antar modul dengan lebih jelas melalui mock_outputs.
5. **Parallel Workflow**: Memungkinkan beberapa orang bekerja pada environment yang berbeda secara bersamaan tanpa konflik.
