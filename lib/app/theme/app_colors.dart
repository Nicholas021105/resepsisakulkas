import 'package:flutter/painting.dart';

import '../data/models/bahan_model.dart';

/// Palet "Pintu Kulkas". Semua warna UI diambil dari sini.
abstract class AppColors {
  /// Latar beku.
  static const latar = Color(0xFFEEF5F3);
  static const permukaan = Color(0xFFFFFFFF);
  static const tinta = Color(0xFF17322B);

  /// Teks sekunder (kontras ± 6:1 terhadap latar).
  static const tintaLembut = Color(0xFF4A615A);
  static const garis = Color(0xFFD5E3DF);

  /// Hijau mint tua: cincin 100%, ikon ✓.
  static const aksen = Color(0xFF1F8A70);

  /// Hijau lebih gelap untuk tombol & teks agar kontras ≥ 4,5:1
  /// (putih di atas #1F8A70 hanya 4,3:1).
  static const aksenTua = Color(0xFF176B57);
  static const aksenLembut = Color(0xFFD7EEE7);

  /// Oranye wortel: bahan kurang (latar/ikon).
  static const wortel = Color(0xFFF28C28);

  /// Wortel gelap untuk teks kecil (kontras ± 5,5:1).
  static const wortelTeks = Color(0xFFA4520B);
  static const wortelLembut = Color(0xFFFDEBD9);

  /// Cincin persentase: 50–99% dan < 50%.
  static const kuningCincin = Color(0xFFE0A800);
  static const abuCincin = Color(0xFFAFC0BB);

  /// Mint sangat pucat: panel header detail, lingkaran nomor langkah.
  static const mintPucat = Color(0xFFDCF0E9);

  /// Hati favorit aktif (ikon, kontras ± 3,6:1 terhadap latar; ≥ 3:1
  /// untuk elemen grafis).
  static const hatiKoral = Color(0xFFE5484D);

  /// Merah tua untuk aksi berbahaya (kontras ± 6,4:1 terhadap putih).
  static const bahaya = Color(0xFFB42318);
  static const bahayaLembut = Color(0xFFFCE8E6);

  static const putih = Color(0xFFFFFFFF);
  static const bayangan = Color(0x1F17322B);
  static const bayanganTegas = Color(0x4017322B);

  /// Bayangan sangat halus (6%) untuk kartu yang "terangkat".
  static const bayanganHalus = Color(0x0F17322B);
  static const transparan = Color(0x00000000);

  /// Ikon bahan gambar sendiri (IkonBahan).
  static const tahuMuka = Color(0xFFF8E7B4);
  static const tahuAtas = Color(0xFFFFF5DA);
  static const tahuSisi = Color(0xFFE5C987);
  static const tahuGaris = Color(0xFFB8925A);
  static const tempeMuka = Color(0xFF9C6B3F);
  static const tempeAtas = Color(0xFFBA8653);
  static const tempeSisi = Color(0xFF77502D);
  static const tempeTitik = Color(0xFFF1DDB5);
  static const kecapBotol = Color(0xFF3A2418);
  static const kecapKilau = Color(0xFF6B4A36);
  static const kecapLabel = Color(0xFFF6D58E);
  static const kecapTutup = Color(0xFFC0392B);
  static const buncisTua = Color(0xFF2F7D32);
  static const buncisMuda = Color(0xFF7CC35A);
  static const buncisBiji = Color(0xFFB8E39A);
  static const minyakEmas = Color(0xFFF2B705);
  static const minyakTepi = Color(0xFFC58A00);
  static const minyakKilau = Color(0xFFFFE58A);
  static const minyakTutup = Color(0xFF2F6F3E);
  static const bawangMerah = Color(0xFFB5426B);
  static const bawangMerahTua = Color(0xFF7E2148);
  static const bawangMerahKilau = Color(0xFFE38AA8);
  static const bawangPutih = Color(0xFFFAF4E6);
  static const bawangPutihGaris = Color(0xFFC2B08C);
  static const bawangAkar = Color(0xFFB79466);
  static const margarinMuka = Color(0xFFF9DC72);
  static const margarinAtas = Color(0xFFFCEAA8);
  static const margarinSisi = Color(0xFFE2B93B);
  static const tiramBotol = Color(0xFF4A3A30);
  static const tiramLabel = Color(0xFFF3E9D2);
  static const tiramCangkang = Color(0xFF8C8277);

  /// Warna magnet per kategori bahan.
  static Color magnet(KategoriBahan kategori) => switch (kategori) {
    KategoriBahan.protein => const Color(0xFFF4A6A0),
    KategoriBahan.sayur => const Color(0xFF9ED9B3),
    KategoriBahan.karbohidrat => const Color(0xFFF6D58E),
    KategoriBahan.bumbu => const Color(0xFFC3B5E8),
  };

  /// Warna cincin persentase: hijau 100%, kuning 50–99%, abu < 50%.
  static Color cincin(int persen) =>
      persen >= 100 ? aksen : (persen >= 50 ? kuningCincin : abuCincin);
}
