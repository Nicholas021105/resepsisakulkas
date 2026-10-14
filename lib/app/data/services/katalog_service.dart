import 'package:get/get.dart';

import '../models/katalog_model.dart';
import '../repositories/resep_repository.dart';

/// Data resep & bahan global yang hidup selama aplikasi berjalan.
class KatalogService extends GetxService {
  KatalogService(this._repository);

  final ResepRepository _repository;

  final katalog = Rxn<Katalog>();
  final sumber = SumberData.bawaan.obs;
  final diperbarui = Rxn<DateTime>();
  final memuat = false.obs;
  final galat = RxnString();

  @override
  void onInit() {
    super.onInit();
    // Tidak di-await: UI tampil dulu dengan status loading.
    muat();
  }

  Future<void> muat() => _ambil(paksaServer: false);

  /// Memaksa ambil dari server. Mengembalikan sumber yang akhirnya dipakai.
  Future<SumberData> perbarui() async {
    await _ambil(paksaServer: true);
    return sumber.value;
  }

  Future<void> _ambil({required bool paksaServer}) async {
    if (memuat.value) return;
    memuat.value = true;
    galat.value = null;
    try {
      final hasil = await _repository.ambil(paksaServer: paksaServer);
      katalog.value = hasil.katalog;
      sumber.value = hasil.sumber;
      diperbarui.value = hasil.waktu;
    } catch (_) {
      galat.value = 'Data resep gagal dimuat.';
    } finally {
      memuat.value = false;
    }
  }
}
