import 'package:get/get.dart';

import '../routes/app_routes.dart';

/// Index bottom navigation Kulkas · Resep · Favorit. Setiap tab adalah
/// named route sendiri (dengan Binding sendiri).
class MainController extends GetxController {
  static const ruteTab = [Routes.kulkas, Routes.resep, Routes.favorit];

  final indexTab = 0.obs;

  void pindahTab(int index) {
    if (index == indexTab.value) return;
    indexTab.value = index;
    Get.offAllNamed(ruteTab[index]);
  }

  /// Dipanggil Binding tiap halaman tab, sehingga tab yang menyala selalu
  /// sesuai route, juga saat route dibuka langsung (initialRoute/deep link)
  /// atau lewat `Get.offAllNamed` di luar [pindahTab].
  void setelTab(int index) => indexTab.value = index;

  /// Kembali ke halaman sebelumnya; bila tidak ada riwayat (halaman dibuka
  /// langsung), ke halaman Kulkas.
  void kembali() {
    if (Get.key.currentState?.canPop() ?? false) {
      Get.back(closeOverlays: true);
    } else {
      Get.offAllNamed(Routes.kulkas);
    }
  }
}
