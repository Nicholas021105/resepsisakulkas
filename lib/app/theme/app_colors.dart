import 'package:flutter/painting.dart';

import '../data/models/bahan_model.dart';

/// Palet "Pintu Kulkas", nilai mentah tema TERANG, ditambah warna ilustrasi
/// (ikon bahan, sampul resep) yang sama di kedua tema.
///
/// Widget tidak memakai kelas ini untuk warna antarmuka; pakai
/// `context.palet` (lihat `app_palet.dart`) agar ikut tema gelap.
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

  /// Pisang matang: bahan "segera habiskan" (ikon/garis).
  static const pisang = Color(0xFFE0A800);

  /// Cokelat pisang untuk teks (± 6,9:1 di putih, ± 6,2:1 di pisangLembut).
  static const pisangTeks = Color(0xFF7A5200);
  static const pisangLembut = Color(0xFFFFF3CC);

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

  /// Warna magnet per kategori bahan (pastel yang sama di kedua tema; teks
  /// di atasnya selalu `palet.diMagnet`).
  static Color magnet(KategoriBahan kategori) => switch (kategori) {
    KategoriBahan.protein => const Color(0xFFF4A6A0),
    KategoriBahan.sayur => const Color(0xFF9ED9B3),
    KategoriBahan.karbohidrat => const Color(0xFFF6D58E),
    KategoriBahan.bumbu => const Color(0xFFC3B5E8),
  };
}

/// Palet "Dapur Malam", nilai mentah tema GELAP. Bukan warna terang yang
/// dibalik: latar hijau-arang seperti dapur dengan lampu kulkas menyala,
/// permukaan naik bertingkat (latar → permukaan → permukaanTinggi), dan
/// aksen mint dibuat lebih terang agar tetap terbaca.
///
/// Kontras (dihitung dan dijaga di `test/kontras_test.dart`):
/// - tinta di latar ± 15:1, di permukaan ± 13:1
/// - tintaLembut di latar ± 8,7:1, di permukaanTinggi ± 6,6:1
/// - diAksen di aksenTua ± 9:1 (tombol isi)
/// - wortelTeks di wortelLembut ± 8:1, pisangTeks di pisangLembut ± 9:1
/// - bahaya di permukaan ± 6,9:1
abstract class AppColorsGelap {
  static const latar = Color(0xFF0E1A17);
  static const permukaan = Color(0xFF162622);
  static const permukaanTinggi = Color(0xFF1E322D);
  static const tinta = Color(0xFFE6F2EE);
  static const tintaLembut = Color(0xFFA3BBB4);
  static const garis = Color(0xFF2A403A);

  /// Mint terang: cincin 100%, ikon ✓.
  static const aksen = Color(0xFF4CC9A7);

  /// Mint untuk tombol isi dan teks beraksen; teks di atasnya hijau-arang.
  static const aksenTua = Color(0xFF5FD4B3);
  static const diAksen = Color(0xFF06231B);
  static const aksenLembut = Color(0xFF1D3D34);

  static const wortel = Color(0xFFF5A04E);
  static const wortelTeks = Color(0xFFFFB877);
  static const wortelLembut = Color(0xFF3D2A17);

  static const pisang = Color(0xFFF0C23A);
  static const pisangTeks = Color(0xFFFFD866);
  static const pisangLembut = Color(0xFF3A3013);

  static const kuningCincin = Color(0xFFF0C23A);

  /// Abu cincin < 50% (grafis ≥ 3:1 di permukaan).
  static const abuCincin = Color(0xFF6F8780);
  static const mintPucat = Color(0xFF1B332C);
  static const hatiKoral = Color(0xFFFF6B6F);

  /// Salmon untuk aksi berbahaya di latar gelap.
  static const bahaya = Color(0xFFFF8A80);
  static const bahayaLembut = Color(0xFF3F1F1C);

  /// Di tema gelap kedalaman datang dari tingkat permukaan dan garis;
  /// bayangan hanya penegas.
  static const bayangan = Color(0x66000000);
  static const bayanganTegas = Color(0x99000000);
  static const bayanganHalus = Color(0x33000000);
}
