import 'package:get/get.dart';

import '../../../data/models/katalog_model.dart';
import '../../../data/services/katalog_service.dart';
import '../../../utils/formatter.dart';
import '../../../utils/notifikasi.dart';
import '../../kulkas/controllers/kulkas_controller.dart';

class PengaturanController extends GetxController {
  final KatalogService _katalog = Get.find<KatalogService>();
  final KulkasController kulkas = Get.find<KulkasController>();

  String get labelSumberData =>
      labelSumber(_katalog.sumber.value, _katalog.diperbarui.value);

  /// Versi aplikasi (sama dengan `version` di pubspec.yaml; tanpa package
  /// tambahan untuk membacanya).
  static const versiApp = '1.0.0';

  SumberData get sumber => _katalog.sumber.value;

  bool get memuat => _katalog.memuat.value;

  int get jumlahResep => _katalog.katalog.value?.resep.length ?? 0;

  int get jumlahBahan => _katalog.katalog.value?.bahan.length ?? 0;

  /// Memaksa ambil dari server; bila gagal, data lama tetap dipakai.
  Future<void> perbaruiData() async {
    final sumber = await _katalog.perbarui();
    if (sumber == SumberData.server) {
      tampilkanSukses('Data resep diperbarui dari server');
    } else {
      tampilkanInfo(
        'Server belum bisa dihubungi. Tetap memakai ${sumber.label.toLowerCase()}.',
      );
    }
  }

  void ubahBumbuDasar(bool nilai) => kulkas.bumbuDasarAda.value = nilai;
}
