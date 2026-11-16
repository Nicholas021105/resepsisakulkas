import 'package:get_storage/get_storage.dart';

/// Cache katalog: isi JSON + waktu diambil dari server.
typedef CacheKatalog = ({Map<String, dynamic> data, DateTime waktu});

/// Pembungkus GetStorage untuk semua data lokal.
///
/// Seluruh pembacaan bersifat defensif: nilai yang hilang atau bertipe salah
/// (data lama, berkas rusak) menghasilkan nilai kosong, tidak pernah
/// melempar. Kunci lama (`bahanDimiliki`, `favorit`, `bumbuDasarAda`,
/// `cacheKatalog`) tidak pernah diganti nama, sehingga data versi 1.0 tetap
/// terbaca; lihat `utils/migrasi_storage.dart`.
class StorageService {
  // Sejak versi 1.0.
  static const kunciKulkas = 'bahanDimiliki';
  static const kunciFavorit = 'favorit';
  static const kunciBumbuDasar = 'bumbuDasarAda';
  static const _kunciCache = 'cacheKatalog';

  // Sejak skema 2 (versi 2.0).
  /// Angka versi skema penyimpanan; tidak ada = skema 1.
  static const kunciSkema = 'versiSkema';

  /// Peta id bahan → tanggal ditempel (ISO 8601).
  static const kunciSejak = 'kulkasSejak';

  /// Id bahan yang ditandai manual "segera habiskan".
  static const kunciSegera = 'segeraHabiskan';

  /// Daftar belanja: daftar peta `ItemBelanja`.
  static const kunciBelanja = 'daftarBelanja';

  /// Riwayat masak: daftar peta `CatatanMasak`, terbaru dulu.
  static const kunciRiwayat = 'riwayatMasak';

  /// 'sistem' | 'terang' | 'gelap'.
  static const kunciTema = 'modeTema';
  static const kunciOnboarding = 'sudahOnboarding';

  GetStorage get _box => GetStorage();

  /// Dua primitif baca/tulis; pembantu bertipe di bawah dibangun di atasnya.
  dynamic bacaMentah(String kunci) => _box.read<dynamic>(kunci);

  Future<void> tulisMentah(String kunci, dynamic nilai) =>
      _box.write(kunci, nilai);

  Set<String> bacaSet(String kunci) {
    final isi = bacaMentah(kunci);
    return isi is Iterable ? isi.whereType<String>().toSet() : <String>{};
  }

  Future<void> simpanSet(String kunci, Set<String> isi) =>
      tulisMentah(kunci, isi.toList());

  bool? bacaBool(String kunci) {
    final isi = bacaMentah(kunci);
    return isi is bool ? isi : null;
  }

  Future<void> simpanBool(String kunci, bool nilai) =>
      tulisMentah(kunci, nilai);

  String? bacaTeks(String kunci) {
    final isi = bacaMentah(kunci);
    return isi is String ? isi : null;
  }

  Future<void> simpanTeks(String kunci, String nilai) =>
      tulisMentah(kunci, nilai);

  int? bacaAngka(String kunci) {
    final isi = bacaMentah(kunci);
    return isi is int ? isi : null;
  }

  Future<void> simpanAngka(String kunci, int nilai) =>
      tulisMentah(kunci, nilai);

  /// Peta teks → teks; entri bertipe lain dilewati.
  Map<String, String> bacaPetaTeks(String kunci) {
    final isi = bacaMentah(kunci);
    if (isi is! Map) return {};
    return {
      for (final e in isi.entries)
        if (e.key is String && e.value is String)
          e.key as String: e.value as String,
    };
  }

  Future<void> simpanPetaTeks(String kunci, Map<String, String> isi) =>
      tulisMentah(kunci, {...isi});

  /// Daftar peta (objek JSON); elemen bertipe lain dilewati.
  List<Map<String, dynamic>> bacaDaftarPeta(String kunci) {
    final isi = bacaMentah(kunci);
    if (isi is! Iterable) return [];
    return [
      for (final e in isi)
        if (e is Map) Map<String, dynamic>.from(e),
    ];
  }

  Future<void> simpanDaftarPeta(String kunci, List<Map<String, dynamic>> isi) =>
      tulisMentah(kunci, isi);

  CacheKatalog? bacaCache() {
    final isi = bacaMentah(_kunciCache);
    if (isi is! Map) return null;
    final teksWaktu = isi['waktu'];
    final waktu = DateTime.tryParse(teksWaktu is String ? teksWaktu : '');
    final data = isi['data'];
    if (waktu == null || data is! Map) return null;
    return (data: Map<String, dynamic>.from(data), waktu: waktu);
  }

  Future<void> simpanCache(Map<String, dynamic> data, DateTime waktu) =>
      tulisMentah(_kunciCache, {
        'waktu': waktu.toIso8601String(),
        'data': data,
      });
}
