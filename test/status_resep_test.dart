import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:resepsisakulkas/app/controllers/main_controller.dart';
import 'package:resepsisakulkas/app/data/models/katalog_model.dart';
import 'package:resepsisakulkas/app/routes/app_routes.dart';

import 'helpers/aplikasi_uji.dart';
import 'helpers/katalog_contoh.dart';

/// Empat status StateMixin di halaman Resep + route dinamis /resep/:id.
void main() {
  setUpAll(() => initializeDateFormatting('id_ID'));

  final hasilServer = HasilAmbil(
    katalog: katalogKecil(),
    sumber: SumberData.server,
    waktu: DateTime(2026, 10, 13, 10, 20),
  );

  testWidgets('loading: katalog belum termuat', (tester) async {
    final tertunda = Completer<HasilAmbil>();
    siapkanDependensi(ambil: () => tertunda.future, kulkas: {'telur'});
    await tester.pumpWidget(aplikasiUji(rute: Routes.resep));
    await tester.pump();

    expect(find.byKey(const Key('status-memuat')), findsOneWidget);
    expect(find.text('Memuat resep…'), findsOneWidget);

    tertunda.complete(hasilServer);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('status-memuat')), findsNothing);
    await bersihkan(tester);
  });

  testWidgets('sukses: daftar resep tampil + label sumber', (tester) async {
    siapkanDependensi(
      ambil: () async => hasilServer,
      kulkas: {'telur', 'kecap'},
    );
    await tester.pumpWidget(aplikasiUji(rute: Routes.resep));
    await tester.pumpAndSettle();

    // Filter awal "Siap dimasak": telur-kecap & dadar (bumbu dasar aktif).
    expect(find.byKey(const Key('resep-telur-kecap')), findsOneWidget);
    expect(find.byKey(const Key('resep-dadar')), findsOneWidget);
    expect(find.text('Server · diperbarui 13 Okt 10.20'), findsOneWidget);
    expect(find.textContaining('Siap dimasak (2)'), findsOneWidget);

    await tester.tap(find.byKey(const Key('filter-kurangSedikit')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('resep-orek')), findsOneWidget);
    expect(find.text('kurang: tempe'), findsOneWidget);
    await bersihkan(tester);
  });

  testWidgets('kosong: tidak ada resep cocok', (tester) async {
    siapkanDependensi(
      ambil: () async => hasilServer,
      kulkas: {'tomat'},
      bumbuDasar: false,
    );
    await tester.pumpWidget(aplikasiUji(rute: Routes.resep));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('status-kosong')), findsOneWidget);
    expect(find.text('Belum ada resep yang cocok'), findsOneWidget);
    await bersihkan(tester);
  });

  testWidgets('error + coba lagi → berhasil', (tester) async {
    var percobaan = 0;
    final repo = siapkanDependensi(
      ambil: () async {
        percobaan++;
        if (percobaan == 1) throw Exception('aset rusak');
        return hasilServer;
      },
      kulkas: {'telur', 'kecap'},
    );
    await tester.pumpWidget(aplikasiUji(rute: Routes.resep));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('status-error')), findsOneWidget);
    expect(find.text('Data resep gagal dimuat.'), findsOneWidget);

    await tester.tap(find.byKey(const Key('coba-lagi')));
    await tester.pumpAndSettle();
    expect(repo.dipanggil, 2);
    expect(find.byKey(const Key('status-error')), findsNothing);
    expect(find.byKey(const Key('resep-telur-kecap')), findsOneWidget);
    await bersihkan(tester);
  });

  testWidgets('/resep/:id valid → detail resep', (tester) async {
    siapkanDependensi(ambil: () async => hasilServer, kulkas: {'telur'});
    await tester.pumpWidget(aplikasiUji(rute: Routes.keDetail('campur')));
    await tester.pumpAndSettle();

    expect(Get.parameters['id'], 'campur');
    expect(find.text('campur'), findsOneWidget);
    expect(find.text('Kurang 3'), findsOneWidget);
    expect(find.text('25%'), findsOneWidget);
    await bersihkan(tester);
  });

  testWidgets('tab menyala sesuai route walau dibuka langsung', (tester) async {
    siapkanDependensi(ambil: () async => hasilServer, kulkas: {'telur'});
    await tester.pumpWidget(aplikasiUji(rute: Routes.favorit));
    await tester.pumpAndSettle();
    int tabAktif() =>
        tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex;
    expect(tabAktif(), 2);

    // offAllNamed di luar pindahTab (mis. tombol kembali) ikut tersinkron.
    Get.offAllNamed(Routes.resep);
    await tester.pumpAndSettle();
    expect(tabAktif(), 1);
    expect(Get.find<MainController>().indexTab.value, 1);
    await bersihkan(tester);
  });

  testWidgets('detail dibuka langsung: tombol kembali → Kulkas', (
    tester,
  ) async {
    siapkanDependensi(ambil: () async => hasilServer, kulkas: {'telur'});
    await tester.pumpWidget(aplikasiUji(rute: Routes.keDetail('dadar')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('appbar-kembali')));
    await tester.pumpAndSettle();
    expect(Get.currentRoute, Routes.kulkas);
    expect(Get.find<MainController>().indexTab.value, 0);
    await bersihkan(tester);
  });

  testWidgets('/resep/:id tidak valid → "Resep tidak ditemukan"', (
    tester,
  ) async {
    siapkanDependensi(ambil: () async => hasilServer);
    await tester.pumpWidget(aplikasiUji());
    await tester.pumpAndSettle();
    Get.toNamed(Routes.keDetail('resep-yang-tidak-ada'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('resep-tidak-ditemukan')), findsOneWidget);
    expect(find.text('Resep tidak ditemukan'), findsOneWidget);

    await tester.tap(find.byKey(const Key('kembali')));
    await tester.pumpAndSettle();
    expect(Get.currentRoute, Routes.kulkas);
    expect(Get.find<MainController>().indexTab.value, 0);
    await bersihkan(tester);
  });
}
