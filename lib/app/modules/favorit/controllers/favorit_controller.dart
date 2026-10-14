import 'package:get/get.dart';

import '../../../data/models/hasil_cocok.dart';
import '../../../data/services/storage_service.dart';
import '../../../utils/notifikasi.dart';
import '../../kulkas/controllers/kulkas_controller.dart';

/// Resep favorit. Permanent agar ikon favorit konsisten di semua halaman.
class FavoritController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();

  final favorit = <String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    favorit.assignAll(_storage.bacaSet(StorageService.kunciFavorit));
    ever(
      favorit,
      (isi) => _storage.simpanSet(StorageService.kunciFavorit, isi),
    );
  }

  bool isFavorit(String id) => favorit.contains(id);

  void toggle(String id, {String? nama}) {
    final judul = nama ?? 'Resep';
    if (favorit.remove(id)) {
      tampilkanInfo('$judul dihapus dari favorit');
    } else {
      favorit.add(id);
      tampilkanSukses('$judul disimpan ke favorit');
    }
  }

  /// Resep favorit beserta kecocokannya dengan isi kulkas saat ini.
  List<HasilCocok> get resepFavorit => Get.find<KulkasController>().semuaHasil
      .where((h) => favorit.contains(h.resep.id))
      .toList();
}
