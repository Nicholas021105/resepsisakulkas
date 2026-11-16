import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:resepsisakulkas/app/data/models/hasil_cocok.dart';
import 'package:resepsisakulkas/app/data/models/katalog_model.dart';
import 'package:resepsisakulkas/app/data/models/resep_model.dart';
import 'package:resepsisakulkas/app/modules/resep/controllers/resep_controller.dart';
import 'package:resepsisakulkas/app/routes/app_routes.dart';
import 'package:resepsisakulkas/app/utils/pencocok_resep.dart';
import 'package:resepsisakulkas/app/widgets/sampul_resep.dart';

import 'helpers/aplikasi_uji.dart';
import 'helpers/katalog_contoh.dart';

/// Jelajah resep: pencarian, kategori, urutan, dan saran hari ini.
void main() {
  late Katalog asli;

  setUpAll(() async {
    await initializeDateFormatting('id_ID');
    asli = Katalog.fromJson(
      jsonDecode(await rootBundle.loadString('assets/data/resep.json'))
          as Map<String, dynamic>,
    );
  });

  Resep r(
    String id, {
    int waktu = 10,
    TingkatResep tingkat = TingkatResep.mudah,
    KategoriResep kategori = KategoriResep.lauk,
    List<String> bahan = const ['telur', 'kecap'],
  }) => Resep(
    id: id,
    nama: id,
    deskripsi: '-',
    waktuMenit: waktu,
    porsi: 1,
    tingkat: tingkat,
    kategori: kategori,
    bahan: [for (final b in bahan) pakai(b)],
    langkah: const ['a', 'b', 'c'],
  );

  List<HasilCocok> cocok(List<Resep> resep, Set<String> kulkas) =>
      cocokkanSemua(
        Katalog(versi: 2, bahan: katalogKecil().bahan, resep: resep),
        kulkas,
        bumbuDasarAda: true,
      );

  group('jelajahResep', () {
    final byId = katalogKecil().bahanById;
    final hasil = cocok(
      [
        r('Orek Tempe', bahan: ['tempe', 'kecap']),
        r(
          'Telur Dadar',
          kategori: KategoriResep.sarapan,
          bahan: ['telur', 'garam'],
        ),
        r(
          'Sayur Tomat',
          kategori: KategoriResep.sayur,
          bahan: ['tomat', 'tempe'],
        ),
      ],
      {'telur'},
    );

    List<String> cari(String kata, {KategoriResep? kategori}) => jelajahResep(
      hasil,
      kataKunci: kata,
      kategori: kategori,
      bahanById: byId,
    ).map((h) => h.resep.id).toList();

    test('tanpa kata & kategori: daftar apa adanya', () {
      expect(identical(jelajahResep(hasil), hasil), isTrue);
    });

    test('cocok nama resep, tanpa membedakan huruf besar', () {
      expect(cari('DADAR'), ['Telur Dadar']);
      expect(cari('  orek  '), ['Orek Tempe']);
    });

    test('cocok nama bahan: "tempe" menemukan dua resep', () {
      expect(cari('tempe'), unorderedEquals(['Orek Tempe', 'Sayur Tomat']));
    });

    test('beberapa kata harus cocok semua', () {
      expect(cari('tempe tomat'), ['Sayur Tomat']);
      expect(cari('tempe rendang'), isEmpty);
    });

    test('kategori, sendiri dan digabung kata kunci', () {
      expect(cari('', kategori: KategoriResep.sarapan), ['Telur Dadar']);
      expect(cari('tempe', kategori: KategoriResep.sayur), ['Sayur Tomat']);
      expect(cari('tempe', kategori: KategoriResep.camilan), isEmpty);
    });

    test('urutan kecocokan dipertahankan', () {
      expect(cari('e').first, hasil.first.resep.id);
    });
  });

  group('urutkanHasil', () {
    final hasil = cocok(
      [
        r('lama-mudah', waktu: 40),
        r('cepat-sulit', waktu: 5, tingkat: TingkatResep.sulit),
        r('sedang', waktu: 20, tingkat: TingkatResep.sedang),
        r('cepat-mudah', waktu: 10),
        r('kembar-mudah', waktu: 10, bahan: ['telur', 'tempe']),
      ],
      {'telur', 'kecap'},
    );

    List<String> urut(UrutanResep u) =>
        urutkanHasil(hasil, u).map((h) => h.resep.id).toList();

    test('paling cocok: daftar yang sama', () {
      expect(identical(urutkanHasil(hasil, UrutanResep.cocok), hasil), isTrue);
    });

    test('tercepat: waktu naik; waktu sama → yang lebih cocok dulu', () {
      expect(urut(UrutanResep.tercepat), [
        'cepat-sulit',
        'cepat-mudah', // 100%
        'kembar-mudah', // 50%
        'sedang',
        'lama-mudah',
      ]);
    });

    test('termudah: tingkat, lalu waktu', () {
      expect(urut(UrutanResep.termudah), [
        'cepat-mudah',
        'kembar-mudah',
        'lama-mudah',
        'sedang',
        'cepat-sulit',
      ]);
    });

    test('daftar asal tidak dimutasi', () {
      final sebelum = hasil.map((h) => h.resep.id).toList();
      urutkanHasil(hasil, UrutanResep.tercepat);
      expect(hasil.map((h) => h.resep.id).toList(), sebelum);
    });
  });

  group('saranHariIni', () {
    test('katalog kosong → null', () {
      expect(saranHariIni(const [], benih: 3), isNull);
    });

    test('benih sama → saran sama; benih bergeser → berkeliling kandidat', () {
      final hasil = cocokkanSemua(asli, {
        'telur',
        'tempe',
        'kecap-manis',
        'bawang-merah',
        'bawang-putih',
      }, bumbuDasarAda: true);
      final a = saranHariIni(hasil, benih: 100)!;
      expect(saranHariIni(hasil, benih: 100)!.resep.id, a.resep.id);
      final keliling = {
        for (var i = 0; i < 5; i++) saranHariIni(hasil, benih: i)!.resep.id,
      };
      expect(keliling, hasLength(5));
      // Hanya dari lima teratas yang hampir bisa dimasak.
      expect(keliling, hasil.take(5).map((h) => h.resep.id).toSet());
      for (var i = 0; i < 30; i++) {
        final s = saranHariIni(hasil, benih: i)!;
        expect(s.kurang.length, lessThanOrEqualTo(batasKurangPrioritas));
      }
    });

    test(
      'resep penyelamat bahan segera habis selalu jadi kandidat pertama',
      () {
        final hasil = cocokkanSemua(
          asli,
          {'bayam', 'bawang-merah', 'telur'},
          bumbuDasarAda: true,
          segera: {'bayam'},
        );
        final s = saranHariIni(hasil, benih: 0)!;
        expect(s.resep.id, 'sayur-bening-bayam');
        expect(s.segera, ['bayam']);
      },
    );

    test('kulkas kosong → inspirasi dari seluruh katalog', () {
      final hasil = cocokkanSemua(asli, {}, bumbuDasarAda: false);
      final id = {
        for (var i = 0; i < asli.resep.length; i++)
          saranHariIni(hasil, benih: i)!.resep.id,
      };
      expect(id, hasLength(asli.resep.length));
    });

    test('benih negatif tidak membuat crash', () {
      final hasil = cocokkanSemua(asli, {'telur'}, bumbuDasarAda: true);
      expect(saranHariIni(hasil, benih: -7), isNotNull);
    });
  });

  group('sampul resep', () {
    test('nada mengikuti bahan', () {
      NadaSampul nada(String id) => nadaSampul(asli.resepById(id)!);
      expect(nada('opor-ayam'), NadaSampul.krem);
      expect(nada('telur-balado'), NadaSampul.merah);
      expect(nada('orek-tempe'), NadaSampul.cokelat);
      expect(nada('tumis-kangkung'), NadaSampul.hijau);
      expect(nada('telur-dadar'), NadaSampul.kuning);
      expect(nada('tempe-goreng'), NadaSampul.emas);
    });

    testWidgets('semua sajian × nada tergambar tanpa error', (tester) async {
      siapkanDependensi(
        ambil: () async => HasilAmbil(katalog: asli, sumber: SumberData.bawaan),
      );
      await tester.pump();
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: SingleChildScrollView(
            child: Wrap(
              children: [
                for (final resep in asli.resep)
                  SampulResep(resep: resep, ukuran: 40),
              ],
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.byType(SampulResep), findsNWidgets(asli.resep.length));
      // Setiap jenis sajian terwakili di katalog.
      expect(
        asli.resep.map((r) => r.sajian).toSet(),
        JenisSajian.values.toSet(),
      );
      await tester.pumpWidget(const SizedBox());
      Get.reset();
    });
  });

  group('tab Resep di layar', () {
    Future<ResepController> buka(WidgetTester tester) async {
      tester.view.physicalSize = const Size(412 * 2, 915 * 2);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);
      siapkanDependensi(
        ambil: () async => HasilAmbil(katalog: asli, sumber: SumberData.bawaan),
        kulkas: {'telur', 'bawang-merah', 'kecap-manis'},
        jam: () => DateTime(2026, 11, 16, 9),
      );
      await tester.pumpWidget(aplikasiUji(rute: Routes.resep));
      await tester.pumpAndSettle();
      return Get.find<ResepController>();
    }

    Future<void> ketik(WidgetTester tester, String teks) async {
      await tester.enterText(find.byKey(const Key('cari-resep')), teks);
      await tester.pump(ResepController.jedaPencarian * 2);
      await tester.pumpAndSettle();
    }

    testWidgets('cari dengan debounce; resep 0% ditemukan lewat "Semua"', (
      tester,
    ) async {
      final c = await buka(tester);
      expect(find.byKey(const Key('saran-hari-ini')), findsOneWidget);

      await tester.enterText(find.byKey(const Key('cari-resep')), 'opor');
      await tester.pump(const Duration(milliseconds: 100));
      expect(c.sedangMencari, isFalse, reason: 'belum lewat debounce');
      await tester.pump(ResepController.jedaPencarian);
      await tester.pumpAndSettle();
      expect(c.sedangMencari, isTrue);

      // Opor tidak "siap dimasak" → keadaan kosong menawarkan jalan keluar.
      expect(find.byKey(const Key('saran-hari-ini')), findsNothing);
      expect(find.text('Tidak ada di "Siap dimasak"'), findsOneWidget);
      expect(c.jumlahPerFilter[FilterHasil.semua], 1);
      await tester.tap(find.byKey(const Key('aksi-kosong')));
      await tester.pumpAndSettle();
      expect(c.filter.value, FilterHasil.semua);
      expect(find.byKey(const Key('resep-opor-ayam')), findsOneWidget);
      expect(c.state!.single.resep.id, 'opor-ayam');

      // Hapus pencarian → saran muncul lagi.
      await tester.tap(find.byKey(const Key('hapus-cari-resep')));
      await tester.pumpAndSettle();
      expect(c.sedangMencari, isFalse);
      expect(find.byKey(const Key('saran-hari-ini')), findsOneWidget);
      await bersihkan(tester);
    });

    testWidgets('pencarian tanpa hasil → "Resep tidak ditemukan"', (
      tester,
    ) async {
      final c = await buka(tester);
      await ketik(tester, 'rendang sapi wagyu');
      expect(find.text('Resep tidak ditemukan'), findsOneWidget);
      await tester.tap(find.byKey(const Key('aksi-kosong')));
      await tester.pumpAndSettle();
      expect(c.kataKunci.value, isEmpty);
      expect(
        tester
            .widget<TextField>(find.byKey(const Key('cari-resep')))
            .controller!
            .text,
        isEmpty,
      );
      await bersihkan(tester);
    });

    testWidgets('kategori & urutan mengubah daftar', (tester) async {
      final c = await buka(tester);
      c.pilihFilter(FilterHasil.semua);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('kategori-sarapan')));
      await tester.pumpAndSettle();
      expect(c.state, isNotEmpty);
      expect(
        c.state!.every((h) => h.resep.kategori == KategoriResep.sarapan),
        isTrue,
      );
      await tester.tap(find.byKey(const Key('kategori-semua')));
      await tester.pumpAndSettle();
      expect(c.kategori.value, isNull);

      expect(find.byKey(const Key('urutan-aktif')), findsNothing);
      await tester.tap(find.byKey(const Key('urutkan')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('urutan-tercepat')));
      await tester.pumpAndSettle();
      expect(c.urutan.value, UrutanResep.tercepat);
      expect(find.byKey(const Key('urutan-aktif')), findsOneWidget);
      final waktu = c.state!.map((h) => h.resep.waktuMenit).toList();
      expect(waktu, [...waktu]..sort());
      await bersihkan(tester);
    });

    testWidgets('saran: "Saran lain" mengganti, ketuk membuka detail', (
      tester,
    ) async {
      final c = await buka(tester);
      final pertama = c.saran!.resep;
      expect(
        tester.widget<Text>(find.byKey(const Key('nama-saran'))).data,
        pertama.nama,
      );
      await tester.tap(find.byKey(const Key('saran-lain')));
      await tester.pumpAndSettle();
      final kedua = c.saran!.resep;
      expect(kedua.id, isNot(pertama.id));
      expect(
        tester.widget<Text>(find.byKey(const Key('nama-saran'))).data,
        kedua.nama,
      );

      await tester.tap(find.byKey(const Key('nama-saran')));
      await tester.pumpAndSettle();
      expect(Get.currentRoute, Routes.keDetail(kedua.id));
      expect(find.byKey(const Key('detail-header')), findsOneWidget);
      expect(tester.takeException(), isNull);
      await bersihkan(tester);
    });
  });
}
