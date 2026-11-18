@Tags(['golden'])
library;

import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resepsisakulkas/app/data/models/bahan_model.dart';
import 'package:resepsisakulkas/app/data/models/katalog_model.dart';
import 'package:resepsisakulkas/app/theme/app_colors.dart';
import 'package:resepsisakulkas/app/widgets/ikon_bahan.dart';

/// Lembar golden semua ikon bahan di atas warna chip magnetnya:
/// - `goldens/ikon_bahan_48.png`: grid 53 ikon di 48 dp (mode detail);
/// - `goldens/ikon_bahan_22.png`: satu baris di 22 dp (mode non-detail).
///
/// Keduanya dirender 2× agar mudah diperiksa. Perbarui dengan
/// `flutter test --update-goldens test/ikon_bahan_golden_test.dart`.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<Bahan> bahan;

  setUpAll(() async {
    final asal = goldenFileComparator;
    if (asal is LocalFileComparator) {
      goldenFileComparator = KomparatorToleran(
        asal.basedir.resolve('ikon_bahan_golden_test.dart'),
      );
      addTearDown(() => goldenFileComparator = asal);
    }
    bahan = Katalog.fromJson(
      jsonDecode(await rootBundle.loadString('assets/data/resep.json'))
          as Map<String, dynamic>,
    ).bahan;
  });

  const perbesar = 2.0;

  Widget sel(Bahan b, double ukuran, double jarak) => Container(
    width: ukuran + jarak,
    height: ukuran + jarak,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: AppColors.magnet(b.kategori),
      borderRadius: BorderRadius.circular(jarak),
    ),
    child: IkonBahan.dari(b, ukuran: ukuran),
  );

  Future<void> lembar(
    WidgetTester tester, {
    required double ukuran,
    required int kolom,
    required String berkas,
  }) async {
    final jarak = ukuran / 6;
    final sisiSel = ukuran + jarak * 2;
    final baris = (bahan.length / kolom).ceil();
    final lebar = kolom * sisiSel + jarak;
    final tinggi = baris * sisiSel + jarak;
    tester.view
      ..devicePixelRatio = 1
      ..physicalSize = Size(lebar * perbesar, tinggi * perbesar);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: RepaintBoundary(
          child: Transform.scale(
            scale: perbesar,
            alignment: Alignment.topLeft,
            child: Align(
              alignment: Alignment.topLeft,
              child: Container(
                width: lebar,
                height: tinggi,
                color: AppColors.latar,
                padding: EdgeInsets.all(jarak / 2),
                child: Wrap(
                  children: [
                    for (final b in bahan)
                      Padding(
                        padding: EdgeInsets.all(jarak / 2),
                        child: sel(b, ukuran, jarak),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await expectLater(
      find.byType(RepaintBoundary).first,
      matchesGoldenFile(berkas),
    );
  }

  testWidgets('grid 53 ikon di 48 dp (detail)', (tester) async {
    expect(bahan, hasLength(53));
    await lembar(
      tester,
      ukuran: 48,
      kolom: 9,
      berkas: 'goldens/ikon_bahan_48.png',
    );
  });

  testWidgets('satu baris ikon di 22 dp (non-detail)', (tester) async {
    expect(22, lessThan(IkonBahan.ambangDetail));
    await lembar(
      tester,
      ukuran: 22,
      kolom: bahan.length,
      berkas: 'goldens/ikon_bahan_22.png',
    );
  });
}

/// Komparator golden dua tingkat yang membedakan antialiasing dari
/// perubahan gambar:
/// 1. piksel dianggap BERBEDA hanya bila selisih terbesar di salah satu
///    kanal RGBA > [ambangKanal];
/// 2. tes lulus bila jumlah piksel BERBEDA ≤ [batasPiksel] dari total.
///
/// Saat gagal, pesan menyebut jumlah & persentase piksel berbeda dan kotak
/// pembatas area yang berubah (px lembar dan dp), lalu menulis gambar
/// selisih ke `test/failures/` seperti komparator bawaan.
class KomparatorToleran extends LocalFileComparator {
  KomparatorToleran(super.testFile);

  /// Selisih kanal (0–255) yang masih dianggap antialiasing: tepi garis
  /// antarmesin Windows berbeda beberapa belas tingkat, sedangkan
  /// pergantian warna isi (mis. tomat → cabai) berbeda puluhan tingkat.
  static const ambangKanal = 24;

  /// Bagian piksel BERBEDA (0–1) yang boleh ada: 0,02% ≈ 180 piksel di
  /// lembar 48 dp, jauh di bawah luas isi satu ikon (± 3.000 piksel), tetapi
  /// cukup untuk segelintir piksel tepi yang lolos ambang kanal.
  static const batasPiksel = 0.0002;

  /// Pembesaran lembar golden (lihat `perbesar` di atas), untuk mengubah
  /// koordinat piksel ke dp di pesan galat.
  static const perbesar = 2;

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final bitaGolden = Uint8List.fromList(await getGoldenBytes(golden));
    final (lebar, tinggi, uji) = await _rgba(imageBytes);
    final (lebarG, tinggiG, acuan) = await _rgba(bitaGolden);
    if (lebar != lebarG || tinggi != tinggiG) {
      throw FlutterError(
        'Golden $golden: ukuran berbeda, ${lebar}x$tinggi px vs '
        'acuan ${lebarG}x$tinggiG px.',
      );
    }
    var beda = 0;
    var x0 = lebar, y0 = tinggi, x1 = -1, y1 = -1;
    for (var i = 0; i < uji.length; i += 4) {
      var maks = 0;
      for (var k = 0; k < 4; k++) {
        final d = (uji[i + k] - acuan[i + k]).abs();
        if (d > maks) maks = d;
      }
      if (maks <= ambangKanal) continue;
      beda++;
      final p = i ~/ 4, x = p % lebar, y = p ~/ lebar;
      if (x < x0) x0 = x;
      if (x > x1) x1 = x;
      if (y < y0) y0 = y;
      if (y > y1) y1 = y;
    }
    final total = lebar * tinggi;
    if (beda <= total * batasPiksel) return true;

    final persen = (beda / total * 100).toStringAsFixed(3);
    final hasil = await GoldenFileComparator.compareLists(
      imageBytes,
      bitaGolden,
    );
    final keluaran = await generateFailureOutput(hasil, golden, basedir);
    hasil.dispose();
    throw FlutterError(
      'Golden $golden: $beda piksel berbeda ($persen% dari $total; batas '
      '${batasPiksel * 100}%, selisih kanal > $ambangKanal).\n'
      'Kotak pembatas area berbeda: x $x0–$x1, y $y0–$y1 px '
      '(= x ${x0 ~/ perbesar}–${x1 ~/ perbesar}, '
      'y ${y0 ~/ perbesar}–${y1 ~/ perbesar} dp di lembar).\n$keluaran',
    );
  }

  static Future<(int, int, Uint8List)> _rgba(Uint8List png) async {
    final codec = await ui.instantiateImageCodec(png);
    final bingkai = await codec.getNextFrame();
    final citra = bingkai.image;
    final data = await citra.toByteData();
    final hasil = (citra.width, citra.height, data!.buffer.asUint8List());
    citra.dispose();
    codec.dispose();
    return hasil;
  }
}
