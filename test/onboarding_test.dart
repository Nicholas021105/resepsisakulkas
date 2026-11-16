import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:resepsisakulkas/app/controllers/tema_controller.dart';
import 'package:resepsisakulkas/app/data/models/katalog_model.dart';
import 'package:resepsisakulkas/app/data/services/storage_service.dart';
import 'package:resepsisakulkas/app/routes/app_routes.dart';
import 'package:resepsisakulkas/app/theme/app_palet.dart';

import 'helpers/aplikasi_uji.dart';
import 'helpers/katalog_contoh.dart';
import 'helpers/palsu.dart';

/// Onboarding tiga layar dan pilihan tema di Pengaturan.
void main() {
  setUpAll(() => initializeDateFormatting('id_ID'));

  Future<StorageMemori> buka(WidgetTester tester, String rute) async {
    tester.view.physicalSize = const Size(412 * 2, 915 * 2);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    siapkanDependensi(
      ambil: () async =>
          HasilAmbil(katalog: katalogKecil(), sumber: SumberData.bawaan),
    );
    await tester.pumpWidget(aplikasiUji(rute: rute));
    await tester.pumpAndSettle();
    return Get.find<StorageService>() as StorageMemori;
  }

  testWidgets('tiga layar → Mulai: ditandai selesai, masuk ke Kulkas', (
    tester,
  ) async {
    final storage = await buka(tester, Routes.onboarding);
    expect(find.text('Tempel isi kulkasmu'), findsOneWidget);
    expect(find.text('Lanjut'), findsOneWidget);
    expect(storage.boolean[StorageService.kunciOnboarding], isNull);

    await tester.tap(find.byKey(const Key('onboarding-lanjut')));
    await tester.pumpAndSettle();
    expect(find.text('Temukan resep yang cocok'), findsOneWidget);
    await tester.tap(find.byKey(const Key('onboarding-lanjut')));
    await tester.pumpAndSettle();
    expect(find.text('Belanja, masak, selesai'), findsOneWidget);
    expect(find.text('Mulai tempel bahan'), findsOneWidget);

    await tester.tap(find.byKey(const Key('onboarding-lanjut')));
    await tester.pumpAndSettle();
    expect(storage.boolean[StorageService.kunciOnboarding], isTrue);
    expect(Get.currentRoute, Routes.kulkas);
    expect(find.text('Kulkasmu masih kosong'), findsOneWidget);
    await bersihkan(tester);
  });

  testWidgets('Lewati langsung menandai selesai', (tester) async {
    final storage = await buka(tester, Routes.onboarding);
    await tester.tap(find.byKey(const Key('onboarding-lewati')));
    await tester.pumpAndSettle();
    expect(storage.boolean[StorageService.kunciOnboarding], isTrue);
    expect(Get.currentRoute, Routes.kulkas);
    await bersihkan(tester);
  });

  testWidgets('geser layar memperbarui indikator & tombol', (tester) async {
    await buka(tester, Routes.onboarding);
    await tester.drag(
      find.byKey(const Key('onboarding-halaman')),
      const Offset(-400, 0),
    );
    await tester.pumpAndSettle();
    expect(find.text('Temukan resep yang cocok'), findsOneWidget);
    expect(find.bySemanticsLabel('Halaman 2 dari 3'), findsOneWidget);
    await bersihkan(tester);
  });

  testWidgets('Pengaturan: pengenalan bisa dibuka lagi', (tester) async {
    await buka(tester, Routes.pengaturan);
    final baris = find.byKey(const Key('lihat-pengenalan'));
    await tester.scrollUntilVisible(
      baris,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(baris);
    await tester.pumpAndSettle();
    expect(Get.currentRoute, Routes.onboarding);
    await bersihkan(tester);
  });

  testWidgets('Pengaturan: memilih tema gelap mengganti palet & tersimpan', (
    tester,
  ) async {
    final storage = await buka(tester, Routes.pengaturan);
    BuildContext konteks() =>
        tester.element(find.byKey(const Key('pilih-tema')));
    expect(konteks().palet.modeGelap, isFalse);

    await tester.tap(find.byKey(const Key('tema-gelap')));
    await tester.pumpAndSettle();
    expect(Get.find<TemaController>().mode.value, ThemeMode.dark);
    expect(storage.mentah[StorageService.kunciTema], 'gelap');
    expect(konteks().palet.modeGelap, isTrue);
    expect(Theme.of(konteks()).scaffoldBackgroundColor, Palet.gelap.latar);

    await tester.tap(find.byKey(const Key('tema-terang')));
    await tester.pumpAndSettle();
    expect(storage.mentah[StorageService.kunciTema], 'terang');
    expect(konteks().palet.modeGelap, isFalse);
    await bersihkan(tester);
  });
}
