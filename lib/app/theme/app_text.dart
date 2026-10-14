import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Bricolage Grotesque (variable; 600 & 800) untuk judul dan angka,
/// DM Sans (variable; 400, 500, 700) untuk teks.
abstract class AppText {
  static const judul = 'BricolageGrotesque';
  static const teks = 'DMSans';

  static TextStyle _gaya(
    String keluarga,
    double ukuran,
    FontWeight berat, {
    double tinggi = 1.35,
    double jarak = 0,
    Color warna = AppColors.tinta,
  }) {
    return TextStyle(
      fontFamily: keluarga,
      fontSize: ukuran,
      fontWeight: berat,
      fontVariations: [FontVariation.weight(berat.value.toDouble())],
      height: tinggi,
      letterSpacing: jarak,
      color: warna,
    );
  }

  static final TextTheme textTheme = TextTheme(
    displayLarge: _gaya(judul, 48, FontWeight.w800, tinggi: 1.05, jarak: -1),
    displayMedium: _gaya(judul, 40, FontWeight.w800, tinggi: 1.05),
    displaySmall: _gaya(judul, 32, FontWeight.w800, tinggi: 1.1),
    headlineLarge: _gaya(judul, 30, FontWeight.w800, tinggi: 1.15),
    headlineMedium: _gaya(judul, 26, FontWeight.w800, tinggi: 1.15),
    headlineSmall: _gaya(judul, 22, FontWeight.w600, tinggi: 1.2),
    titleLarge: _gaya(judul, 20, FontWeight.w600, tinggi: 1.25),
    titleMedium: _gaya(teks, 16, FontWeight.w700),
    titleSmall: _gaya(teks, 14, FontWeight.w700),
    bodyLarge: _gaya(teks, 16, FontWeight.w400, tinggi: 1.5),
    bodyMedium: _gaya(teks, 14, FontWeight.w400, tinggi: 1.5),
    bodySmall: _gaya(teks, 12, FontWeight.w400, warna: AppColors.tintaLembut),
    labelLarge: _gaya(teks, 15, FontWeight.w700),
    labelMedium: _gaya(teks, 13, FontWeight.w500),
    labelSmall: _gaya(teks, 11, FontWeight.w700, jarak: 0.6),
  );

  /// Angka (persen, nomor langkah) dengan angka tabular.
  static TextStyle angka(double ukuran, {Color warna = AppColors.tinta}) =>
      TextStyle(
        fontFamily: judul,
        fontSize: ukuran,
        fontWeight: FontWeight.w800,
        fontVariations: const [FontVariation.weight(800)],
        fontFeatures: const [FontFeature.tabularFigures()],
        color: warna,
        height: 1,
      );
}
