# GCP Infrastructure Foundation

Repositori ini berisi konfigurasi Terraform untuk membuat dan mengelola infrastruktur dasar di Google Cloud Platform (GCP).

## Struktur Direktori

```
.
├── modules/                  # Modul-modul Terraform yang dapat digunakan kembali
│   ├── project/              # Modul untuk membuat dan mengelola project GCP
│   └── vpc/                  # Modul untuk membuat dan mengelola VPC
├── environments/             # Konfigurasi untuk lingkungan yang berbeda
│   ├── dev/                  # Lingkungan development
│   ├── staging/              # Lingkungan staging
│   └── prod/                 # Lingkungan production
├── .gitignore                # File untuk mengabaikan file-file tertentu dalam Git
├── backend.tf                # Konfigurasi backend untuk menyimpan state Terraform
├── provider.tf               # Konfigurasi provider GCP
├── variables.tf              # Variabel input untuk root module
└── README.md                 # Dokumentasi proyek
```

## Prasyarat

- [Terraform](https://www.terraform.io/downloads.html) (v1.0.0+)
- [Google Cloud SDK](https://cloud.google.com/sdk/docs/install)
- Akun Google Cloud dengan akses yang sesuai

## Cara Penggunaan

1. Autentikasi ke Google Cloud:
   ```
   gcloud auth application-default login
   ```

2. Inisialisasi Terraform:
   ```
   terraform init
   ```

3. Lihat perubahan yang akan diterapkan:
   ```
   terraform plan
   ```

4. Terapkan perubahan:
   ```
   terraform apply
   ```

## Komponen Infrastruktur

- **Project GCP**: Membuat dan mengonfigurasi project GCP dengan pengaturan billing dan API yang diperlukan.
- **VPC Network**: Membuat jaringan VPC dengan subnet, firewall rules, dan komponen networking lainnya.
