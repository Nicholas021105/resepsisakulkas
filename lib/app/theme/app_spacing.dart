/// Skala jarak dan radius sudut.
abstract class AppSpacing {
  static const double xs = 4;
  static const double s = 8;
  static const double m = 12;
  static const double l = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  static const double radiusS = 10;
  static const double radiusM = 18;
  static const double radiusL = 28;
  static const double radiusPill = 999;

  /// Target sentuh minimal.
  static const double sentuh = 48;

  /// Tinggi tombol utama.
  static const double tombol = 56;

  /// Sisi sampul resep di kartu daftar.
  static const double sampul = 76;

  /// Lebar isi maksimal agar nyaman dibaca di layar lebar/landscape.
  static const double lebarIsi = 560;
}

/// Durasi dan kurva gerak yang dipakai bersama.
abstract class AppGerak {
  static const cepat = Duration(milliseconds: 160);
  static const sedang = Duration(milliseconds: 260);
  static const lambat = Duration(milliseconds: 480);

  /// Animasi magnet "menempel" ke pintu kulkas.
  static const tempel = Duration(milliseconds: 420);
}
