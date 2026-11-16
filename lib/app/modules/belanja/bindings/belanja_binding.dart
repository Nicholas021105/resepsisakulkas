import 'package:get/get.dart';

import '../controllers/belanja_controller.dart';

/// [BelanjaController] sudah permanent lewat InitialBinding (dipakai juga
/// oleh kartu dan detail resep); binding ini memastikan instance tersedia
/// sebelum tab Belanja dibangun.
class BelanjaBinding extends Bindings {
  @override
  void dependencies() {
    Get.find<BelanjaController>();
  }
}
