import 'package:get/get.dart';

import '../controllers/masak_controller.dart';

class MasakBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MasakController>(() => MasakController());
  }
}
