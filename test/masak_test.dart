import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:resepsisakulkas/app/data/models/belanja_model.dart';
import 'package:resepsisakulkas/app/data/models/katalog_model.dart';
import 'package:resepsisakulkas/app/data/services/storage_service.dart';
import 'package:resepsisakulkas/app/modules/favorit/controllers/riwayat_controller.dart';
import 'package:resepsisakulkas/app/modules/kulkas/controllers/kulkas_controller.dart';
import 'package:resepsisakulkas/app/modules/masak/controllers/masak_controller.dart';
import 'package:resepsisakulkas/app/routes/app_routes.dart';
import 'package:resepsisakulkas/app/utils/durasi_langkah.dart';
import 'package:resepsisakulkas/app/utils/formatter.dart';

import 'helpers/aplikasi_uji.dart';
import 'helpers/katalog_contoh.dart';
import 'helpers/palsu.dart';

/// Mode masak: durasi langkah, timer, pengurangan stok, dan riwayat.
void main() {
  late Katalog asli;
  final kini = DateTime(2026, 11, 16, 18, 30);

  setUpAll(() async {
    await initializeDateFormatting('id_ID');
    asli = Katalog.fromJson(
      jsonDecode(await rootBundle.loadString('assets/data/resep.json'))
          as Map<String, dynamic>,
    );
  });

  group('durasiLangkah', () {
    test('menit, detik, jam', () {
      expect(
        durasiLangkah('Rendam tempe selama 10 menit.'),
        const Duration(minutes: 10),
      );
      expect(durasiLangkah('Aduk 30 detik saja.'), const Duration(seconds: 30));
      expect(durasiLangkah('Ungkep 1 jam.'), const Duration(hours: 1));
      expect(
        durasiLangkah('Goreng sekitar 3 Menit tiap sisi.'),
        const Duration(minutes: 3),
      );
    });

    test('rentang memakai angka terkecil', () {
      expect(durasiLangkah('Masak 5–7 menit.'), const Duration(minutes: 5));
      expect(durasiLangkah('Masak 5-7 menit.'), const Duration(minutes: 5));
      expect(durasiLangkah('Masak 5 - 7 menit.'), const Duration(minutes: 5));
    });

    test('angka bersatuan lain diabaikan', () {
      expect(durasiLangkah('Tuang 400 ml air dan 2 sdm kecap.'), isNull);
      expect(durasiLangkah('Potong 1 cm.'), isNull);
      expect(durasiLangkah('Tumis hingga harum.'), isNull);
      expect(durasiLangkah('Masak 0 menit.'), isNull);
      expect(durasiLangkah('Semenit saja.'), isNull);
    });

    test('beberapa durasi → yang pertama; satuan harus kata utuh', () {
      expect(
        durasiLangkah('Tuang 100 ml, rebus 15 menit lalu diamkan 5 menit.'),
        const Duration(minutes: 15),
      );
      expect(durasiLangkah('Butuh 3 menitan.'), isNull);
    });

    test('format & ucapan timer', () {
      expect(formatTimer(0), '00:00');
      expect(formatTimer(65), '01:05');
      expect(formatTimer(3900), '1:05:00');
      expect(formatTimer(-4), '00:00');
      expect(ucapTimer(0), '0 detik');
      expect(ucapTimer(330), '5 menit 30 detik');
      expect(ucapTimer(3600), '1 jam');
    });

    test('katalog: banyak langkah berdurasi, semuanya masuk akal', () {
      var berdurasi = 0;
      for (final r in asli.resep) {
        for (final l in r.langkah) {
          final d = durasiLangkah(l);
          if (d == null) continue;
          berdurasi++;
          expect(d.inSeconds, greaterThanOrEqualTo(30), reason: '${r.id}: $l');
          expect(
            d.inMinutes,
            lessThanOrEqualTo(r.waktuMenit),
            reason: '${r.id}: durasi langkah melebihi waktu resep ($l)',
          );
        }
      }
      expect(berdurasi, greaterThan(40));
    });
  });

  test('formatWaktuMasak relatif terhadap hari ini', () {
    expect(
      formatWaktuMasak(DateTime(2026, 11, 16, 7, 5), kini),
      'Hari ini, 07.05',
    );
    expect(
      formatWaktuMasak(DateTime(2026, 11, 15, 23, 59), kini),
      'Kemarin, 23.59',
    );
    expect(
      formatWaktuMasak(DateTime(2026, 10, 13, 10, 20), kini),
      '13 Okt, 10.20',
    );
  });

  group('RiwayatController', () {
    late StorageMemori storage;

    Future<RiwayatController> siapkan({
      List<Map<String, dynamic>> tersimpan = const [],
      DateTime Function()? jam,
    }) async {
      siapkanDependensi(
        ambil: () async =>
            HasilAmbil(katalog: katalogKecil(), sumber: SumberData.bawaan),
        mentah: {
          if (tersimpan.isNotEmpty) StorageService.kunciRiwayat: tersimpan,
        },
        jam: jam ?? () => kini,
      );
      storage = Get.find<StorageService>() as StorageMemori;
      await Future<void>.delayed(Duration.zero);
      return Get.find<RiwayatController>();
    }

    tearDown(Get.reset);

    test('catat: terbaru di depan, tersimpan, jumlahMasak', () async {
      var waktu = kini;
      final c = await siapkan(jam: () => waktu);
      final katalog = katalogKecil();
      c.catat(katalog.resepById('dadar')!);
      waktu = kini.add(const Duration(hours: 2));
      c.catat(katalog.resepById('orek')!);
      waktu = kini.add(const Duration(days: 1));
      c.catat(katalog.resepById('dadar')!);

      expect(c.riwayat.map((e) => e.resepId), ['dadar', 'orek', 'dadar']);
      expect(c.jumlahMasak('dadar'), 2);
      expect(c.jumlahMasak('campur'), 0);
      await Future<void>.delayed(Duration.zero);
      final simpan = storage.bacaDaftarPeta(StorageService.kunciRiwayat);
      expect(simpan, hasLength(3));
      expect(simpan.first, {
        'resepId': 'dadar',
        'nama': 'dadar',
        'waktu': kini.add(const Duration(days: 1)).toIso8601String(),
      });
    });

    test('dimuat: catatan rusak dibuang, diurutkan terbaru dulu', () async {
      final c = await siapkan(
        tersimpan: [
          {'resepId': 'orek', 'nama': 'Orek', 'waktu': '2026-11-10T08:00:00'},
          {'resepId': 'dadar', 'waktu': '2026-11-15T08:00:00'},
          {'resepId': 'x', 'waktu': 'kemarin'},
          {'nama': 'tanpa id', 'waktu': '2026-11-15T08:00:00'},
        ],
      );
      expect(c.riwayat.map((e) => e.resepId), ['dadar', 'orek']);
      expect(c.riwayat.first.nama, 'dadar', reason: 'nama kosong → id');
    });

    test('dibatasi 100 catatan terbaru', () async {
      var n = 0;
      final c = await siapkan(jam: () => kini.add(Duration(minutes: n++)));
      final resep = katalogKecil().resepById('dadar')!;
      for (var i = 0; i < RiwayatController.maksCatatan + 15; i++) {
        c.catat(resep);
      }
      expect(c.riwayat, hasLength(RiwayatController.maksCatatan));
      expect(c.riwayat.first.waktu.isAfter(c.riwayat.last.waktu), isTrue);
    });

    test('CatatanMasak toJson/cobaDariJson bolak-balik', () {
      final asal = CatatanMasak(resepId: 'dadar', nama: 'Dadar', waktu: kini);
      expect(CatatanMasak.cobaDariJson(asal.toJson())!.toJson(), asal.toJson());
    });
  });

  group('mode masak di layar', () {
    Future<void> buka(
      WidgetTester tester, {
      String id = 'sop-ayam',
      Set<String> kulkas = const {'ayam', 'wortel', 'kentang', 'bawang-putih'},
      Set<String> segera = const {},
      bool lewatDetail = true,
    }) async {
      tester.view.physicalSize = const Size(412 * 2, 915 * 2);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);
      siapkanDependensi(
        ambil: () async => HasilAmbil(katalog: asli, sumber: SumberData.bawaan),
        kulkas: kulkas,
        segera: segera,
        jam: () => kini,
      );
      await tester.pumpWidget(
        aplikasiUji(rute: lewatDetail ? Routes.kulkas : Routes.keMasak(id)),
      );
      await tester.pumpAndSettle();
      if (lewatDetail) {
        Get.toNamed(Routes.keDetail(id));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('mulai-masak')));
        await tester.pumpAndSettle();
      }
    }

    testWidgets('langkah demi langkah → selesai → stok berkurang + riwayat', (
      tester,
    ) async {
      await buka(tester, segera: {'ayam'});
      final c = Get.find<MasakController>();
      final kulkas = Get.find<KulkasController>();
      final riwayat = Get.find<RiwayatController>();
      expect(Get.currentRoute, '/resep/sop-ayam/masak');
      expect(find.text('Langkah 1 dari 5'), findsOneWidget);
      expect(find.byKey(const Key('langkah-sebelum')), findsNothing);

      for (var i = 1; i < 5; i++) {
        await tester.tap(find.byKey(const Key('langkah-berikut')));
        await tester.pumpAndSettle();
        expect(find.text('Langkah ${i + 1} dari 5'), findsOneWidget);
      }
      expect(find.text('Selesai memasak'), findsOneWidget);
      await tester.tap(find.byKey(const Key('langkah-sebelum')));
      await tester.pumpAndSettle();
      expect(c.halaman.value, 3);
      await tester.tap(find.byKey(const Key('langkah-berikut')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('langkah-berikut')));
      await tester.pumpAndSettle();

      // Layar selesai: bahan terpakai yang ada di kulkas; yang segera habis
      // sudah diusulkan.
      expect(find.text('Selamat makan!'), findsOneWidget);
      expect(find.byKey(const Key('langkah-berikut')), findsNothing);
      expect(c.bahanTerpakai.map((b) => b.id), [
        'ayam',
        'wortel',
        'kentang',
        'bawang-putih',
      ]);
      expect(c.habis, {'ayam'});
      await tester.ensureVisible(find.byKey(const Key('habis-wortel')));
      await tester.tap(find.byKey(const Key('habis-wortel')));
      await tester.pumpAndSettle();
      expect(find.text('Catat & lepas 2 bahan'), findsOneWidget);

      await tester.ensureVisible(find.byKey(const Key('simpan-selesai')));
      await tester.tap(find.byKey(const Key('simpan-selesai')));
      await tester.pumpAndSettle();

      expect(kulkas.bahanDimiliki, {'kentang', 'bawang-putih'});
      expect(kulkas.ditandaiSegera, isEmpty);
      expect(riwayat.riwayat.single.resepId, 'sop-ayam');
      expect(riwayat.riwayat.single.waktu, kini);
      // Kembali ke detail, yang kini menampilkan jumlah dimasak.
      expect(Get.currentRoute, '/resep/sop-ayam');
      expect(find.text('Dimasak 1×'), findsOneWidget);
      await bersihkan(tester);
    });

    testWidgets('tanpa bahan habis: kulkas utuh, tetap tercatat', (
      tester,
    ) async {
      await buka(tester, lewatDetail: false);
      final c = Get.find<MasakController>();
      c.pageController.jumpToPage(c.jumlahLangkah);
      await tester.pumpAndSettle();
      expect(c.habis, isEmpty);
      expect(find.text('Catat ke riwayat masak'), findsOneWidget);
      await tester.ensureVisible(find.byKey(const Key('simpan-selesai')));
      await tester.tap(find.byKey(const Key('simpan-selesai')));
      await tester.pumpAndSettle();
      expect(Get.find<KulkasController>().bahanDimiliki, hasLength(4));
      expect(Get.find<RiwayatController>().jumlahMasak('sop-ayam'), 1);
      // Dibuka langsung (tanpa riwayat navigasi) → kembali ke Kulkas.
      expect(Get.currentRoute, Routes.kulkas);
      await bersihkan(tester);
    });

    testWidgets('timer: mulai, hitung mundur, jeda, +1 menit, habis', (
      tester,
    ) async {
      await buka(tester, lewatDetail: false);
      final c = Get.find<MasakController>();
      // Langkah 1 sop ayam: "… merebus selama 15 menit."
      expect(c.durasi(0), const Duration(minutes: 15));
      expect(c.durasi(1), isNull);
      expect(find.text('15:00'), findsOneWidget);

      await tester.tap(find.byKey(const Key('timer-mulai-0')));
      await tester.pump();
      expect(c.berjalanDi(0), isTrue);
      await tester.pump(const Duration(seconds: 3));
      expect(c.sisaDetik.value, 15 * 60 - 3);
      expect(find.text('14:57'), findsOneWidget);
      expect(find.text('Jeda'), findsOneWidget);

      await tester.tap(find.byKey(const Key('timer-mulai-0')));
      await tester.pump();
      expect(c.berjalanDi(0), isFalse);
      await tester.pump(const Duration(seconds: 5));
      expect(c.sisaDetik.value, 15 * 60 - 3, reason: 'jeda: tidak berkurang');
      expect(find.text('Lanjutkan'), findsOneWidget);

      await tester.tap(find.byKey(const Key('timer-tambah-0')));
      await tester.pump();
      expect(c.sisaDetik.value, 16 * 60 - 3);

      await tester.tap(find.byKey(const Key('timer-ulang-0')));
      await tester.pump();
      expect(c.sisaDetik.value, 15 * 60);

      // Percepat: sisakan 2 detik lalu jalankan sampai habis.
      c.sisaDetik.value = 2;
      await tester.tap(find.byKey(const Key('timer-mulai-0')));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(c.sisaDetik.value, 1);
      await tester.pump(const Duration(seconds: 1));
      expect(c.sisaDetik.value, 0);
      expect(c.habisDi(0), isTrue);
      expect(c.timerJalan.value, isFalse);
      await tester.pump();
      expect(find.text('Waktu habis'), findsOneWidget);
      expect(
        find.text('Waktu langkah 1 habis. Cek masakanmu!'),
        findsOneWidget,
      );
      expect(find.text('Ulangi'), findsOneWidget);
      await bersihkan(tester);
    });

    testWidgets('tutup di tengah jalan meminta konfirmasi', (tester) async {
      await buka(tester);
      await tester.tap(find.byKey(const Key('langkah-berikut')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('tutup-masak')));
      await tester.pumpAndSettle();
      expect(find.text('Berhenti memasak?'), findsOneWidget);
      await tester.tap(find.text('Lanjut masak'));
      await tester.pumpAndSettle();
      expect(Get.currentRoute, '/resep/sop-ayam/masak');

      await tester.tap(find.byKey(const Key('tutup-masak')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Berhenti'));
      await tester.pumpAndSettle();
      expect(Get.currentRoute, '/resep/sop-ayam');
      expect(Get.find<RiwayatController>().riwayat, isEmpty);
      await bersihkan(tester);
    });

    testWidgets('lembar bahan menampilkan takaran', (tester) async {
      await buka(tester, lewatDetail: false);
      await tester.tap(find.byKey(const Key('lihat-bahan')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('lembar-bahan-masak')), findsOneWidget);
      expect(find.text('250 gram, potong kecil'), findsOneWidget);
      expect(find.text('3 lembar, potong (opsional)'), findsOneWidget);
      await bersihkan(tester);
    });

    testWidgets('riwayat tampil di tab Favorit dan membuka detail', (
      tester,
    ) async {
      await buka(tester, lewatDetail: false);
      Get.find<RiwayatController>().catat(asli.resepById('orek-tempe')!);
      Get.offAllNamed(Routes.favorit);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('favorit-kosong')), findsOneWidget);

      await tester.tap(find.byKey(const Key('segmen-riwayat')));
      await tester.pumpAndSettle();
      expect(find.text('Orek Tempe Manis Pedas'), findsOneWidget);
      expect(find.text('Hari ini, 18.30'), findsOneWidget);
      await tester.tap(find.byKey(const Key('riwayat-0')));
      await tester.pumpAndSettle();
      expect(Get.currentRoute, '/resep/orek-tempe');
      await bersihkan(tester);
    });
  });
}
