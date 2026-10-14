/// Konfigurasi server data resep. URL disimpan di SATU konstanta agar mudah
/// diganti setelah repositori GitHub data dibuat (lihat
/// `server_data/README.md`).
abstract class ApiConfig {
  /// Ganti `GANTI_USERNAME` dengan username GitHub pemilik repo data.
  static const urlKatalog =
      'https://raw.githubusercontent.com/GANTI_USERNAME/resep-sisa-kulkas-data/main/resep.json';

  static const timeout = Duration(seconds: 10);

  /// Cache lebih muda dari ini dipakai langsung tanpa menghubungi server.
  static const umurCache = Duration(hours: 24);
}
