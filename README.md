# GCP Infrastructure Foundation dengan Terragrunt dan Workspace

Repositori ini berisi konfigurasi Terragrunt dan Terraform untuk membuat dan mengelola infrastruktur dasar di Google Cloud Platform (GCP) menggunakan pendekatan workspace.

## Struktur Direktori

```
.
├── modules/                  # Modul-modul Terraform yang dapat digunakan kembali
│   ├── project/              # Modul untuk membuat dan mengelola project GCP
│   └── vpc/                  # Modul untuk membuat dan mengelola VPC
├── terragrunt/               # Konfigurasi Terragrunt untuk komponen infrastruktur
│   ├── project/              # Konfigurasi Terragrunt untuk project GCP
│   └── vpc/                  # Konfigurasi Terragrunt untuk VPC
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

### Refaktor Konfigurasi Project (29 Maret 2025)

- **Penggunaan `terraform.workspace`**: Mengubah kode untuk menggunakan `terraform.workspace` langsung di file Terraform untuk mengakses nilai dari map variabel.
- **Struktur Variabel Map**: Mengubah variabel `project_id` dan `project_name` menjadi map berdasarkan environment (dev, stg, prd).
- **Penyederhanaan Label**: Menggunakan hardcoded labels di `main.tf` dengan nilai `environment` yang diambil dari `terraform.workspace`.
- **Penyederhanaan Terragrunt**: Menyederhanakan konfigurasi Terragrunt untuk mengurangi kompleksitas.

## Cara Penggunaan dengan Workspace

Repositori ini menggunakan Terragrunt dan workspace Terraform untuk mengelola lingkungan yang berbeda (dev, stg, prd). Workspace memungkinkan Anda menggunakan konfigurasi yang sama dengan variabel yang berbeda untuk setiap lingkungan.

1. Autentikasi ke Google Cloud:
   ```
   gcloud auth application-default login
   ```

2. Menjalankan untuk lingkungan development (default):
   ```
   cd terragrunt/project
   terragrunt workspace select dev
   terragrunt init
   terragrunt plan
   terragrunt apply
   ```

3. Menjalankan untuk lingkungan staging:
   ```
   cd terragrunt/project
   terragrunt workspace select stg
   terragrunt init
   terragrunt plan
   terragrunt apply
   ```

4. Menjalankan untuk lingkungan production:
   ```
   cd terragrunt/project
   terragrunt workspace select prd
   terragrunt init
   terragrunt plan
   terragrunt apply
   ```

5. Alternatif menggunakan variabel lingkungan:
   ```
   cd terragrunt/project
   export TF_WORKSPACE=prd
   terragrunt init
   terragrunt plan
   terragrunt apply
   ```

6. Untuk menjalankan semua modul sekaligus:
   ```
   cd terragrunt
   terragrunt run-all apply
   ```

## Komponen Infrastruktur

- **Project GCP**: Membuat dan mengonfigurasi project GCP dengan pengaturan billing dan API yang diperlukan.
- **VPC Network**: Membuat jaringan VPC dengan subnet, firewall rules, dan komponen networking lainnya.

## Implementasi Variabel Map

```hcl
# Di modules/project/variables.tf
variable "project_id" {
  description = "The ID of the project based on environment"
  type        = map(string)
  default = {
    dev = "awanmasterpiece-dev"
    stg = "awanmasterpiece-stg"
    prd = "awanmasterpiece-prd"
  }
}

# Di modules/project/main.tf
resource "google_project" "project" {
  name            = var.project_name[terraform.workspace]
  project_id      = var.project_id[terraform.workspace]
  billing_account = var.billing_account
  
  labels = {
    environment = terraform.workspace
    managed_by  = "terraform"
  }
}
```

## Keuntungan Menggunakan Terragrunt dengan Workspace

1. **DRY (Don't Repeat Yourself)**: Mengurangi duplikasi kode dengan menggunakan konfigurasi yang sama untuk semua lingkungan.
2. **Manajemen State yang Lebih Baik**: State Terraform disimpan terpisah untuk setiap lingkungan dan komponen.
3. **Dependency Management**: Terragrunt menangani dependensi antar modul secara otomatis.
4. **Konsistensi**: Memastikan bahwa konfigurasi yang sama diterapkan di semua lingkungan dengan variabel yang sesuai.
5. **Fleksibilitas Workspace**: Mudah beralih antara lingkungan menggunakan `terragrunt workspace select` atau variabel lingkungan `TF_WORKSPACE`.
