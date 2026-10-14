import 'package:get/get.dart';

import '../controllers/main_controller.dart';
import '../data/providers/resep_provider.dart';
import '../data/repositories/resep_repository.dart';
import '../data/services/katalog_service.dart';
import '../data/services/storage_service.dart';
import '../modules/favorit/controllers/favorit_controller.dart';
import '../modules/kulkas/controllers/kulkas_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    final storage = Get.put(StorageService(), permanent: true);
    final provider = Get.put(ResepProvider(), permanent: true);
    Get.put(
      KatalogService(ResepRepository(provider: provider, storage: storage)),
      permanent: true,
    );
    Get.put(KulkasController(), permanent: true);
    Get.put(FavoritController(), permanent: true);
    Get.put(MainController(), permanent: true);
  }
}
