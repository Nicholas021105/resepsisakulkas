import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../data/services/storage_service.dart';
import '../../../routes/app_routes.dart';
import '../../../theme/app_spacing.dart';

/// Pengenalan singkat tiga layar untuk pemasangan baru. Setelah selesai
/// atau dilewati, tidak tampil lagi (bisa dibuka ulang dari Pengaturan).
class OnboardingController extends GetxController {
  static const jumlahHalaman = 3;

  final StorageService _storage = Get.find<StorageService>();

  final pageController = PageController();
  final halaman = 0.obs;

  bool get terakhir => halaman.value == jumlahHalaman - 1;

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  void halamanBerubah(int index) => halaman.value = index;

  void lanjut() {
    HapticFeedback.lightImpact();
    if (terakhir) {
      selesai();
      return;
    }
    if (MediaQuery.disableAnimationsOf(Get.context!)) {
      pageController.jumpToPage(halaman.value + 1);
    } else {
      pageController.nextPage(
        duration: AppGerak.sedang,
        curve: Curves.easeOutCubic,
      );
    }
  }

  /// Menandai pengenalan sudah dilihat, lalu membuka halaman Kulkas.
  void selesai() {
    _storage.simpanBool(StorageService.kunciOnboarding, true);
    Get.offAllNamed(Routes.kulkas);
  }
}
