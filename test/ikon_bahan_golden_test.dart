@Tags(['golden'])
library;

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resepsisakulkas/app/data/models/bahan_model.dart';
import 'package:resepsisakulkas/app/data/models/katalog_model.dart';
import 'package:resepsisakulkas/app/theme/app_colors.dart';
import 'package:resepsisakulkas/app/widgets/ikon_bahan.dart';

import 'helpers/komparator_toleran.dart';

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
    pasangKomparatorToleran('ikon_bahan_golden_test.dart');
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
