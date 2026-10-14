import 'package:get/get.dart';

import '../../../controllers/main_controller.dart';
import '../../../data/models/bahan_model.dart';
import '../../../data/models/hasil_cocok.dart';
import '../../../data/services/katalog_service.dart';
import '../../../utils/pencocok_resep.dart';
import '../../favorit/controllers/favorit_controller.dart';
import '../../kulkas/controllers/kulkas_controller.dart';

/// Detail resep dari route dinamis `/resep/:id`.
class DetailResepController extends GetxController {
  final KatalogService _katalog = Get.find<KatalogService>();
  final KulkasController _kulkas = Get.find<KulkasController>();
  final FavoritController _favorit = Get.find<FavoritController>();

  late final String id;
  final hasil = Rxn<HasilCocok>();

  @override
  void onInit() {
    super.onInit();
    id = Get.parameters['id'] ?? '';
    everAll([
      _katalog.katalog,
      _kulkas.bahanDimiliki,
      _kulkas.bumbuDasarAda,
    ], (_) => _hitung());
    _hitung();
  }

  /// Katalog sudah termuat (bila belum, tampilkan loading, bukan "tidak
  /// ditemukan").
  bool get katalogSiap => _katalog.katalog.value != null;

  Map<String, Bahan> get bahanById =>
      _katalog.katalog.value?.bahanById ?? const {};

  bool get favorit => _favorit.favorit.contains(id);

  void toggleFavorit() => _favorit.toggle(id, nama: hasil.value?.resep.nama);

  /// Kembali ke halaman sebelumnya; bila dibuka langsung (tanpa riwayat),
  /// ke halaman Kulkas.
  void kembali() => Get.find<MainController>().kembali();

  /// Bahan dianggap dimiliki: ada di kulkas, atau bumbu dasar saat opsi aktif.
  bool dimiliki(String bahanId) =>
      _kulkas.bahanDimiliki.contains(bahanId) ||
      (_kulkas.bumbuDasarAda.value &&
          (bahanById[bahanId]?.bumbuDasar ?? false));

  void _hitung() {
    final katalog = _katalog.katalog.value;
    final resep = katalog?.resepById(id);
    hasil.value = resep == null
        ? null
        : cocokkanResep(
            resep,
            _kulkas.bahanDimiliki,
            katalog!.bahanById,
            bumbuDasarAda: _kulkas.bumbuDasarAda.value,
          );
  }
}
