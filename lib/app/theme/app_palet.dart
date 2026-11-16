import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Warna semantik UI untuk satu tema. Widget TIDAK memakai [AppColors]
/// langsung untuk warna antarmuka, melainkan `context.palet.xxx`, sehingga
/// tema terang dan gelap cukup berbeda di sini.
///
/// Rasio kontras tiap pasangan teks/latar dijaga otomatis oleh
/// `test/kontras_test.dart` (≥ 4,5:1 untuk teks, ≥ 3:1 untuk grafis).
@immutable
class Palet extends ThemeExtension<Palet> {
  const Palet({
    required this.modeGelap,
    required this.latar,
    required this.permukaan,
    required this.permukaanTinggi,
    required this.tinta,
    required this.tintaLembut,
    required this.garis,
    required this.aksen,
    required this.aksenTua,
    required this.diAksen,
    required this.aksenLembut,
    required this.wortel,
    required this.wortelTeks,
    required this.wortelLembut,
    required this.pisang,
    required this.pisangTeks,
    required this.pisangLembut,
    required this.kuningCincin,
    required this.abuCincin,
    required this.mintPucat,
    required this.hatiKoral,
    required this.bahaya,
    required this.bahayaLembut,
    required this.balik,
    required this.diBalik,
    required this.diMagnet,
    required this.kerangka,
    required this.kerangkaKilau,
    required this.bayangan,
    required this.bayanganTegas,
    required this.bayanganHalus,
  });

  final bool modeGelap;

  /// Latar halaman dan permukaan kartu.
  final Color latar;
  final Color permukaan;

  /// Permukaan yang "lebih dekat" ke pengguna (sheet, kartu di atas kartu).
  final Color permukaanTinggi;

  /// Teks utama dan sekunder.
  final Color tinta;
  final Color tintaLembut;
  final Color garis;

  /// Mint: cincin 100%, ikon ✓ (grafis).
  final Color aksen;

  /// Mint untuk tombol isi & teks beraksen, dan teks di atasnya.
  final Color aksenTua;
  final Color diAksen;
  final Color aksenLembut;

  /// Wortel: bahan kurang.
  final Color wortel;
  final Color wortelTeks;
  final Color wortelLembut;

  /// Pisang matang: bahan "segera habiskan".
  final Color pisang;
  final Color pisangTeks;
  final Color pisangLembut;

  final Color kuningCincin;
  final Color abuCincin;
  final Color mintPucat;
  final Color hatiKoral;
  final Color bahaya;
  final Color bahayaLembut;

  /// Permukaan kebalikan (chip terpilih, snackbar) dan teks di atasnya.
  final Color balik;
  final Color diBalik;

  /// Teks di atas magnet berwarna kategori (pastel di kedua tema).
  final Color diMagnet;

  /// Kerangka pemuatan (skeleton) dan kilaunya.
  final Color kerangka;
  final Color kerangkaKilau;

  final Color bayangan;
  final Color bayanganTegas;
  final Color bayanganHalus;

  static const terang = Palet(
    modeGelap: false,
    latar: AppColors.latar,
    permukaan: AppColors.permukaan,
    permukaanTinggi: AppColors.permukaan,
    tinta: AppColors.tinta,
    tintaLembut: AppColors.tintaLembut,
    garis: AppColors.garis,
    aksen: AppColors.aksen,
    aksenTua: AppColors.aksenTua,
    diAksen: AppColors.putih,
    aksenLembut: AppColors.aksenLembut,
    wortel: AppColors.wortel,
    wortelTeks: AppColors.wortelTeks,
    wortelLembut: AppColors.wortelLembut,
    pisang: AppColors.pisang,
    pisangTeks: AppColors.pisangTeks,
    pisangLembut: AppColors.pisangLembut,
    kuningCincin: AppColors.kuningCincin,
    abuCincin: AppColors.abuCincin,
    mintPucat: AppColors.mintPucat,
    hatiKoral: AppColors.hatiKoral,
    bahaya: AppColors.bahaya,
    bahayaLembut: AppColors.bahayaLembut,
    balik: AppColors.tinta,
    diBalik: AppColors.putih,
    diMagnet: AppColors.tinta,
    kerangka: AppColors.garis,
    kerangkaKilau: AppColors.latar,
    bayangan: AppColors.bayangan,
    bayanganTegas: AppColors.bayanganTegas,
    bayanganHalus: AppColors.bayanganHalus,
  );

  static const gelap = Palet(
    modeGelap: true,
    latar: AppColorsGelap.latar,
    permukaan: AppColorsGelap.permukaan,
    permukaanTinggi: AppColorsGelap.permukaanTinggi,
    tinta: AppColorsGelap.tinta,
    tintaLembut: AppColorsGelap.tintaLembut,
    garis: AppColorsGelap.garis,
    aksen: AppColorsGelap.aksen,
    aksenTua: AppColorsGelap.aksenTua,
    diAksen: AppColorsGelap.diAksen,
    aksenLembut: AppColorsGelap.aksenLembut,
    wortel: AppColorsGelap.wortel,
    wortelTeks: AppColorsGelap.wortelTeks,
    wortelLembut: AppColorsGelap.wortelLembut,
    pisang: AppColorsGelap.pisang,
    pisangTeks: AppColorsGelap.pisangTeks,
    pisangLembut: AppColorsGelap.pisangLembut,
    kuningCincin: AppColorsGelap.kuningCincin,
    abuCincin: AppColorsGelap.abuCincin,
    mintPucat: AppColorsGelap.mintPucat,
    hatiKoral: AppColorsGelap.hatiKoral,
    bahaya: AppColorsGelap.bahaya,
    bahayaLembut: AppColorsGelap.bahayaLembut,
    balik: AppColorsGelap.tinta,
    diBalik: AppColorsGelap.latar,
    diMagnet: AppColors.tinta,
    kerangka: AppColorsGelap.garis,
    kerangkaKilau: AppColorsGelap.permukaanTinggi,
    bayangan: AppColorsGelap.bayangan,
    bayanganTegas: AppColorsGelap.bayanganTegas,
    bayanganHalus: AppColorsGelap.bayanganHalus,
  );

  /// Warna cincin persentase: hijau 100%, kuning 50–99%, abu < 50%.
  Color cincin(int persen) =>
      persen >= 100 ? aksen : (persen >= 50 ? kuningCincin : abuCincin);

  /// Bayangan sangat halus untuk kartu yang "terangkat".
  List<BoxShadow> get bayanganKartu => [
    BoxShadow(color: bayanganHalus, blurRadius: 16, offset: const Offset(0, 4)),
  ];

  @override
  Palet copyWith() => this;

  /// Dua palet dirancang terpisah; pergantian tema berpindah di tengah
  /// animasi, bukan mencampur tiap warna.
  @override
  Palet lerp(Palet? lain, double t) => lain == null || t < 0.5 ? this : lain;
}

extension PaletKonteks on BuildContext {
  /// Palet tema yang sedang aktif.
  Palet get palet => Theme.of(this).extension<Palet>() ?? Palet.terang;
}
