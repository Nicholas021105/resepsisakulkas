import 'package:get/get.dart';

import '../controllers/kulkas_controller.dart';

/// [KulkasController] sudah permanent lewat InitialBinding; binding ini
/// memastikan tab Kulkas selalu dibuka dengan pencarian & filter kosong.
class KulkasBinding extends Bindings {
  @override
  void dependencies() {
    Get.find<KulkasController>().resetPencarian();
  }
}
