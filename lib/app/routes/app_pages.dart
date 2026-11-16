import 'package:get/get.dart';

import '../controllers/main_controller.dart';
import '../modules/belanja/bindings/belanja_binding.dart';
import '../modules/beranda/tab_middleware.dart';
import '../modules/beranda/views/beranda_view.dart';
import '../modules/detail_resep/bindings/detail_resep_binding.dart';
import '../modules/detail_resep/views/detail_resep_view.dart';
import '../modules/favorit/bindings/favorit_binding.dart';
import '../modules/kulkas/bindings/kulkas_binding.dart';
import '../modules/masak/bindings/masak_binding.dart';
import '../modules/masak/views/masak_view.dart';
import '../modules/pengaturan/bindings/pengaturan_binding.dart';
import '../modules/pengaturan/views/pengaturan_view.dart';
import '../modules/resep/bindings/resep_binding.dart';
import 'app_routes.dart';

abstract class AppPages {
  static const initial = Routes.kulkas;

  /// Route satu tab: cangkang [BerandaView] dengan Binding semua modul tab
  /// (semua tab hidup bersama di cangkang) + tab yang dinyalakan.
  static GetPage<dynamic> _tab(String nama, int index) => GetPage(
    name: nama,
    page: () => const BerandaView(),
    bindings: [
      KulkasBinding(),
      ResepBinding(),
      FavoritBinding(),
      BelanjaBinding(),
    ],
    middlewares: [TabMiddleware(index)],
    transition: Transition.noTransition,
  );

  static final routes = [
    _tab(Routes.kulkas, MainController.tabKulkas),
    _tab(Routes.resep, MainController.tabResep),
    _tab(Routes.favorit, MainController.tabFavorit),
    _tab(Routes.belanja, MainController.tabBelanja),
    GetPage(
      name: Routes.detailResep,
      page: () => const DetailResepView(),
      binding: DetailResepBinding(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: Routes.masak,
      page: () => const MasakView(),
      binding: MasakBinding(),
      transition: Transition.downToUp,
    ),
    GetPage(
      name: Routes.pengaturan,
      page: () => const PengaturanView(),
      binding: PengaturanBinding(),
      transition: Transition.cupertino,
    ),
  ];
}
