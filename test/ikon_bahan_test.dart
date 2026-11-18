import 'dart:convert';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resepsisakulkas/app/data/models/bahan_model.dart';
import 'package:resepsisakulkas/app/data/models/katalog_model.dart';
import 'package:resepsisakulkas/app/widgets/ikon_bahan.dart';

/// Ikon bahan: setiap bahan di dataset digambar CustomPainter (tanpa
/// emoji), bahan tak dikenal jatuh ke cadangan tanpa galat, dan semua ikon
/// benar-benar terisi di ukuran kecil maupun besar.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Katalog katalog;

  setUpAll(() async {
    katalog = Katalog.fromJson(
      jsonDecode(await rootBundle.loadString('assets/data/resep.json'))
          as Map<String, dynamic>,
    );
  });

  test('setiap bahan di dataset punya pelukis', () {
    final tanpa = [
      for (final b in katalog.bahan)
        if (!IkonBahan.punyaPelukis(b.id)) '${b.id} ${b.emoji}',
    ];
    expect(
      tanpa,
      isEmpty,
      reason: 'Tambahkan gambar di IkonBahanPainter (ikon_bahan.dart).',
    );
    // Daftar pelukis tidak berisi id yang tidak ada di dataset.
    expect(
      IkonBahanPainter.dikenal.difference({
        for (final b in katalog.bahan) b.id,
      }),
      isEmpty,
    );
  });

  testWidgets('bahan dataset tidak pernah tampil sebagai emoji', (
    tester,
  ) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Wrap(
          children: [for (final b in katalog.bahan) IkonBahan.dari(b)],
        ),
      ),
    );
    expect(find.byType(Text), findsNothing);
    expect(
      find.byWidgetPredicate(
        (w) => w is CustomPaint && w.painter is IkonBahanPainter,
      ),
      findsNWidgets(katalog.bahan.length),
    );
  });

  testWidgets('id tak dikenal: bentuk generik berwarna kategori, emoji '
      'hanya bila kategori tidak diketahui', (tester) async {
    const nangka = Bahan(
      id: 'nangka-muda',
      nama: 'Nangka muda',
      kategori: KategoriBahan.sayur,
      emoji: '🍈',
    );
    expect(IkonBahan.punyaPelukis(nangka.id), isFalse);
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Row(
          children: [
            IkonBahan.dari(nangka, ukuran: 32),
            const IkonBahan(id: 'nangka-muda', emoji: '🍈', ukuran: 32),
          ],
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    final pelukis = tester
        .widgetList<CustomPaint>(find.byType(CustomPaint))
        .map((w) => w.painter)
        .whereType<IkonBahanPainter>()
        .single;
    expect(pelukis.cadangan, isNotNull);
    expect(find.text('🍈'), findsOneWidget);
  });

  testWidgets('semua ikon terisi dan berwarna di 20, 28, dan 48 px', (
    tester,
  ) async {
    const kunci = Key('ikon');
    final lemah = <String>[];
    for (final ukuran in [20.0, 28.0, 48.0]) {
      for (final b in katalog.bahan) {
        await tester.pumpWidget(
          Center(
            child: RepaintBoundary(
              key: kunci,
              child: IkonBahan.dari(b, ukuran: ukuran),
            ),
          ),
        );
        expect(tester.getSize(find.byKey(kunci)), Size.square(ukuran));
        final piksel = await tester.runAsync(() async {
          final gambar = await tester
              .renderObject<RenderRepaintBoundary>(find.byKey(kunci))
              .toImage(pixelRatio: 3);
          final data = await gambar.toByteData();
          gambar.dispose();
          return data!;
        });
        var terisi = 0;
        final warna = <int>{};
        for (var i = 0; i < piksel!.lengthInBytes; i += 4) {
          if (piksel.getUint8(i + 3) > 200) {
            terisi++;
            warna.add(piksel.getUint32(i) >> 12); // warna dikelompokkan
          }
        }
        final rasio = terisi / (piksel.lengthInBytes / 4);
        // Benda ramping (tauge, kangkung, buncis) wajar lebih tipis.
        if (rasio < 0.15 || warna.length < 3) {
          lemah.add(
            '${b.id} @ ${ukuran.toInt()} px: isi $rasio, '
            '${warna.length} warna',
          );
        }
      }
    }
    expect(lemah, isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ukuran optis seragam: sisi terpanjang bounding box tiap ikon '
      '34–40 px di kanvas 48 px', (tester) async {
    const sisi = 48;
    final hasil = <String, int>{};
    for (final b in katalog.bahan) {
      final bita = await tester.runAsync(() async {
        final perekam = ui.PictureRecorder();
        IkonBahanPainter(
          b.id,
        ).paint(Canvas(perekam), const Size.square(sisi * 1.0));
        final gambar = perekam.endRecording();
        final citra = await gambar.toImage(sisi, sisi);
        final data = await citra.toByteData();
        citra.dispose();
        gambar.dispose();
        return data!.buffer.asUint8List();
      });
      var x0 = sisi, y0 = sisi, x1 = -1, y1 = -1;
      for (var y = 0; y < sisi; y++) {
        for (var x = 0; x < sisi; x++) {
          // Abaikan tepi anti-alias yang sangat tipis.
          if (bita![(y * sisi + x) * 4 + 3] > 64) {
            x0 = min(x0, x);
            x1 = max(x1, x);
            y0 = min(y0, y);
            y1 = max(y1, y);
          }
        }
      }
      hasil[b.id] = max(x1 - x0 + 1, y1 - y0 + 1);
    }
    final urut = hasil.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    debugPrint(
      'Bounding box (px): ${urut.map((e) => '${e.key}=${e.value}').join(', ')}',
    );
    expect({
      for (final e in hasil.entries)
        if (e.value < 34 || e.value > 40) e.key: e.value,
    }, isEmpty);
  });

  testWidgets('detail hanya digambar mulai ambang detail', (tester) async {
    // Kanvas sama besar, hanya sakelar detail yang beda: tempe mendapat
    // bintik kedelai tambahan.
    Future<int> jumlahPikselBerbeda() async {
      Future<List<int>> lukis(bool detail) async {
        await tester.pumpWidget(
          Center(
            child: RepaintBoundary(
              child: SizedBox.square(
                dimension: 48,
                child: CustomPaint(
                  painter: IkonBahanPainter('tempe', detail: detail),
                ),
              ),
            ),
          ),
        );
        final data = await tester.runAsync(() async {
          final gambar = await tester
              .renderObject<RenderRepaintBoundary>(
                find.byType(RepaintBoundary).first,
              )
              .toImage();
          final d = await gambar.toByteData();
          gambar.dispose();
          return d!.buffer.asUint8List().toList();
        });
        return data!;
      }

      final a = await lukis(false), b = await lukis(true);
      var beda = 0;
      for (var i = 0; i < a.length; i++) {
        if (a[i] != b[i]) beda++;
      }
      return beda;
    }

    expect(await jumlahPikselBerbeda(), greaterThan(0));
    expect(IkonBahan.ambangDetail, 24);
  });
}
