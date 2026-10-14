import 'package:get/get.dart';

import '../../../controllers/main_controller.dart';
import '../controllers/resep_controller.dart';

class ResepBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ResepController>(() => ResepController());
    Get.find<MainController>().setelTab(1);
  }
}
