import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:resepsisakulkas/app/data/models/katalog_model.dart';
import 'package:resepsisakulkas/app/routes/app_routes.dart';
import 'package:resepsisakulkas/app/widgets/umum_widgets.dart';

import 'helpers/aplikasi_uji.dart';
import 'helpers/katalog_contoh.dart';

/// Ikon aplikasi: aset runtime, pemakaian di dalam app, dan hasil generator
/// ikon launcher Android.
void main() {
  setUpAll(() => initializeDateFormatting('id_ID'));

  test('hanya ikon_app.png yang dibundel sebagai aset runtime', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final manifes = await AssetManifest.loadFromAssetBundle(rootBundle);
    final ikon = manifes.listAssets().where(
      (a) => a.startsWith('assets/ikon/'),
    );
    expect(ikon, [IkonAplikasi.aset]);
    final data = await rootBundle.load(IkonAplikasi.aset);
    // Tanda tangan PNG.
    expect(data.buffer.asUint8List(0, 4), [0x89, 0x50, 0x4E, 0x47]);
  });

  group('hasil flutter_launcher_icons (Android)', () {
    const res = 'android/app/src/main/res';

    test('mipmap semua kerapatan + latar depan adaptif ada', () {
      for (final dpi in ['mdpi', 'hdpi', 'xhdpi', 'xxhdpi', 'xxxhdpi']) {
        expect(File('$res/mipmap-$dpi/ic_launcher.png').existsSync(), isTrue);
        expect(
          File('$res/drawable-$dpi/ic_launcher_foreground.png').existsSync(),
          isTrue,
          reason: dpi,
        );
      }
    });

    test('ic_launcher adaptif memakai latar #1F8A70', () {
      final adaptif = File('$res/mipmap-anydpi-v26/ic_launcher.xml')
          .readAsStringSync();
      expect(adaptif, contains('<adaptive-icon'));
      expect(adaptif, contains('@color/ic_launcher_background'));
      expect(adaptif, contains('@drawable/ic_launcher_foreground'));
      expect(
        File('$res/values/colors.xml').readAsStringSync().toUpperCase(),
        contains('#1F8A70'),
      );
    });

    test('layar pembuka: warna latar ikon + ikon di tengah', () {
      for (final folder in ['drawable', 'drawable-v21']) {
        final xml = File('$res/$folder/launch_background.xml')
            .readAsStringSync();
        expect(xml, contains('@color/ic_launcher_background'), reason: folder);
        expect(
          xml,
          contains('@drawable/ic_launcher_foreground'),
          reason: folder,
        );
        expect(xml, contains('android:gravity="center"'), reason: folder);
        expect(xml, isNot(contains('@android:color/white')), reason: folder);
      }
      for (final folder in ['values-v31', 'values-night-v31']) {
        expect(
          File('$res/$folder/styles.xml').readAsStringSync(),
          contains('windowSplashScreenBackground'),
          reason: folder,
        );
      }
    });

    test('manifest: label ResepSisaKulkas dan ikon launcher', () {
      final manifes = File('android/app/src/main/AndroidManifest.xml')
          .readAsStringSync();
      expect(manifes, contains('android:label="ResepSisaKulkas"'));
      expect(manifes, contains('android:icon="@mipmap/ic_launcher"'));
    });
  });

  group('ikon di dalam app', () {
    Future<void> buka(WidgetTester tester, String rute) async {
      tester.view.physicalSize = const Size(412 * 2, 915 * 2);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);
      siapkanDependensi(
        ambil: () async =>
            HasilAmbil(katalog: katalogKecil(), sumber: SumberData.bawaan),
      );
      await tester.pumpWidget(aplikasiUji(rute: rute));
      await tester.pumpAndSettle();
    }

    Image gambarDi(WidgetTester tester, Key kunci) => tester.widget<Image>(
      find.descendant(of: find.byKey(kunci), matching: find.byType(Image)),
    );

    testWidgets('onboarding menampilkan ikon aset di kepala halaman', (
      tester,
    ) async {
      await buka(tester, Routes.onboarding);
      final gambar = gambarDi(tester, const Key('ikon-app-onboarding'));
      final sumber = gambar.image as ResizeImage;
      expect((sumber.imageProvider as AssetImage).assetName, IkonAplikasi.aset);
      expect(find.text('ResepSisaKulkas'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      Get.reset();
    });

    testWidgets('Pengaturan → Tentang memakai ikon aset', (tester) async {
      await buka(tester, Routes.pengaturan);
      await tester.scrollUntilVisible(
        find.byKey(const Key('ikon-app-tentang')),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      final gambar = gambarDi(tester, const Key('ikon-app-tentang'));
      expect(gambar.width, 40);
      expect(gambar.height, 40);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      Get.reset();
    });
  });
}
