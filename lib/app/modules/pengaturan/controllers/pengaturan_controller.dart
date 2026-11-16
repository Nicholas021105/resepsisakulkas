import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/tema_controller.dart';
import '../../../data/models/katalog_model.dart';
import '../../../data/services/katalog_service.dart';
import '../../../utils/formatter.dart';
import '../../../utils/info_aplikasi.dart';
import '../../../utils/notifikasi.dart';
import '../../kulkas/controllers/kulkas_controller.dart';

class PengaturanController extends GetxController {
  final KatalogService _katalog = Get.find<KatalogService>();
  final KulkasController kulkas = Get.find<KulkasController>();
  final TemaController _tema = Get.find<TemaController>();

  /// Versi aplikasi, dibaca dari `pubspec.yaml` (satu sumber kebenaran).
  final versiApp = RxnString();

  @override
  void onInit() {
    super.onInit();
    bacaVersiAplikasi().then((v) => versiApp.value = v);
  }

  String get labelSumberData =>
      labelSumber(_katalog.sumber.value, _katalog.diperbarui.value);

  SumberData get sumber => _katalog.sumber.value;

  bool get memuat => _katalog.memuat.value;

  int get jumlahResep => _katalog.katalog.value?.resep.length ?? 0;

  int get jumlahBahan => _katalog.katalog.value?.bahan.length ?? 0;

  ThemeMode get modeTema => _tema.mode.value;

  void ubahTema(ThemeMode mode) => _tema.ubah(mode);

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
