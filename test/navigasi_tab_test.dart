import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:resepsisakulkas/app/controllers/main_controller.dart';
import 'package:resepsisakulkas/app/data/models/hasil_cocok.dart';
import 'package:resepsisakulkas/app/data/models/katalog_model.dart';
import 'package:resepsisakulkas/app/modules/kulkas/controllers/kulkas_controller.dart';
import 'package:resepsisakulkas/app/modules/resep/controllers/resep_controller.dart';
import 'package:resepsisakulkas/app/routes/app_routes.dart';

import 'helpers/aplikasi_uji.dart';

/// Tab mempertahankan state: pindah tab tidak membangun ulang halaman.
void main() {
  late Katalog katalog;

  setUpAll(() async {
    await initializeDateFormatting('id_ID');
    katalog = Katalog.fromJson(
      jsonDecode(await rootBundle.loadString('assets/data/resep.json'))
          as Map<String, dynamic>,
    );
  });

  Future<void> buka(WidgetTester tester, {String rute = Routes.kulkas}) async {
    tester.view.physicalSize = const Size(360 * 2, 640 * 2);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    siapkanDependensi(
      ambil: () async =>
          HasilAmbil(katalog: katalog, sumber: SumberData.bawaan),
      kulkas: {'telur', 'tempe', 'kecap-manis'},
    );
    await tester.pumpWidget(aplikasiUji(rute: rute));
    await tester.pumpAndSettle();
  }

  Future<void> ketukTab(WidgetTester tester, String nama) async {
    await tester.tap(find.byKey(Key('nav-$nama')));
    await tester.pumpAndSettle();
  }

  double gulirKulkas(WidgetTester tester) => tester
      .state<ScrollableState>(
        find
            .descendant(
              of: find.byKey(const ValueKey('tab-0')),
              matching: find.byType(Scrollable),
            )
            .first,
      )
      .position
      .pixels;

  testWidgets('posisi gulir & pencarian Kulkas bertahan saat pindah tab', (
    tester,
  ) async {
    await buka(tester);
    await tester.enterText(find.byKey(const Key('cari-bahan')), 'a');
    await tester.pump(KulkasController.jedaPencarian * 2);
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await tester.drag(
      find.byKey(const Key('cari-bahan')),
      const Offset(0, -240),
    );
    await tester.pumpAndSettle();
    final gulir = gulirKulkas(tester);
    expect(gulir, greaterThan(100));

    await ketukTab(tester, 'resep');
    expect(Get.find<MainController>().indexTab.value, 1);
    // Tab Kulkas tersembunyi, bukan dibuang.
    expect(find.byKey(const Key('cari-bahan')), findsNothing);
    expect(
      find.byKey(const Key('cari-bahan'), skipOffstage: false),
      findsOneWidget,
    );
    await ketukTab(tester, 'favorit');
    await ketukTab(tester, 'kulkas');

    expect(gulirKulkas(tester), gulir);
    expect(Get.find<KulkasController>().keyword.value, 'a');
    // Kolom pencarian (kini tergulir ke atas layar) masih memegang teksnya:
    // state TextField yang sama, bukan widget baru.
    expect(
      tester
          .state<EditableTextState>(
            find.descendant(
              of: find.byKey(const Key('cari-bahan'), skipOffstage: false),
              matching: find.byType(EditableText, skipOffstage: false),
            ),
          )
          .textEditingValue
          .text,
      'a',
    );
    await bersihkan(tester);
  });

  testWidgets('filter tab Resep bertahan; tab dibangun saat pertama dibuka', (
    tester,
  ) async {
    await buka(tester);
    // Tab Resep belum pernah dibuka → belum dibangun.
    expect(
      find.byKey(const Key('filter-semua'), skipOffstage: false),
      findsNothing,
    );
    await ketukTab(tester, 'resep');
    final resep = Get.find<ResepController>();
    expect(
      tester.widget<ChoiceChip>(find.byKey(const Key('filter-siap'))).selected,
      isTrue,
    );
    resep.pilihFilter(FilterHasil.semua);
    await tester.pumpAndSettle();
    await ketukTab(tester, 'kulkas');
    await ketukTab(tester, 'resep');
    expect(identical(Get.find<ResepController>(), resep), isTrue);
    expect(resep.filter.value, FilterHasil.semua);
    expect(
      tester.widget<ChoiceChip>(find.byKey(const Key('filter-siap'))).selected,
      isFalse,
    );
    await bersihkan(tester);
  });

  testWidgets('tombol kembali sistem: tab lain → Kulkas dulu', (tester) async {
    await buka(tester, rute: Routes.favorit);
    final main = Get.find<MainController>();
    expect(main.indexTab.value, MainController.tabFavorit);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(main.indexTab.value, MainController.tabKulkas);
    expect(find.text('Kulkasku'), findsOneWidget);
    await bersihkan(tester);
  });

  testWidgets('pindahTab dari halaman detail menutup detail dulu', (
    tester,
  ) async {
    await buka(tester);
    Get.toNamed(Routes.keDetail('telur-dadar'));
    await tester.pumpAndSettle();
    expect(Get.currentRoute, '/resep/telur-dadar');

    Get.find<MainController>().pindahTab(MainController.tabResep);
    await tester.pumpAndSettle();
    expect(Get.currentRoute, Routes.kulkas);
    expect(Get.find<MainController>().indexTab.value, 1);
    expect(find.byKey(const Key('filter-siap')), findsOneWidget);
    await bersihkan(tester);
  });
}
