import 'package:get/get.dart';

import '../controllers/favorit_controller.dart';

/// [FavoritController] sudah permanent lewat InitialBinding; binding ini
/// memastikan instance tersedia sebelum tab Favorit dibangun.
class FavoritBinding extends Bindings {
  @override
  void dependencies() {
    Get.find<FavoritController>();
  }
}
