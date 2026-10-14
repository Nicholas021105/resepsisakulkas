import 'package:get/get.dart';

import '../../../data/models/hasil_cocok.dart';
import '../../../data/services/katalog_service.dart';
import '../../../utils/pencocok_resep.dart';
import '../../kulkas/controllers/kulkas_controller.dart';

/// Daftar resep cocok dengan empat status StateMixin:
/// loading (katalog belum ada), error (gagal muat), empty, success.
class ResepController extends GetxController with StateMixin<List<HasilCocok>> {
  final KulkasController _kulkas = Get.find<KulkasController>();
  final KatalogService _katalog = Get.find<KatalogService>();

  final filter = FilterHasil.siap.obs;

  @override
  void onInit() {
    super.onInit();
    everAll([
      _kulkas.bahanDimiliki,
      _kulkas.bumbuDasarAda,
      filter,
      _katalog.katalog,
      _katalog.galat,
    ], (_) => hitungUlang());
    hitungUlang();
  }

  /// Jumlah resep per filter (untuk label chip).
  Map<FilterHasil, int> get jumlahPerFilter {
    final semua = _kulkas.semuaHasil;
    return {
      for (final f in FilterHasil.values)
        f: saringHasil(semua, f, kulkasKosong: _kulkas.kulkasKosong).length,
    };
  }

  void pilihFilter(FilterHasil f) => filter.value = f;

  /// Katalog gagal dimuat (status error). Dibaca dari Rx agar bisa dipakai
  /// di Obx (status StateMixin bukan observable Obx).
  bool get gagalMuat =>
      _katalog.katalog.value == null && _katalog.galat.value != null;

  void hitungUlang() {
    final galat = _katalog.galat.value;
    if (_katalog.katalog.value == null) {
      change(
        null,
        status: galat != null ? RxStatus.error(galat) : RxStatus.loading(),
      );
      return;
    }
    final hasil = saringHasil(
      _kulkas.semuaHasil,
      filter.value,
      kulkasKosong: _kulkas.kulkasKosong,
    );
    change(
      hasil,
      status: hasil.isEmpty ? RxStatus.empty() : RxStatus.success(),
    );
  }

  /// Dipanggil tombol "Coba lagi" pada status error.
  Future<void> cobaLagi() async {
    change(null, status: RxStatus.loading());
    await _katalog.muat();
    hitungUlang();
  }
}
