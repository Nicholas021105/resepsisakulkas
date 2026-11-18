@Tags(['golden'])
library;

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resepsisakulkas/app/data/models/katalog_model.dart';
import 'package:resepsisakulkas/app/theme/app_colors.dart';
import 'package:resepsisakulkas/app/theme/app_spacing.dart';
import 'package:resepsisakulkas/app/widgets/sampul_resep.dart';

import 'helpers/komparator_toleran.dart';

/// Lembar golden semua sampul resep (urutan katalog, 10 kolom):
/// - `goldens/sampul_resep_kartu.png`: 60 sampul di ukuran kartu
///   (AppSpacing.sampul, detail halus disembunyikan);
/// - `goldens/sampul_resep_detail.png`: 60 sampul di ukuran halaman detail
///   (112 dp, detail penuh).
///
/// Keduanya dirender 2× agar mudah diperiksa. Perbarui dengan
/// `flutter test --update-goldens test/sampul_resep_golden_test.dart`.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Katalog katalog;

  setUpAll(() async {
    pasangKomparatorToleran('sampul_resep_golden_test.dart');
    katalog = Katalog.fromJson(
      jsonDecode(await rootBundle.loadString('assets/data/resep.json'))
          as Map<String, dynamic>,
    );
  });

  const perbesar = 2.0, kolom = 10;

  Future<void> lembar(
    WidgetTester tester, {
    required double ukuran,
    required String berkas,
  }) async {
    const jarak = AppSpacing.s;
    final baris = (katalog.resep.length / kolom).ceil();
    final lebar = kolom * (ukuran + jarak) + jarak;
    final tinggi = baris * (ukuran + jarak) + jarak;
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
                padding: const EdgeInsets.all(jarak / 2),
                child: Wrap(
                  children: [
                    for (final r in katalog.resep)
                      Padding(
                        padding: const EdgeInsets.all(jarak / 2),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusM,
                          ),
                          child: SizedBox.square(
                            dimension: ukuran,
                            child: CustomPaint(
                              painter: SampulPainter(
                                susunSampul(r, katalog.bahanById),
                              ),
                            ),
                          ),
                        ),
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

  testWidgets('60 sampul di ukuran kartu (non-detail)', (tester) async {
    expect(katalog.resep, hasLength(60));
    expect(AppSpacing.sampul, lessThan(SampulResep.ambangDetail));
    await lembar(
      tester,
      ukuran: AppSpacing.sampul,
      berkas: 'goldens/sampul_resep_kartu.png',
    );
  });

  testWidgets('60 sampul di ukuran detail', (tester) async {
    expect(112, greaterThanOrEqualTo(SampulResep.ambangDetail));
    await lembar(
      tester,
      ukuran: 112,
      berkas: 'goldens/sampul_resep_detail.png',
    );
  });
}
