import 'package:get/get.dart';

import '../../../controllers/main_controller.dart';
import '../controllers/favorit_controller.dart';

/// [FavoritController] sudah permanent lewat InitialBinding; binding ini
/// memastikan instance tersedia sebelum halaman Favorit dibangun, dan tab
/// Favorit yang menyala di bottom nav.
class FavoritBinding extends Bindings {
  @override
  void dependencies() {
    Get.find<FavoritController>();
    Get.find<MainController>().setelTab(2);
  }
}
