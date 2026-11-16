import 'package:flutter/services.dart';

/// Mengambil nomor versi (tanpa nomor build) dari isi `pubspec.yaml`.
/// Contoh: `version: 2.0.0+2` → `2.0.0`. Null bila tidak ditemukan.
String? versiDariPubspec(String isi) {
  final cocok = RegExp(
    r'^version:\s*([0-9]+(?:\.[0-9]+)*)',
    multiLine: true,
  ).firstMatch(isi);
  return cocok?.group(1);
}

/// Versi aplikasi dibaca dari `pubspec.yaml` yang ikut dibundel sebagai
/// asset, sehingga nomor versi hanya ditulis di SATU tempat dan tidak perlu
/// paket tambahan (package_info_plus).
Future<String?> bacaVersiAplikasi() async {
  try {
    return versiDariPubspec(await rootBundle.loadString('pubspec.yaml'));
  } catch (_) {
    return null;
  }
}
