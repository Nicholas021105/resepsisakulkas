import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resepsisakulkas/app/theme/app_palet.dart';
import 'package:resepsisakulkas/app/theme/app_theme.dart';
import 'package:resepsisakulkas/app/widgets/ilustrasi_kulkas.dart';

/// Ilustrasi kulkas kosong: animasi pembuka, "kurangi gerak", dan pelukis
/// di kedua tema.
void main() {
  Widget bungkus({bool kurangiGerak = false, bool gelap = false}) =>
      MaterialApp(
        theme: gelap ? AppTheme.gelap : AppTheme.terang,
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: kurangiGerak),
          child: const Center(
            child: RepaintBoundary(
              key: Key('ilustrasi'),
              child: IlustrasiKulkasKosong(ukuran: 112),
            ),
          ),
        ),
      );

  KulkasKosongPainter pelukis(WidgetTester tester) =>
      tester
              .widget<CustomPaint>(
                find.descendant(
                  of: find.byType(IlustrasiKulkasKosong),
                  matching: find.byType(CustomPaint),
                ),
              )
              .painter!
          as KulkasKosongPainter;

  testWidgets('animasi pembuka berjalan sekali lalu berhenti di akhir', (
    tester,
  ) async {
    await tester.pumpWidget(bungkus());
    expect(pelukis(tester).maju, 0);
    expect(tester.hasRunningAnimations, isTrue);

    await tester.pump(IlustrasiKulkasKosong.durasi ~/ 2);
    expect(pelukis(tester).maju, closeTo(0.5, 0.02));

    await tester.pumpAndSettle();
    expect(pelukis(tester).maju, 1);
    expect(tester.hasRunningAnimations, isFalse);
    expect(
      tester.getSize(find.byType(IlustrasiKulkasKosong)),
      const Size.square(112),
    );
  });

  testWidgets('kurangi gerak: langsung keadaan akhir, tanpa animasi', (
    tester,
  ) async {
    await tester.pumpWidget(bungkus(kurangiGerak: true));
    expect(pelukis(tester).maju, 1);
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('pelukis memakai palet tema aktif', (tester) async {
    await tester.pumpWidget(bungkus(kurangiGerak: true));
    expect(pelukis(tester).p, Palet.terang);
    await tester.pumpWidget(bungkus(kurangiGerak: true, gelap: true));
    await tester.pumpAndSettle();
    expect(pelukis(tester).p, Palet.gelap);
  });

  test('shouldRepaint hanya saat palet atau kemajuan berubah', () {
    const a = KulkasKosongPainter(Palet.terang, maju: 0.4);
    expect(
      a.shouldRepaint(const KulkasKosongPainter(Palet.terang, maju: 0.4)),
      isFalse,
    );
    expect(
      a.shouldRepaint(const KulkasKosongPainter(Palet.terang, maju: 0.5)),
      isTrue,
    );
    expect(
      a.shouldRepaint(const KulkasKosongPainter(Palet.gelap, maju: 0.4)),
      isTrue,
    );
  });

  testWidgets('setiap tahap animasi tergambar tanpa error di kedua tema, '
      'dan keadaan akhir lebih ramai daripada awal', (tester) async {
    Future<int> pikselTerisi(Palet p, double maju) async {
      await tester.pumpWidget(
        Center(
          child: RepaintBoundary(
            key: const Key('kanvas'),
            child: CustomPaint(
              size: const Size.square(112),
              painter: KulkasKosongPainter(p, maju: maju),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull, reason: 'maju $maju');
      final data = await tester.runAsync(() async {
        final gambar = await tester
            .renderObject<RenderRepaintBoundary>(
              find.byKey(const Key('kanvas')),
            )
            .toImage();
        final bita = await gambar.toByteData();
        gambar.dispose();
        return bita!;
      });
      var terisi = 0;
      for (var i = 3; i < data!.lengthInBytes; i += 4) {
        if (data.getUint8(i) > 40) terisi++;
      }
      return terisi;
    }

    for (final p in [Palet.terang, Palet.gelap]) {
      final awal = await pikselTerisi(p, 0);
      for (final maju in [0.1, 0.25, 0.49, 0.51, 0.75, 0.9]) {
        await pikselTerisi(p, maju);
      }
      final akhir = await pikselTerisi(p, 1);
      // Kulkas mengisi sebagian besar kanvas sejak awal …
      expect(awal / (112 * 112), greaterThan(0.3));
      // … dan pintu terbuka + udara dingin + kilau menambah isi.
      expect(akhir, greaterThan(awal + 500));
    }
  });
}
