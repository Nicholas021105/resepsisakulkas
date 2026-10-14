import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:resepsisakulkas/app/data/models/bahan_model.dart';
import 'package:resepsisakulkas/app/data/models/hasil_cocok.dart';
import 'package:resepsisakulkas/app/data/models/katalog_model.dart';
import 'package:resepsisakulkas/app/data/models/resep_model.dart';
import 'package:resepsisakulkas/app/modules/kulkas/controllers/kulkas_controller.dart';
import 'package:resepsisakulkas/app/modules/resep/controllers/resep_controller.dart';
import 'package:resepsisakulkas/app/routes/app_routes.dart';
import 'package:resepsisakulkas/app/widgets/ikon_bahan.dart';
import 'package:resepsisakulkas/app/widgets/kartu_resep.dart';

import 'helpers/aplikasi_uji.dart';

/// Membuka semua route & dialog pada berbagai ukuran layar, textScaler,
/// kondisi data, dan keyboard terbuka (halaman dengan pencarian), lalu
/// memastikan tidak ada exception (termasuk RenderFlex overflow).
enum KondisiData { kosong, ekstrem }

class Layar {
  final String nama;
  final Size ukuran;
  final List<double> skala;

  const Layar(this.nama, this.ukuran, this.skala);
}

const daftarLayar = [
  Layar('320×568', Size(320, 568), [1.0, 1.3, 1.5]),
  Layar('360×640', Size(360, 640), [1.0, 1.3]),
  Layar('412×915', Size(412, 915), [1.0, 1.3]),
  Layar('640×360 landscape', Size(640, 360), [1.0, 1.3]),
];

const namaPanjang = 'Muhammad Abdurrahman Wahyudiantoro Saputra';
final teks150 = List.filled(11, 'Aduk perlahan ').join().substring(0, 150);

/// 42 bahan bernama 40+ karakter (40 dipilih) dan 30 resep bernama panjang;
/// tiap resep memakai 2 bahan yang tidak dipilih agar daftar "kurang" panjang.
Katalog katalogEkstrem() {
  final bahan = [
    for (var i = 0; i < 42; i++)
      Bahan(
        id: 'b$i',
        nama: 'Bahan $namaPanjang $i',
        kategori: KategoriBahan.values[i % 4],
        emoji: '🥚',
        bumbuDasar: i < 2,
      ),
  ];
  final resep = [
    for (var r = 0; r < 30; r++)
      Resep(
        id: 'r$r',
        nama: 'Resep $namaPanjang Spesial $r',
        deskripsi: teks150,
        waktuMenit: 999,
        porsi: 99,
        tingkat: TingkatResep.sedang,
        bahan: [
          for (var j = 0; j < 8; j++)
            BahanResep(
              bahanId: 'b${(r + j) % 40}',
              takaran: '999 gram, potong dadu kecil sekali',
              opsional: j == 7,
            ),
          const BahanResep(bahanId: 'b40', takaran: 'secukupnya'),
          const BahanResep(bahanId: 'b41', takaran: 'secukupnya'),
        ],
        langkah: List.filled(7, teks150),
      ),
  ];
  return Katalog(versi: 1, bahan: bahan, resep: resep);
}

