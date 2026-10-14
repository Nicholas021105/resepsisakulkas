import 'package:get/get.dart';

import '../modules/detail_resep/bindings/detail_resep_binding.dart';
import '../modules/detail_resep/views/detail_resep_view.dart';
import '../modules/favorit/bindings/favorit_binding.dart';
import '../modules/favorit/views/favorit_view.dart';
import '../modules/kulkas/bindings/kulkas_binding.dart';
import '../modules/kulkas/views/kulkas_view.dart';
import '../modules/pengaturan/bindings/pengaturan_binding.dart';
import '../modules/pengaturan/views/pengaturan_view.dart';
import '../modules/resep/bindings/resep_binding.dart';
import '../modules/resep/views/resep_view.dart';
import 'app_routes.dart';

abstract class AppPages {
  static const initial = Routes.kulkas;

  static final routes = [
    GetPage(
      name: Routes.kulkas,
      page: () => const KulkasView(),
      binding: KulkasBinding(),
    ),
    GetPage(
      name: Routes.resep,
      page: () => const ResepView(),
      binding: ResepBinding(),
    ),
    GetPage(
      name: Routes.detailResep,
      page: () => const DetailResepView(),
      binding: DetailResepBinding(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: Routes.favorit,
      page: () => const FavoritView(),
      binding: FavoritBinding(),
    ),
    GetPage(
      name: Routes.pengaturan,
      page: () => const PengaturanView(),
      binding: PengaturanBinding(),
      transition: Transition.cupertino,
    ),
  ];
}
