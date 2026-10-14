# Data Resep — ResepSisaKulkas

Folder `server_data/` ini berisi `resep.json`, salinan yang identik dengan `assets/data/resep.json`. File ini yang disajikan sebagai "server" lewat GitHub, langsung dari repo app ini. Tidak perlu repo data terpisah.

## Langkah singkat

1. **Cukup push repo ini** (`git push`, branch `main`, repo publik `Nicholas021105/resepsisakulkas`). App membaca `server_data/resep.json` lewat raw.githubusercontent.com.
2. **Cek URL raw.** Buka alamat berikut di browser; isi JSON harus tampil:
   ```
   https://raw.githubusercontent.com/Nicholas021105/resepsisakulkas/main/server_data/resep.json
   ```
   URL ini sudah tertulis di `ApiConfig.urlKatalog` (`lib/app/data/providers/api_config.dart`).
3. **Di app**, buka **Pengaturan → Perbarui data**. Sumber data akan berubah menjadi "Server · diperbarui …".

## Catatan

- **Bila server gagal** (404, timeout, tidak ada internet), app tetap berjalan. App memakai cache (bila ada) lalu data bawaan, dan sumbernya tampil sebagai "Cache" atau "Data bawaan".
- **Cache.** Data dari server disimpan dan dipakai langsung selama < 24 jam. Tombol **Perbarui data** memaksa pengambilan ulang.
- **Mengubah resep.** Edit `resep.json` di GitHub tanpa perlu build ulang app.
  - Jaga struktur JSON sesuai rencana bagian 5.
  - Setiap `bahanId` di resep harus ada di daftar `bahan`.
  - Jalankan `flutter test test/dataset_test.dart` setelah menyalin perubahan ke asset untuk memeriksa integritasnya.
