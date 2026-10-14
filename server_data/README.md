# Data Resep — ResepSisaKulkas

Folder `server_data/` ini berisi `resep.json`, salinan yang identik dengan `assets/data/resep.json`. File ini yang akan disajikan sebagai "server" lewat GitHub.

## Langkah singkat

1. **Buat repositori.** Login ke GitHub, buat repositori **publik** baru bernama `resep-sisa-kulkas-data`.
2. **Upload data.** Pada repo tersebut pilih **Add file → Upload files**, unggah `resep.json` dari folder ini ke root branch `main`, lalu commit.
3. **Cek URL raw.** Buka alamat berikut di browser (ganti `USERNAME`); isi JSON harus tampil:
   ```
   https://raw.githubusercontent.com/USERNAME/resep-sisa-kulkas-data/main/resep.json
   ```
4. **Ganti URL di app.** Buka `lib/app/data/providers/api_config.dart` dan ganti `GANTI_USERNAME` pada konstanta `ApiConfig.urlKatalog` dengan username GitHub kamu.
5. **Build ulang app** (`flutter build apk --release`). Di app, buka **Pengaturan → Perbarui data**; sumber data akan berubah menjadi "Server · diperbarui …".

## Catatan

- **Bila URL belum diganti atau server gagal** (404, timeout, tidak ada internet), app tetap berjalan. App memakai cache (bila ada) lalu data bawaan, dan sumbernya tampil sebagai "Cache" atau "Data bawaan".
- **Cache.** Data dari server disimpan dan dipakai langsung selama < 24 jam. Tombol **Perbarui data** memaksa pengambilan ulang.
- **Mengubah resep.** Edit `resep.json` di GitHub tanpa perlu build ulang app.
  - Jaga struktur JSON sesuai rencana bagian 5.
  - Setiap `bahanId` di resep harus ada di daftar `bahan`.
  - Jalankan `flutter test test/dataset_test.dart` setelah menyalin perubahan ke asset untuk memeriksa integritasnya.
