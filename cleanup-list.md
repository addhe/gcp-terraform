# Daftar State Files untuk Dibersihkan Setelah 8 April 2025
State files yang perlu dibersihkan setelah retention period berakhir pada 8 April 2025:

## Folder Lama yang Menggunakan Pendekatan Workspace
1. gs://awanmasterpiece-terraform-state/terragrunt/project/* 
   - Semua file state di folder project lama
   - Digantikan oleh folder-based structure: gs://awanmasterpiece-terraform-state/terragrunt/dev|stg|prd/project/

2. gs://awanmasterpiece-terraform-state/terragrunt/vpc/*
   - Semua file state di folder vpc lama
   - Digantikan oleh folder-based structure: gs://awanmasterpiece-terraform-state/terragrunt/dev|stg|prd/vpc/

3. gs://awanmasterpiece-terraform-state/dev/*
   - File state yang ditempatkan langsung di folder dev

## Perintah Untuk Membersihkan State (Jalankan Setelah 8 April 2025)
```bash
# Hapus folder project lama
gsutil rm -r gs://awanmasterpiece-terraform-state/terragrunt/project/

# Hapus folder vpc lama
gsutil rm -r gs://awanmasterpiece-terraform-state/terragrunt/vpc/

# Hapus folder dev lama
gsutil rm -r gs://awanmasterpiece-terraform-state/dev/
```

> **Catatan**: File state ini tidak dapat dihapus sampai retention period berakhir (10 hari setelah pembuatan).
> Jika Anda ingin mengubah kebijakan retensi bucket, gunakan perintah berikut:
> `gsutil retention set [DURATION] gs://awanmasterpiece-terraform-state`
> 
> Namun sangat disarankan untuk tetap mempertahankan policy retention untuk mencegah penghapusan state secara tidak sengaja.