void main() {
  late Katalog katalogAsli;

  setUpAll(() async {
    await initializeDateFormatting('id_ID');
    katalogAsli = Katalog.fromJson(
      jsonDecode(await rootBundle.loadString('assets/data/resep.json'))
          as Map<String, dynamic>,
    );
  });

  Future<void> uji(
    WidgetTester tester,
    String halaman, {
    required String Function(KondisiData kondisi) rute,
    bool keyboard = false,
    bool gagal = false,
    void Function(KondisiData kondisi)? lanjutan,
    Future<void> Function(KondisiData kondisi, String konteks)? cek,
  }) async {
    addTearDown(() {
      tester.view.reset();
      tester.platformDispatcher.clearTextScaleFactorTestValue();
    });
    for (final kondisi in KondisiData.values) {
      for (final layar in daftarLayar) {
        for (final skala in layar.skala) {
          for (final kb in keyboard ? [false, true] : [false]) {
            final konteks =
                '$halaman | ${layar.nama} | textScaler $skala | '
                'data ${kondisi.name}${kb ? ' | keyboard terbuka' : ''}';
            const dpr = 2.0;
            tester.view.devicePixelRatio = dpr;
            tester.view.physicalSize = layar.ukuran * dpr;
            tester.view.viewInsets = kb
                ? const FakeViewPadding(bottom: 300 * dpr)
                : FakeViewPadding.zero;
            tester.platformDispatcher.textScaleFactorTestValue = skala;

            final ekstrem = kondisi == KondisiData.ekstrem;
            final katalog = ekstrem ? katalogEkstrem() : katalogAsli;
            siapkanDependensi(
              ambil: () async {
                if (gagal) throw Exception('gagal');
                return HasilAmbil(
                  katalog: katalog,
                  sumber: SumberData.server,
                  waktu: DateTime(2026, 10, 13, 10, 20),
                );
              },
              kulkas: ekstrem ? {for (var i = 0; i < 40; i++) 'b$i'} : {},
              favorit: ekstrem ? {for (var r = 0; r < 30; r++) 'r$r'} : {},
            );

            await tester.pumpWidget(aplikasiUji(rute: rute(kondisi)));
            await tester.pumpAndSettle();
            if (lanjutan != null) {
              lanjutan(kondisi);
              await tester.pumpAndSettle();
            }

            expect(tester.takeException(), isNull, reason: konteks);
            if (cek != null) {
              await cek(kondisi, konteks);
              expect(tester.takeException(), isNull, reason: konteks);
            }

            await tester.pumpWidget(const SizedBox());
            await tester.pumpAndSettle();
            Get.reset();
          }
        }
      }
    }
  }

  testWidgets('kulkas (dengan pencarian)', (tester) async {
    await uji(tester, '/kulkas', rute: (_) => Routes.kulkas, keyboard: true);
  });

  testWidgets('kulkas + dialog kosongkan', (tester) async {
    await uji(
      tester,
      '/kulkas + dialog kosongkan',
      rute: (_) => Routes.kulkas,
      lanjutan: (_) => Get.find<KulkasController>().konfirmasiKosongkan(),
    );
  });

  testWidgets('resep: filter Siap dimasak', (tester) async {
    await uji(tester, '/resep siap', rute: (_) => Routes.resep);
  });

  testWidgets('resep: filter Kurang 1–2 bahan', (tester) async {
    await uji(
      tester,
      '/resep kurang 1–2',
      rute: (_) => Routes.resep,
      lanjutan: (_) =>
          Get.find<ResepController>().pilihFilter(FilterHasil.kurangSedikit),
    );
  });

  testWidgets('resep: filter Semua', (tester) async {
    await uji(
      tester,
      '/resep semua',
      rute: (_) => Routes.resep,
      lanjutan: (_) =>
          Get.find<ResepController>().pilihFilter(FilterHasil.semua),
    );
  });

  testWidgets('resep: status error', (tester) async {
    await uji(tester, '/resep error', rute: (_) => Routes.resep, gagal: true);
  });

  testWidgets('detail resep valid', (tester) async {
    await uji(
      tester,
      '/resep/:id',
      rute: (k) =>
          Routes.keDetail(k == KondisiData.ekstrem ? 'r0' : 'telur-dadar'),
    );
  });

  testWidgets('detail resep tidak ditemukan', (tester) async {
    await uji(
      tester,
      '/resep/:id (tidak valid)',
      rute: (_) => Routes.keDetail('tidak-ada'),
    );
  });

  testWidgets('favorit', (tester) async {
    await uji(tester, '/favorit', rute: (_) => Routes.favorit);
  });

  testWidgets('pengaturan', (tester) async {
    await uji(tester, '/pengaturan', rute: (_) => Routes.pengaturan);
  });

  // --- Widget hasil poles UI ---

  Future<void> gulirKe(WidgetTester tester, Finder target) async {
    await tester.scrollUntilVisible(
      target,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
  }

  testWidgets('kartu resep dengan pratinjau bahan', (tester) async {
    await uji(
      tester,
      '/resep semua (kartu + pratinjau)',
      rute: (_) => Routes.resep,
      lanjutan: (kondisi) {
        // Data kosong: tempel 2 bahan agar ada kartu dengan bahan kurang.
        if (kondisi == KondisiData.kosong) {
          Get.find<KulkasController>()
            ..toggle('telur')
            ..toggle('tempe');
        }
        Get.find<ResepController>().pilihFilter(FilterHasil.semua);
      },
      cek: (kondisi, konteks) async {
        expect(find.byType(KartuResep), findsWidgets, reason: konteks);
        expect(
          find.byWidgetPredicate(
            (w) =>
                w.key is ValueKey<String> &&
                (w.key! as ValueKey<String>).value.startsWith('pratinjau-'),
          ),
          findsWidgets,
          reason: konteks,
        );
        expect(find.byType(IkonBahan), findsWidgets, reason: konteks);
      },
    );
  });

  testWidgets('detail: header + kolom takaran lebar tetap', (tester) async {
    await uji(
      tester,
      '/resep/:id (header + takaran)',
      rute: (k) =>
          Routes.keDetail(k == KondisiData.ekstrem ? 'r0' : 'nasi-goreng'),
      cek: (kondisi, konteks) async {
        expect(find.byKey(const Key('detail-header')), findsOneWidget);
        expect(find.byKey(const Key('appbar-kembali')), findsOneWidget);
        await gulirKe(tester, find.byKey(const Key('kartu-bahan')));
        final takaran = find.byWidgetPredicate(
          (w) =>
              w.key is ValueKey<String> &&
              (w.key! as ValueKey<String>).value.startsWith('takaran-'),
        );
        final lebar = {
          for (final e in takaran.evaluate())
            (e.renderObject! as RenderBox).size.width,
        };
        expect(lebar, hasLength(1), reason: '$konteks: lebar takaran $lebar');
      },
    );
  });

  testWidgets('pengaturan dengan kartu Tentang', (tester) async {
    await uji(
      tester,
      '/pengaturan (kartu Tentang)',
      rute: (_) => Routes.pengaturan,
      cek: (kondisi, konteks) async {
        expect(find.byKey(const Key('appbar-kembali')), findsOneWidget);
        await gulirKe(tester, find.byKey(const Key('info-data-resep')));
        expect(find.byKey(const Key('kartu-tentang')), findsOneWidget);
        final katalog = kondisi == KondisiData.ekstrem
            ? katalogEkstrem()
            : katalogAsli;
        expect(
          find.text(
            '${katalog.resep.length} resep, ${katalog.bahan.length} bahan',
          ),
          findsOneWidget,
          reason: konteks,
        );
      },
    );
  });

  testWidgets('kulkas: Sayur & Bumbu (ikon pelukis baru)', (tester) async {
    Future<void> cekKategori(
      String kategori,
      List<String> idPelukis,
      KondisiData kondisi,
      String konteks,
    ) async {
      Get.find<KulkasController>().pilihKategori(kategori);
      await tester.pumpAndSettle();
      // Data ekstrem memakai emoji 🥚; pelukis hanya ada di katalog asli.
      if (kondisi == KondisiData.ekstrem) return;
      for (final id in idPelukis) {
        final magnet = find.byKey(Key('magnet-$id'));
        await gulirKe(tester, magnet);
        final ikon = find.descendant(
          of: magnet,
          matching: find.byType(IkonBahan),
        );
        expect(ikon, findsOneWidget, reason: '$konteks: $id');
        expect(
          find.descendant(of: ikon, matching: find.byType(CustomPaint)),
          findsOneWidget,
          reason: '$konteks: $id harus digambar pelukis, bukan emoji',
        );
        expect(tester.getSize(ikon), const Size.square(28), reason: konteks);
      }
    }

    await uji(
      tester,
      '/kulkas Sayur & Bumbu',
      rute: (_) => Routes.kulkas,
      cek: (kondisi, konteks) async {
        await cekKategori('sayur', ['buncis'], kondisi, '$konteks | Sayur');
        expect(tester.takeException(), isNull, reason: '$konteks | Sayur');
        await cekKategori(
          'bumbu',
          [
            'minyak-goreng',
            'bawang-merah',
            'bawang-putih',
            'kecap-manis',
            'saus-tiram',
            'margarin',
          ],
          kondisi,
          '$konteks | Bumbu',
        );
      },
    );
  });
}
