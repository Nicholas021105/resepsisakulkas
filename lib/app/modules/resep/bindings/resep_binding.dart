import 'package:get/get.dart';

import '../controllers/resep_controller.dart';

class ResepBinding extends Bindings {
  @override
  void dependencies() {
    // fenix: bila cangkang tab dibuat ulang (deep link, Get.offAllNamed),
    // controller yang ikut terbuang dibuat lagi saat tab Resep dibuka.
    Get.lazyPut<ResepController>(() => ResepController(), fenix: true);
  }
}
