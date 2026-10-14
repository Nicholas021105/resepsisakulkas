import 'package:get/get.dart';

import '../../../controllers/main_controller.dart';
import '../controllers/kulkas_controller.dart';

/// [KulkasController] sudah permanent lewat InitialBinding; binding ini
/// memastikan halaman Kulkas selalu dibuka dengan pencarian & filter kosong,
/// dan tab Kulkas yang menyala di bottom nav.
class KulkasBinding extends Bindings {
  @override
  void dependencies() {
    Get.find<KulkasController>().resetPencarian();
    Get.find<MainController>().setelTab(0);
  }
}
