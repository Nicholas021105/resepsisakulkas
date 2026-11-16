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
- **Mengubah resep.** Edit `assets/data/resep.json`, salin ke `server_data/resep.json`, lalu jalankan:
  ```bash
  flutter test test/dataset_test.dart test/kompatibilitas_katalog_test.dart
  ```
  Test memeriksa integritas data, bahwa kedua berkas identik, dan bahwa katalog masih terbaca aplikasi versi lama.

## Skema (katalog versi 2)

Semua field baru bersifat **opsional**. Aplikasi versi 1.0 mengabaikan field yang tidak dikenalnya, dan aplikasi versi 2.0 memakai nilai default bila field tidak ada.

### Bahan

| Field | Wajib | Keterangan |
| --- | --- | --- |
| `id` | ya | kebab-case, unik |
| `nama`, `emoji` | ya | emoji Unicode ≤ 12, atau punya pelukis di `IkonBahan` |
| `kategori` | ya | `protein` \| `sayur` \| `karbohidrat` \| `bumbu` |
| `bumbuDasar` | tidak | default `false`; hanya garam, gula, minyak goreng, air |
| `awetHari` | tidak (baru) | perkiraan hari tetap segar di kulkas. Tanpa nilai = awet, tidak pernah otomatis ditandai "segera habiskan" |

### Resep

| Field | Wajib | Keterangan |
| --- | --- | --- |
| `id`, `nama`, `deskripsi`, `waktuMenit`, `porsi` | ya | |
| `tingkat` | ya | **hanya** `mudah` \| `sedang` |
| `tingkatV2` | tidak (baru) | `sulit`; ditulis bersama `"tingkat": "sedang"` |
| `kategori` | tidak (baru) | `sarapan` \| `lauk` \| `sayur` \| `nasiMie` \| `camilan` \| `pelengkap`. Default: "Lainnya" |
| `sajian` | tidak (baru) | bentuk ilustrasi sampul: `piring` \| `goreng` \| `tumis` \| `kuah` \| `nasi` \| `mie` \| `telur` \| `sambal` \| `manis` \| `roti`. Default `piring` |
| `bahan[]` | ya | `bahanId`, `takaran`, `opsional` (default `false`); 2–10 bahan, minimal 2 wajib |
| `langkah[]` | ya | 3–7 kalimat. Durasi yang ditulis di kalimat ("selama 10 menit", "sekitar 3 menit") otomatis menjadi timer di mode masak |

### Aturan agar versi lama tetap bisa membaca

Aplikasi versi 1.0 membaca `tingkat` dan `kategori` bahan dengan `Enum.values.byName`, yang gagal untuk nilai tak dikenal. Bila gagal, seluruh katalog server ditolak dan aplikasi lama diam-diam kembali ke data bawaannya. Karena itu:

- Jangan menulis `"tingkat": "sulit"`. Tulis `"tingkat": "sedang", "tingkatV2": "sulit"`.
- Jangan menambah nilai `kategori` bahan baru.
- Jangan menghapus atau mengganti nama field yang sudah ada.
- Menambah field opsional baru, resep baru, atau bahan baru (dengan kategori yang ada) aman.

`test/kompatibilitas_katalog_test.dart` meniru pembaca versi 1.0 dan menggagalkan test bila aturan ini dilanggar.
