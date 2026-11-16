import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../routes/app_routes.dart';

/// Tab utama Kulkas · Resep · Favorit · Belanja.
///
/// Setiap tab tetap punya named route dan Binding sendiri (bisa dibuka
/// langsung/deep link), tetapi keempat route itu menampilkan satu cangkang
/// `BerandaView` yang menumpuk semua tab. Berpindah tab hanya mengganti
/// [indexTab]: halaman tidak dibangun ulang, sehingga posisi gulir, teks
/// pencarian, dan filter tiap tab bertahan.
class MainController extends GetxController {
  static const ruteTab = [
    Routes.kulkas,
    Routes.resep,
    Routes.favorit,
    Routes.belanja,
  ];

  static const tabKulkas = 0;
  static const tabResep = 1;
  static const tabFavorit = 2;
  static const tabBelanja = 3;

  final indexTab = 0.obs;

  /// Berpindah tab. Bila sedang berada di halaman lain di atas cangkang
  /// (detail, pengaturan), halaman itu ditutup dulu.
  void pindahTab(int index) {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!ruteTab.contains(Get.currentRoute)) {
      Get.until((rute) => rute.isFirst);
      if (!ruteTab.contains(Get.currentRoute)) {
        // Halaman dibuka langsung tanpa cangkang di bawahnya.
        Get.offAllNamed(ruteTab[index]);
        return;
      }
    }
    indexTab.value = index;
  }

  /// Dipanggil `TabMiddleware`, sehingga tab yang menyala selalu sesuai
  /// route saat dibuka langsung (initialRoute/deep link/`Get.offAllNamed`).
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
