/// Konfigurasi server data resep. URL disimpan di SATU konstanta.
abstract class ApiConfig {
  /// Data server diambil dari folder `server_data/` di repo app ini sendiri
  /// (github.com/Nicholas021105/resepsisakulkas), lewat raw.githubusercontent.com.
  /// Cukup edit lalu push `server_data/resep.json` untuk memperbarui resep
  /// tanpa build ulang app (lihat `server_data/README.md`).
  static const urlKatalog =
      'https://raw.githubusercontent.com/Nicholas021105/resepsisakulkas/main/server_data/resep.json';

  static const timeout = Duration(seconds: 10);

  /// Cache lebih muda dari ini dipakai langsung tanpa menghubungi server.
  static const umurCache = Duration(hours: 24);
}
