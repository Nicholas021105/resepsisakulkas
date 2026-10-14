import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:resepsisakulkas/app/controllers/main_controller.dart';
import 'package:resepsisakulkas/app/data/models/katalog_model.dart';
import 'package:resepsisakulkas/app/data/services/katalog_service.dart';
import 'package:resepsisakulkas/app/data/services/storage_service.dart';
import 'package:resepsisakulkas/app/modules/favorit/controllers/favorit_controller.dart';
import 'package:resepsisakulkas/app/modules/kulkas/controllers/kulkas_controller.dart';
import 'package:resepsisakulkas/app/routes/app_pages.dart';
import 'package:resepsisakulkas/app/theme/app_theme.dart';

import 'palsu.dart';

/// Mendaftarkan service & controller permanent seperti InitialBinding,
/// tetapi dengan storage memori dan repository tiruan.
RepoTetap siapkanDependensi({
  required Future<HasilAmbil> Function() ambil,
  Set<String> kulkas = const {},
  Set<String> favorit = const {},
  bool bumbuDasar = true,
}) {
  Get.testMode = true;
  final storage = StorageMemori()
    ..set[StorageService.kunciKulkas] = {...kulkas}
    ..set[StorageService.kunciFavorit] = {...favorit}
    ..boolean[StorageService.kunciBumbuDasar] = bumbuDasar;
  Get.put<StorageService>(storage, permanent: true);
  final repo = RepoTetap(ambil);
  Get.put(KatalogService(repo), permanent: true);
  Get.put(KulkasController(), permanent: true);
  Get.put(FavoritController(), permanent: true);
  Get.put(MainController(), permanent: true);
  return repo;
}

Widget aplikasiUji({String rute = AppPages.initial, ThemeData? tema}) =>
    GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: tema ?? AppTheme.terang,
      initialRoute: rute,
      getPages: AppPages.routes,
    );

/// Habiskan antrean snackbar lalu bersihkan GetX.
Future<void> bersihkan(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(seconds: 1));
  }
  await tester.pumpWidget(const SizedBox());
  Get.reset();
}
