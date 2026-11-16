import '../data/services/storage_service.dart';

/// Versi skema penyimpanan lokal yang dipahami aplikasi ini.
///
/// - Skema 1 (app 1.0): `bahanDimiliki`, `favorit`, `bumbuDasarAda`,
///   `cacheKatalog`.
/// - Skema 2 (app 2.0): menambah `kulkasSejak`, `segeraHabiskan`,
///   `daftarBelanja`, `riwayatMasak`, `modeTema`, `sudahOnboarding`.
///   Tidak ada kunci lama yang diubah atau dihapus.
const versiSkemaSekarang = 2;

/// Menaikkan data lama ke skema sekarang. Aman dipanggil berulang kali dan
/// tidak pernah menghapus kulkas, favorit, opsi bumbu dasar, maupun cache.
///
/// Dari skema 1:
/// - bahan yang sudah ada di kulkas diberi tanggal tempel [sekarang]
///   (tanggal aslinya tidak diketahui, jadi dihitung "baru" agar tidak
///   langsung ditandai segera habis);
/// - pengguna lama tidak perlu melihat onboarding.
///
/// Di setiap skema, data turunan dirapikan: tanda "segera" dan tanggal
/// tempel untuk bahan yang sudah tidak ada di kulkas dibuang.
Future<void> migrasiStorage(
  StorageService storage, {
  required DateTime sekarang,
}) async {
  final skema = storage.bacaAngka(StorageService.kunciSkema) ?? 1;
  final kulkas = storage.bacaSet(StorageService.kunciKulkas);

  if (skema < 2) {
    final punyaDataLama =
        kulkas.isNotEmpty ||
        storage.bacaSet(StorageService.kunciFavorit).isNotEmpty ||
        storage.bacaBool(StorageService.kunciBumbuDasar) != null ||
        storage.bacaCache() != null;
    if (punyaDataLama &&
        storage.bacaBool(StorageService.kunciOnboarding) == null) {
      await storage.simpanBool(StorageService.kunciOnboarding, true);
    }
  }

  // Lengkapi & rapikan tanggal tempel.
  final sejak = storage.bacaPetaTeks(StorageService.kunciSejak);
  final sejakBaru = {
    for (final id in kulkas)
      id: DateTime.tryParse(sejak[id] ?? '') == null
          ? sekarang.toIso8601String()
          : sejak[id]!,
  };
  if (!_petaSama(sejak, sejakBaru)) {
    await storage.simpanPetaTeks(StorageService.kunciSejak, sejakBaru);
  }

  // Tanda "segera" hanya berlaku untuk bahan yang masih di kulkas.
  final segera = storage.bacaSet(StorageService.kunciSegera);
  final segeraBaru = segera.intersection(kulkas);
  if (segeraBaru.length != segera.length) {
    await storage.simpanSet(StorageService.kunciSegera, segeraBaru);
  }

  if (skema != versiSkemaSekarang) {
    await storage.simpanAngka(StorageService.kunciSkema, versiSkemaSekarang);
  }
}

bool _petaSama(Map<String, String> a, Map<String, String> b) =>
    a.length == b.length && a.entries.every((e) => b[e.key] == e.value);
