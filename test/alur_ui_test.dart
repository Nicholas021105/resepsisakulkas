import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:resepsisakulkas/app/data/models/katalog_model.dart';
import 'package:resepsisakulkas/app/data/services/storage_service.dart';
import 'package:resepsisakulkas/app/modules/favorit/controllers/favorit_controller.dart';
import 'package:resepsisakulkas/app/modules/kulkas/controllers/kulkas_controller.dart';
import 'package:resepsisakulkas/app/routes/app_routes.dart';

import 'helpers/aplikasi_uji.dart';
import 'helpers/katalog_contoh.dart';
import 'helpers/palsu.dart';

/// Alur utama: cari & pilih bahan → lihat resep → detail → favorit.
void main() {
  setUpAll(() => initializeDateFormatting('id_ID'));

  Future<void> ketuk(WidgetTester tester, Finder target) async {
    await tester.ensureVisible(target);
    await tester.pumpAndSettle();
    await tester.tap(target);
    await tester.pumpAndSettle();
  }

  testWidgets('pilih bahan → lihat resep → detail → favorit', (tester) async {
    tester.view.physicalSize = const Size(412 * 3, 915 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    siapkanDependensi(
      ambil: () async =>
          HasilAmbil(katalog: katalogKecil(), sumber: SumberData.bawaan),
    );
    await tester.pumpWidget(aplikasiUji());
    await tester.pumpAndSettle();

    // Kulkas kosong: ilustrasi + ajakan, tombol belum aktif.
    expect(find.text('Kulkasmu masih kosong'), findsOneWidget);
    expect(find.text('Tempel bahan dulu'), findsOneWidget);

    // F1: pencarian dengan debounce 300 ms.
    await tester.enterText(find.byKey(const Key('cari-bahan')), 'tem');
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byKey(const Key('magnet-telur')), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byKey(const Key('magnet-telur')), findsNothing);
    expect(find.byKey(const Key('magnet-tempe')), findsOneWidget);
    await tester.enterText(find.byKey(const Key('cari-bahan')), '');
    await tester.pump(const Duration(milliseconds: 350));
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();

    // Tempel telur & kecap.
    await ketuk(tester, find.byKey(const Key('magnet-telur')));
    await ketuk(tester, find.byKey(const Key('magnet-kecap')));
    final kulkas = Get.find<KulkasController>();
    expect(kulkas.bahanDimiliki, {'telur', 'kecap'});
    expect(find.text('2 bahan di kulkas'), findsOneWidget);

    // F2: tersimpan otomatis ke storage.
    final storage = Get.find<StorageService>() as StorageMemori;
    expect(storage.set[StorageService.kunciKulkas], {'telur', 'kecap'});

    // Tombol pill "Lihat n resep cocok" (telur-kecap, dadar, orek, campur).
    expect(find.text('4'), findsOneWidget);
    await ketuk(tester, find.byKey(const Key('lihat-resep')));
    expect(Get.currentRoute, Routes.resep);
    expect(find.byKey(const Key('resep-dadar')), findsOneWidget);

    // F4: detail lewat route dinamis.
    await ketuk(tester, find.byKey(const Key('resep-dadar')));
    expect(Get.currentRoute, '/resep/dadar');
    expect(find.text('Semua ada ✓'), findsOneWidget);
    expect(find.text('Langkah'), findsOneWidget);

    // F9: favorit.
    await ketuk(tester, find.byKey(const Key('toggle-favorit')));
    expect(Get.find<FavoritController>().favorit, {'dadar'});
    expect(storage.set[StorageService.kunciFavorit], {'dadar'});
    Get.back(closeOverlays: true);
    await tester.pumpAndSettle();
    await ketuk(tester, find.byKey(const Key('nav-favorit')));
    expect(find.byKey(const Key('resep-dadar')), findsOneWidget);

    // F8: matikan bumbu dasar di Pengaturan → dadar tidak lagi 100%.
    await ketuk(tester, find.byKey(const Key('buka-pengaturan')));
    await ketuk(tester, find.byKey(const Key('opsi-bumbu-dasar')));
    expect(kulkas.bumbuDasarAda.value, isFalse);
    expect(storage.boolean[StorageService.kunciBumbuDasar], isFalse);
    await bersihkan(tester);
  });
}
