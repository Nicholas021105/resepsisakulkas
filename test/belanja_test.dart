import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:resepsisakulkas/app/controllers/main_controller.dart';
import 'package:resepsisakulkas/app/data/models/belanja_model.dart';
import 'package:resepsisakulkas/app/data/models/hasil_cocok.dart';
import 'package:resepsisakulkas/app/data/models/katalog_model.dart';
import 'package:resepsisakulkas/app/data/services/storage_service.dart';
import 'package:resepsisakulkas/app/modules/belanja/controllers/belanja_controller.dart';
import 'package:resepsisakulkas/app/modules/kulkas/controllers/kulkas_controller.dart';
import 'package:resepsisakulkas/app/modules/resep/controllers/resep_controller.dart';
import 'package:resepsisakulkas/app/routes/app_routes.dart';
import 'package:resepsisakulkas/app/utils/daftar_belanja.dart';

import 'helpers/aplikasi_uji.dart';
import 'helpers/katalog_contoh.dart';
import 'helpers/palsu.dart';

/// Daftar belanja: logika murni, controller (+ kulkas), dan alur di layar.
void main() {
  setUpAll(() => initializeDateFormatting('id_ID'));

  group('logika daftar (murni)', () {
    test('tambah: bahan baru masuk, yang sudah menunggu dilewati', () {
      final a = tambahKeDaftar([], [
        'tempe',
        'kecap',
        'tempe',
      ], resepId: 'orek');
      expect(a.ditambah, 2);
      expect(a.daftar.map((e) => e.bahanId), ['tempe', 'kecap']);
      expect(a.daftar.every((e) => e.resepId == 'orek' && !e.dibeli), isTrue);

      final b = tambahKeDaftar(a.daftar, ['kecap', 'tomat']);
      expect(b.ditambah, 1);
      expect(b.daftar.map((e) => e.bahanId), ['tempe', 'kecap', 'tomat']);
      // Daftar asal tidak dimutasi.
      expect(a.daftar, hasLength(2));
    });

    test('tambah bahan yang sudah dibeli → perlu dibeli lagi', () {
      final awal = [
        const ItemBelanja(bahanId: 'tempe', dibeli: true, masukKulkas: true),
      ];
      final hasil = tambahKeDaftar(awal, ['tempe'], resepId: 'orek');
      expect(hasil.ditambah, 1);
      expect(hasil.daftar.single.dibeli, isFalse);
      expect(hasil.daftar.single.masukKulkas, isFalse);
      expect(hasil.daftar.single.resepId, 'orek');
    });

    test('belumDiDaftar mengabaikan baris yang sudah dibeli', () {
      final daftar = [
        const ItemBelanja(bahanId: 'tempe'),
        const ItemBelanja(bahanId: 'kecap', dibeli: true),
      ];
      expect(belumDiDaftar(daftar, ['tempe', 'kecap', 'tomat']), {
        'kecap',
        'tomat',
      });
    });

    test('baca: baris rusak & ganda dibuang, tidak melempar', () {
      final daftar = bacaDaftarBelanja([
        {'bahanId': 'tempe', 'dibeli': true, 'masukKulkas': true},
        {'bahanId': 'tempe'},
        {'bahanId': 7},
        {'tanpa': 'id'},
        {'bahanId': 'kecap', 'dibeli': 'ya', 'resepId': 12},
        {'bahanId': ''},
      ]);
      expect(daftar.map((e) => e.bahanId), ['tempe', 'kecap']);
      expect(daftar[0].dibeli, isTrue);
      expect(daftar[1].dibeli, isFalse);
      expect(daftar[1].resepId, isNull);
    });

    test('ItemBelanja toJson/cobaDariJson bolak-balik', () {
      const asli = ItemBelanja(
        bahanId: 'tempe',
        dibeli: true,
        resepId: 'orek',
        masukKulkas: true,
      );
      expect(ItemBelanja.cobaDariJson(asli.toJson())!.toJson(), asli.toJson());
      expect(
        const ItemBelanja(bahanId: 'x').toJson().containsKey('resepId'),
        isFalse,
      );
    });

    test('teks untuk disalin', () {
      final teks = teksDaftarBelanja([
        const ItemBelanja(bahanId: 'tempe'),
        const ItemBelanja(bahanId: 'hilang'),
        const ItemBelanja(bahanId: 'kecap', dibeli: true),
      ], katalogKecil().bahanById);
      expect(
        teks,
        'Daftar belanja (ResepSisaKulkas)\n'
        '☐ tempe\n'
        '☐ hilang\n'
        '\n'
        'Sudah dibeli:\n'
        '☑ kecap',
      );
    });
  });

  group('BelanjaController', () {
    late StorageMemori storage;
    final kini = DateTime(2026, 11, 16, 9);

    Future<BelanjaController> siapkan({
      Set<String> kulkas = const {},
      List<Map<String, dynamic>> tersimpan = const [],
    }) async {
      siapkanDependensi(
        ambil: () async =>
            HasilAmbil(katalog: katalogKecil(), sumber: SumberData.bawaan),
        kulkas: kulkas,
        mentah: {
          if (tersimpan.isNotEmpty) StorageService.kunciBelanja: tersimpan,
        },
        jam: () => kini,
      );
      storage = Get.find<StorageService>() as StorageMemori;
      await Future<void>.delayed(Duration.zero);
      return Get.find<BelanjaController>();
    }

    tearDown(Get.reset);

    test('tambah tersimpan ke storage', () async {
      final c = await siapkan();
      expect(c.tambah(['tempe', 'kecap'], resepId: 'orek'), 2);
      expect(c.tambah(['tempe']), 0);
      expect(c.jumlahPerlu, 2);
      expect(c.menunggu('tempe'), isTrue);
      await Future<void>.delayed(Duration.zero);
      expect(storage.bacaDaftarPeta(StorageService.kunciBelanja), [
        {
          'bahanId': 'tempe',
          'dibeli': false,
          'resepId': 'orek',
          'masukKulkas': false,
        },
        {
          'bahanId': 'kecap',
          'dibeli': false,
          'resepId': 'orek',
          'masukKulkas': false,
        },
      ]);
    });

    test('dimuat kembali dari storage', () async {
      final c = await siapkan(
        tersimpan: [
          {'bahanId': 'tempe', 'dibeli': false},
          {'bahanId': 'kecap', 'dibeli': true, 'masukKulkas': true},
          {'rusak': true},
        ],
      );
      expect(c.perluDibeli.map((e) => e.bahanId), ['tempe']);
      expect(c.sudahDibeli.map((e) => e.bahanId), ['kecap']);
    });

    test('centang dibeli → langsung masuk kulkas dengan tanggal', () async {
      final c = await siapkan();
      final kulkas = Get.find<KulkasController>();
      c.tambah(['tempe']);
      c.setelDibeli('tempe', true);

      expect(kulkas.bahanDimiliki, {'tempe'});
      expect(kulkas.sejak['tempe'], kini);
      expect(c.sudahDibeli.single.masukKulkas, isTrue);
      expect(c.jumlahPerlu, 0);
    });

    test('batal centang → dilepas lagi dari kulkas', () async {
      final c = await siapkan();
      final kulkas = Get.find<KulkasController>();
      c.tambah(['tempe']);
      c.toggleDibeli('tempe');
      c.toggleDibeli('tempe');

      expect(kulkas.bahanDimiliki, isEmpty);
      expect(c.perluDibeli.single.masukKulkas, isFalse);
    });

    test(
      'bahan yang sudah ada di kulkas tidak dilepas saat batal centang',
      () async {
        final c = await siapkan(kulkas: {'tempe'});
        final kulkas = Get.find<KulkasController>();
        c.tambah(['tempe']);
        c.setelDibeli('tempe', true);
        expect(c.sudahDibeli.single.masukKulkas, isFalse);
        c.setelDibeli('tempe', false);
        expect(kulkas.bahanDimiliki, {'tempe'});
      },
    );

    test('hapus & kembalikan (urungkan) di posisi semula', () async {
      final c = await siapkan();
      c.tambah(['tempe', 'kecap', 'tomat']);
      final terhapus = c.hapus('kecap')!;
      expect(c.daftar.map((e) => e.bahanId), ['tempe', 'tomat']);
      c.kembalikan(terhapus.posisi, terhapus.item);
      expect(c.daftar.map((e) => e.bahanId), ['tempe', 'kecap', 'tomat']);
      // Tidak menggandakan.
      c.kembalikan(0, terhapus.item);
      expect(c.daftar, hasLength(3));
      expect(c.hapus('tidak-ada'), isNull);
    });

    test('bersihkan yang sudah dibeli; bahannya tetap di kulkas', () async {
      final c = await siapkan();
      final kulkas = Get.find<KulkasController>();
      c.tambah(['tempe', 'kecap']);
      c.setelDibeli('tempe', true);
      expect(c.bersihkanDibeli(), 1);
      expect(c.daftar.map((e) => e.bahanId), ['kecap']);
      expect(kulkas.bahanDimiliki, {'tempe'});
      expect(c.bersihkanDibeli(), 0);
    });
  });

  group('alur di layar', () {
    Future<void> buka(WidgetTester tester, {String rute = Routes.resep}) async {
      tester.view.physicalSize = const Size(412 * 2, 915 * 2);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);
      siapkanDependensi(
        ambil: () async =>
            HasilAmbil(katalog: katalogKecil(), sumber: SumberData.bawaan),
        kulkas: {'telur', 'kecap'},
      );
      await tester.pumpWidget(aplikasiUji(rute: rute));
      await tester.pumpAndSettle();
    }

    testWidgets('kartu resep → belanja → centang → masuk kulkas', (
      tester,
    ) async {
      await buka(tester);
      final belanja = Get.find<BelanjaController>();
      final kulkas = Get.find<KulkasController>();
      // Chip filter kedua bisa berada di luar lebar layar; pilih lewat
      // controller.
      Get.find<ResepController>().pilihFilter(FilterHasil.kurangSedikit);
      await tester.pumpAndSettle();

      // 'orek' kurang tempe.
      await tester.tap(find.byKey(const Key('belanja-orek')));
      await tester.pump();
      expect(belanja.daftar.single.bahanId, 'tempe');
      expect(belanja.daftar.single.resepId, 'orek');
      expect(
        find.text('1 bahan ditambahkan ke daftar belanja'),
        findsOneWidget,
      );
      for (var i = 0; i < 8; i++) {
        await tester.pump(const Duration(seconds: 1));
      }
      // Lencana jumlah di tab Belanja.
      expect(
        find.descendant(
          of: find.byKey(const Key('nav-belanja')),
          matching: find.text('1'),
        ),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const Key('nav-belanja')));
      await tester.pumpAndSettle();
      expect(Get.find<MainController>().indexTab.value, 3);
      expect(find.text('PERLU DIBELI (1)'), findsOneWidget);
      expect(find.text('untuk orek'), findsOneWidget);

      await tester.tap(find.byKey(const Key('belanja-tempe')));
      await tester.pumpAndSettle();
      expect(kulkas.bahanDimiliki, {'telur', 'kecap', 'tempe'});
      expect(find.text('SUDAH DIBELI (1)'), findsOneWidget);
      expect(find.text('Sudah masuk kulkas'), findsOneWidget);
      expect(find.byKey(const Key('belanja-beres')), findsOneWidget);

      await tester.tap(find.byKey(const Key('bersihkan-dibeli')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('belanja-kosong')), findsOneWidget);
      expect(kulkas.bahanDimiliki, contains('tempe'));
      await bersihkan(tester);
    });

    testWidgets('detail → tambah bahan kurang, lalu tombol jadi pintasan', (
      tester,
    ) async {
      await buka(tester, rute: Routes.kulkas);
      Get.toNamed(Routes.keDetail('campur'));
      await tester.pumpAndSettle();
      final belanja = Get.find<BelanjaController>();

      final tombol = find.byKey(const Key('tambah-belanja'));
      await tester.ensureVisible(tombol);
      await tester.pumpAndSettle();
      expect(find.text('Tambah 2 bahan kurang ke belanja'), findsOneWidget);
      await tester.tap(tombol);
      await tester.pump();
      expect(belanja.daftar.map((e) => e.bahanId), ['tempe', 'tomat']);
      for (var i = 0; i < 8; i++) {
        await tester.pump(const Duration(seconds: 1));
      }
      expect(find.text('Sudah di daftar belanja · lihat'), findsOneWidget);

      await tester.tap(tombol);
      await tester.pumpAndSettle();
      expect(Get.currentRoute, Routes.kulkas);
      expect(Get.find<MainController>().indexTab.value, 3);
      await bersihkan(tester);
    });

    testWidgets('tambah manual lewat lembar, hapus, lalu urungkan', (
      tester,
    ) async {
      await buka(tester, rute: Routes.belanja);
      final belanja = Get.find<BelanjaController>();
      expect(find.byKey(const Key('belanja-kosong')), findsOneWidget);

      await tester.tap(find.byKey(const Key('tambah-belanja-manual')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('lembar-tambah-belanja')), findsOneWidget);
      // Bahan di kulkas (telur, kecap) dan bumbu dasar tidak ditawarkan.
      expect(find.byKey(const Key('pilih-belanja-telur')), findsNothing);
      expect(find.byKey(const Key('pilih-belanja-garam')), findsNothing);
      await tester.tap(find.byKey(const Key('pilih-belanja-tempe')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('pilih-belanja-tomat')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('pilih-belanja-tomat')));
      await tester.pumpAndSettle();
      expect(belanja.daftar.map((e) => e.bahanId), ['tempe']);
      await tester.tap(find.byKey(const Key('selesai-tambah-belanja')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('hapus-belanja-tempe')));
      await tester.pump();
      expect(belanja.daftar, isEmpty);
      await tester.pump(const Duration(milliseconds: 600));
      await tester.tap(find.text('Urungkan'));
      await tester.pump();
      expect(belanja.daftar.single.bahanId, 'tempe');
      await bersihkan(tester);
    });
  });
}
