# ResepSisaKulkas

Tempel bahan yang ada di kulkas seperti magnet di pintunya, lalu temukan resep rumahan Indonesia yang bisa langsung dimasak. Aplikasi Flutter + GetX, berjalan penuh tanpa internet.

## Fitur

**Kulkas**
- Ketuk magnet untuk menempel atau melepas bahan. Semua tersimpan otomatis.
- Tekan lama magnet untuk menandai bahan **segera habiskan**. Bahan segar juga ditandai otomatis saat mendekati masa simpannya (tanggal tempel dicatat).
- Banner kuning merangkum bahan yang segera habis dan membuka resep yang memakainya.

**Resep**
- 60 resep dicocokkan dengan isi kulkas: persentase = bahan wajib yang dimiliki ÷ bahan wajib.
- Resep yang memakai bahan segera habis (dan kurang paling banyak 2 bahan) naik ke urutan teratas dengan label "Pakai … yang segera habis".
- Cari berdasarkan nama resep atau bahan, urutkan (paling cocok, tercepat, termudah), saring per kategori hidangan dan per kecocokan.
- Kartu **Masak apa hari ini?** memberi satu saran per hari; "Saran lain" menggantinya.
- Setiap resep punya sampul yang digambar dengan kode, bukan foto.

**Daftar belanja**
- Tambahkan bahan yang kurang dari kartu atau halaman resep, atau pilih sendiri.
- Centang saat dibeli: bahan langsung masuk kulkas. Daftar bisa disalin ke aplikasi chat.

**Mode masak**
- Satu langkah per layar dengan huruf besar dan batang kemajuan.
- Timer muncul otomatis pada langkah yang menyebut durasi ("selama 10 menit"); getar dan bunyi saat habis.
- Di akhir, pilih bahan yang habis untuk dilepas dari kulkas. Masakan tercatat di riwayat (tab Favorit).

**Lainnya**
- Tema terang "Pintu Kulkas" dan tema gelap "Dapur Malam", atau ikuti sistem.
- Pengenalan tiga layar untuk pemasangan baru.
- Tab mempertahankan posisi gulir, pencarian, dan filter.

## Menjalankan

```bash
flutter pub get
flutter run
```

Membutuhkan Flutter 3.47 / Dart 3.13 atau lebih baru.

## Pemeriksaan

```bash
flutter analyze
flutter test                    # unit + widget test
flutter test screenshot_test/   # merender semua halaman ke ../screenshots/resepsisakulkas/
```

Yang dijaga test:

| Berkas | Isi |
| --- | --- |
| `pencocok_resep_test`, `kesegaran_test`, `jelajah_resep_test` | persentase, peringkat bahan segera habis, pencarian, urutan, saran |
| `belanja_test`, `masak_test` | daftar belanja, timer, pengurangan stok, riwayat |
| `migrasi_storage_test` | data versi 1.0 tetap utuh, pembacaan data rusak tidak membuat crash |
| `dataset_test`, `kompatibilitas_katalog_test` | integritas `resep.json`, kedua salinan identik, tetap terbaca aplikasi versi 1.0 |
| `kontras_test` | kontras WCAG kedua palet (teks ≥ 4,5:1, grafis ≥ 3:1) |
| `overflow_semua_halaman_test` | semua halaman di 4 ukuran layar × skala huruf × data ekstrem, tanpa overflow |

## Arsitektur

GetX penuh: named route dan `Binding` per modul, `StateMixin` di daftar resep, `GetConnect` sebagai satu-satunya akses jaringan, `get_storage` untuk data lokal.

```
lib/app/
  bindings/      InitialBinding: service dan controller permanen
  controllers/   MainController (tab), TemaController
  data/          models, providers (GetConnect), repositories, services
  modules/       beranda (cangkang tab), kulkas, resep, detail_resep,
                 belanja, favorit (+ riwayat), masak, onboarding, pengaturan
  routes/        AppPages, Routes
  theme/         AppColors (nilai mentah), Palet (warna semantik per tema),
                 AppSpacing, AppText, AppTheme
  utils/         logika murni: pencocok_resep, kesegaran, daftar_belanja,
                 durasi_langkah, migrasi_storage
  widgets/       magnet, ikon bahan, sampul resep, kartu resep, kerangka
```

Beberapa keputusan:

- **Tab.** `/kulkas`, `/resep`, `/favorit`, dan `/belanja` tetap named route dengan Binding masing-masing, tetapi semuanya menampilkan satu cangkang `BerandaView` yang menumpuk keempat tab. Berpindah tab hanya mengganti index, sehingga state tab bertahan.
- **Tema.** Widget memakai `context.palet.xxx` (sebuah `ThemeExtension`), tidak pernah warna langsung. Palet gelap dirancang terpisah, bukan warna terang yang dibalik.
- **Logika di `utils/`.** Pencocokan, kesegaran, daftar belanja, dan durasi langkah berupa fungsi murni, sehingga bisa diuji tanpa widget.

## Data resep

Katalog dimuat dengan urutan: server → cache (24 jam) → data bawaan.

- Bawaan: `assets/data/resep.json`
- Server: `server_data/resep.json`, diambil lewat `raw.githubusercontent.com`. Kedua berkas harus identik (dijaga test).

Cara memperbarui resep dan aturan kompatibilitas skema ada di [`server_data/README.md`](server_data/README.md).

## Data lokal

Disimpan di `get_storage`. Kunci versi 1.0 (`bahanDimiliki`, `favorit`, `bumbuDasarAda`, `cacheKatalog`) tidak diubah. Versi 2.0 menambah `kulkasSejak`, `segeraHabiskan`, `daftarBelanja`, `riwayatMasak`, `modeTema`, `sudahOnboarding`, dan `versiSkema`. `migrasiStorage` dijalankan saat aplikasi dibuka.

## Batasan yang diketahui

- Timer hanya berjalan selama aplikasi terbuka; tidak ada notifikasi lokal.
- Layar tidak ditahan tetap menyala saat mode masak (perlu paket tambahan).
- Kulkas mencatat ada atau tidak ada, bukan jumlah bahan.

## Ikon aplikasi

Sumber ikon ada di `assets/ikon/`. Setelah mengganti `ikon_app.png` atau `ikon_depan.png`, buat ulang ikon launcher Android:

```bash
dart run flutter_launcher_icons
```

Konfigurasinya di `pubspec.yaml` (bagian `flutter_launcher_icons`). Hanya `ikon_app.png` yang ikut dibundel ke dalam app.
