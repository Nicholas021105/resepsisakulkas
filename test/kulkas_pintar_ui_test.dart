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
import 'package:resepsisakulkas/app/widgets/kartu_resep.dart';

import 'helpers/aplikasi_uji.dart';

/// Alur "segera habiskan" di layar: banner, tekan lama magnet, lembar opsi,
/// dan resep penyelamat di urutan teratas.
void main() {
  late Katalog katalog;
  final kini = DateTime(2026, 11, 16, 9);

  setUpAll(() async {
    await initializeDateFormatting('id_ID');
    katalog = Katalog.fromJson(
      jsonDecode(await rootBundle.loadString('assets/data/resep.json'))
          as Map<String, dynamic>,
    );
  });

  Future<void> buka(WidgetTester tester) async {
    tester.view.physicalSize = const Size(412 * 2, 915 * 2);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    siapkanDependensi(
      ambil: () async =>
          HasilAmbil(katalog: katalog, sumber: SumberData.bawaan),
      kulkas: {'bayam', 'telur', 'bawang-merah'},
      sejak: {
        // Bayam (awet 2 hari) sudah 3 hari → otomatis segera.
        'bayam': kini.subtract(const Duration(days: 3)).toIso8601String(),
        'telur': kini.toIso8601String(),
        'bawang-merah': kini.toIso8601String(),
      },
      jam: () => kini,
    );
    await tester.pumpWidget(aplikasiUji());
    await tester.pumpAndSettle();
  }

  Future<void> tekanLama(WidgetTester tester, String id) async {
    final magnet = find.byKey(Key('magnet-$id'));
    await tester.ensureVisible(magnet);
    await tester.pumpAndSettle();
    await tester.longPress(magnet);
    await tester.pumpAndSettle();
  }

  testWidgets('banner, lencana, dan lembar opsi bahan', (tester) async {
    await buka(tester);
    final kulkas = Get.find<KulkasController>();

    // Otomatis: bayam sudah lewat masa segarnya.
    expect(find.byKey(const Key('banner-segera')), findsOneWidget);
    expect(find.text('1 bahan segera habiskan'), findsOneWidget);
    expect(find.byKey(const Key('petunjuk-tekan-lama')), findsNothing);
    expect(
      find.descendant(
        of: find.byKey(const Key('magnet-bayam')),
        matching: find.byKey(const Key('lencana-segera')),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('magnet-telur')),
        matching: find.byKey(const Key('lencana-ada')),
      ),
      findsOneWidget,
    );

    // Tekan lama telur → tandai segera habiskan.
    await tekanLama(tester, 'telur');
    expect(find.byKey(const Key('lembar-opsi-bahan')), findsOneWidget);
    expect(
      find.text('Ditempel hari ini · kira-kira masih segar 21 hari lagi'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('opsi-segar')), findsNothing);
    await tester.tap(find.byKey(const Key('opsi-segera')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('lembar-opsi-bahan')), findsNothing);
    expect(kulkas.ditandaiSegera, {'telur'});
    // Ringkasan bisa tergulir keluar layar setelah ensureVisible.
    expect(
      find.text('2 bahan segera habiskan', skipOffstage: false),
      findsOneWidget,
    );

    // Bayam: "masih segar" → hitung ulang, tidak lagi segera.
    await tekanLama(tester, 'bayam');
    expect(
      find.text(
        'Ditempel 3 hari lalu · sudah lewat 1 hari dari perkiraan segar',
      ),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('opsi-segar')));
    await tester.pumpAndSettle();
    expect(kulkas.bahanSegera, {'telur'});
    expect(kulkas.sejak['bayam'], kini);

    // Lepas dari kulkas lewat lembar.
    await tekanLama(tester, 'telur');
    await tester.tap(find.byKey(const Key('opsi-lepas')));
    await tester.pumpAndSettle();
    expect(kulkas.bahanDimiliki, {'bayam', 'bawang-merah'});
    expect(
      find.byKey(const Key('banner-segera'), skipOffstage: false),
      findsNothing,
    );
    expect(
      find.byKey(const Key('petunjuk-tekan-lama'), skipOffstage: false),
      findsOneWidget,
    );
    await bersihkan(tester);
  });

  testWidgets('magnet yang belum ditempel tidak punya lembar opsi', (
    tester,
  ) async {
    await buka(tester);
    // Tanpa aksi tekan-lama, menahan lalu melepas jari sama dengan ketuk
    // (perilaku standar InkWell): bahan ditempel, lembar tidak muncul.
    await tekanLama(tester, 'tempe');
    expect(find.byKey(const Key('lembar-opsi-bahan')), findsNothing);
    expect(Get.find<KulkasController>().bahanDimiliki, contains('tempe'));
    await bersihkan(tester);
  });

  testWidgets('banner → tab Resep, resep penyelamat di urutan teratas', (
    tester,
  ) async {
    await buka(tester);
    await tester.tap(find.byKey(const Key('banner-segera')));
    await tester.pumpAndSettle();

    expect(Get.find<MainController>().indexTab.value, MainController.tabResep);
    final resep = Get.find<ResepController>();
    expect(resep.filter.value, FilterHasil.semua);
    // Sayur bening bayam: bayam + bawang merah + bumbu dasar = 100%.
    expect(resep.state!.first.resep.id, 'sayur-bening-bayam');
    expect(resep.state!.first.segera, ['bayam']);
    expect(
      find.descendant(
        of: find.byType(KartuResep).first,
        matching: find.text('Pakai bayam yang segera habis'),
      ),
      findsOneWidget,
    );
    await bersihkan(tester);
  });
}
