import 'package:get/get.dart';

import '../../../data/models/belanja_model.dart';
import '../../../data/models/resep_model.dart';
import '../../../data/services/storage_service.dart';

/// Riwayat masak (terbaru dulu). Permanent: ditulis mode masak, dibaca
/// halaman detail dan tab Favorit.
class RiwayatController extends GetxController {
  RiwayatController({DateTime Function()? jam}) : _jam = jam ?? DateTime.now;

  /// Catatan terlama dibuang setelah sebanyak ini.
  static const maksCatatan = 100;

  final StorageService _storage = Get.find<StorageService>();
  final DateTime Function() _jam;

  final riwayat = <CatatanMasak>[].obs;

  @override
  void onInit() {
    super.onInit();
    final tersimpan = [
      for (final json in _storage.bacaDaftarPeta(StorageService.kunciRiwayat))
        ?CatatanMasak.cobaDariJson(json),
    ]..sort((a, b) => b.waktu.compareTo(a.waktu));
    riwayat.assignAll(tersimpan.take(maksCatatan));
    ever(
      riwayat,
      (isi) => _storage.simpanDaftarPeta(StorageService.kunciRiwayat, [
        for (final c in isi) c.toJson(),
      ]),
    );
  }

  DateTime get sekarang => _jam();

  /// Mencatat satu kali memasak [resep] sekarang.
  CatatanMasak catat(Resep resep) {
    final catatan = CatatanMasak(
      resepId: resep.id,
      nama: resep.nama,
      waktu: _jam(),
    );
    riwayat.insert(0, catatan);
    if (riwayat.length > maksCatatan) {
      riwayat.removeRange(maksCatatan, riwayat.length);
    }
    return catatan;
  }

  /// Berapa kali resep ini pernah dimasak.
  int jumlahMasak(String resepId) =>
      riwayat.where((c) => c.resepId == resepId).length;

  void hapusSemua() => riwayat.clear();
}
