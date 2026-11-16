import 'package:get/get.dart';

import '../../controllers/main_controller.dart';

/// Menyalakan tab yang sesuai saat salah satu route tab dibuka langsung
/// (initialRoute, deep link, `Get.offAllNamed`).
///
/// Dilakukan di `onPageCalled` (saat navigasi dipanggil), bukan di Binding:
/// Binding berjalan di tengah fase build, dan mengubah Rx di sana akan
/// memicu rebuild cangkang lama yang sedang dibuang.
class TabMiddleware extends GetMiddleware {
  TabMiddleware(this.tab);

  final int tab;

  @override
  GetPage<dynamic>? onPageCalled(GetPage<dynamic>? page) {
    if (Get.isRegistered<MainController>()) {
      Get.find<MainController>().setelTab(tab);
    }
    return page;
  }
}
