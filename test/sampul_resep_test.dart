import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resepsisakulkas/app/data/models/bahan_model.dart';
import 'package:resepsisakulkas/app/data/models/katalog_model.dart';
import 'package:resepsisakulkas/app/data/models/resep_model.dart';
import 'package:resepsisakulkas/app/theme/app_colors.dart';
import 'package:resepsisakulkas/app/theme/app_spacing.dart';
import 'package:resepsisakulkas/app/widgets/sampul_resep.dart';

/// Sampul resep: pemetaan bahan → komponen, susunan per resep, tata letak
/// deterministik, dan pelukis untuk seluruh katalog.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Katalog katalog;
  late Map<String, Bahan> byId;

  setUpAll(() async {
    katalog = Katalog.fromJson(
      jsonDecode(await rootBundle.loadString('assets/data/resep.json'))
          as Map<String, dynamic>,
    );
    byId = katalog.bahanById;
  });

  RancanganSampul rancang(String id) =>
      susunSampul(katalog.resepById(id)!, byId);

  group('pemetaan bahan → komponen', () {
    test('setiap bahan di katalog punya komponen khusus', () {
      final tanpaPeta = [
        for (final b in katalog.bahan)
          if (!petaKomponen.containsKey(b.id)) b.id,
      ];
      expect(
        tanpaPeta,
        isEmpty,
        reason:
            'Tambahkan ke petaKomponen (sampul_resep.dart). Tanpa itu bahan '
            'tetap tergambar, tetapi hanya sebagai bentuk generik.',
      );
    });

    test('bahan non-bumbu selalu tergambar (isi atau hiasan)', () {
      for (final b in katalog.bahan) {
        final k = komponenUntuk(b.id, b);
        if (b.kategori != KategoriBahan.bumbu && b.id != 'tepung-terigu') {
          // Daun bawang & seledri sengaja menjadi hiasan, bukan isi.
          expect(
            k.peran,
            anyOf(PeranMakanan.isi, PeranMakanan.hiasan),
            reason: b.id,
          );
        }
        if (b.bumbuDasar) expect(k.peran, PeranMakanan.tanpa, reason: b.id);
      }
    });

    test('fallback: bahan tak dikenal → generik berwarna kategori', () {
      const nangka = Bahan(
        id: 'nangka-muda',
        nama: 'Nangka muda',
        kategori: KategoriBahan.sayur,
        emoji: '🍈',
      );
      final k = komponenUntuk(nangka.id, nangka);
      expect(k.bentuk, BentukMakanan.generik);
      expect(k.peran, PeranMakanan.isi);
      expect(k.warna, AppColors.magnet(KategoriBahan.sayur));

      const kunyit = Bahan(
        id: 'kunyit',
        nama: 'Kunyit',
        kategori: KategoriBahan.bumbu,
        emoji: '🟡',
      );
      expect(komponenUntuk(kunyit.id, kunyit).peran, PeranMakanan.tanpa);
      // Tanpa data bahan sama sekali pun tidak melempar.
      expect(komponenUntuk('entah-apa').bentuk, BentukMakanan.generik);
    });
  });

  group('susunSampul', () {
    test('utama = bahan isi wajib pertama; hiasan dari bumbu', () {
      final r = rancang('orek-tempe');
      expect(r.utama?.nama, 'tempe');
      expect(r.wadah, WadahSampul.piring);
      expect(r.hiasan.map((k) => k.nama), ['bawang-merah', 'bawang-putih']);
      // Tumisan berkecap: genangan saus, bukan siraman di atas.
      expect(r.genangan, isNotNull);
      expect(r.siraman, isNull);
    });

    test('telur digambar menurut cara masaknya', () {
      expect(rancang('telur-dadar').utama?.nama, 'telur-dadar');
      expect(rancang('telur-ceplok-kecap').utama?.nama, 'telur-ceplok');
      expect(rancang('telur-balado').utama?.nama, 'telur-rebus');
      expect(rancang('telur-ceplok-kecap').siraman, isNotNull);
    });

    test('wadah mengikuti sajian', () {
      expect(rancang('sop-ayam').wadah, WadahSampul.mangkuk);
      expect(rancang('mie-rebus').wadah, WadahSampul.mangkuk);
      expect(rancang('mie-goreng-telur').wadah, WadahSampul.piring);
      expect(rancang('sambal-tomat').wadah, WadahSampul.cobek);
      expect(rancang('sambal-tomat').utama, isNull);
      expect(
        rancang('pisang-bakar-cokelat-keju').wadah,
        WadahSampul.daunPisang,
      );
    });

    test('gorengan bertepung dibalut; telur pelapisnya tidak digambar', () {
      final ayam = rancang('ayam-goreng-tepung');
      expect(ayam.balut, isTrue);
      expect(ayam.utama?.nama, 'ayam');
      expect(
        ayam.pendamping.map((k) => k.nama),
        isNot(contains('telur-dadar')),
      );
      expect(rancang('ayam-goreng').balut, isFalse);
      expect(rancang('bakwan-sayur').balut, isTrue);
    });

    test('bubur: nasi menjadi kuah, lauknya yang utama', () {
      final r = rancang('bubur-ayam');
      expect(r.wadah, WadahSampul.mangkuk);
      expect(r.utama?.nama, 'ayam');
    });

    test('nasi goreng kecap berwarna kecokelatan, tanpa siraman', () {
      final r = rancang('nasi-goreng');
      expect(r.utama?.nama, 'nasi');
      expect(r.warnaUtama, isNotNull);
      expect(r.siraman, isNull);
      expect(rancang('nasi-telur').siraman, isNotNull);
    });

    test('tidak ada dua resep dengan komposisi yang sama', () {
      final menurutTanda = <String, List<String>>{};
      for (final r in katalog.resep) {
        menurutTanda
            .putIfAbsent(susunSampul(r, byId).tanda, () => [])
            .add(r.id);
      }
      expect(
        menurutTanda.values.where((ids) => ids.length > 1),
        isEmpty,
        reason: 'resep-resep ini akan tampak kembar',
      );
    });

    test('setiap resep punya sesuatu untuk digambar', () {
      for (final r in katalog.resep) {
        final s = susunSampul(r, byId);
        expect(
          s.utama != null || s.pendamping.isNotEmpty || s.hiasan.isNotEmpty,
          isTrue,
          reason: r.id,
        );
      }
    });
  });

  group('tataSampul', () {
    test('deterministik: benih sama → tata letak sama', () {
      for (final r in katalog.resep) {
        final a = tataSampul(susunSampul(r, byId));
        final b = tataSampul(susunSampul(r, byId));
        expect(a.length, b.length, reason: r.id);
        for (var i = 0; i < a.length; i++) {
          expect(a[i].pos, b[i].pos, reason: r.id);
          expect(a[i].r, b[i].r, reason: r.id);
          expect(a[i].putar, b[i].putar, reason: r.id);
          expect(a[i].komponen.nama, b[i].komponen.nama, reason: r.id);
        }
      }
    });

    test('semua potongan berada di dalam area makanan wadahnya', () {
      for (final r in katalog.resep) {
        final s = susunSampul(r, byId);
        final batas = batasIsi(s.wadah);
        expect(batas, lessThan(0.8));
        for (final p in tataSampul(s)) {
          expect(
            p.pos.distance + p.r,
            lessThanOrEqualTo(batas + 1e-9),
            reason: '${r.id}: ${p.komponen.nama}',
          );
        }
      }
    });

    test('jumlah potongan utama selalu utuh dan tidak bertumpuk', () {
      for (final r in katalog.resep) {
        final s = susunSampul(r, byId);
        final utama = tataSampul(s).where((p) => p.lapis == 0).toList();
        if (s.utama == null) {
          expect(utama, isEmpty, reason: r.id);
          continue;
        }
        expect(
          utama.length,
          s.utama!.tunggal ? 1 : s.utama!.jumlah,
          reason: r.id,
        );
        for (var i = 0; i < utama.length; i++) {
          for (var j = i + 1; j < utama.length; j++) {
            expect(
              (utama[i].pos - utama[j].pos).distance,
              greaterThanOrEqualTo((utama[i].r + utama[j].r) * 0.7),
              reason: '${r.id}: potongan utama $i & $j terlalu rapat',
            );
          }
        }
      }
    });

    test('potongan selapis menjaga jarak minimum', () {
      for (final r in katalog.resep) {
        final potongan = tataSampul(susunSampul(r, byId));
        for (var i = 0; i < potongan.length; i++) {
          for (var j = i + 1; j < potongan.length; j++) {
            final a = potongan[i], b = potongan[j];
            if (a.lapis != b.lapis || a.lapis == 0) continue;
            expect(
              (a.pos - b.pos).distance,
              greaterThanOrEqualTo((a.r + b.r) * 0.63),
              reason: '${r.id}: ${a.komponen.nama} & ${b.komponen.nama}',
            );
          }
        }
      }
    });
  });

  group('pelukis', () {
    Future<List<int>> lukis(
      WidgetTester tester,
      Resep resep,
      double sisi,
    ) async {
      final perekam = ui.PictureRecorder();
      SampulPainter(susunSampul(resep, byId))
          .paint(ui.Canvas(perekam), ui.Size.square(sisi));
      final gambar = perekam.endRecording();
      final bita = await tester.runAsync(() async {
        final citra = await gambar.toImage(sisi.round(), sisi.round());
        final data = await citra.toByteData();
        citra.dispose();
        return data!.buffer.asUint8List().toList();
      });
      gambar.dispose();
      return bita!;
    }

    testWidgets('semua resep tergambar tanpa galat di ukuran kartu & detail', (
      tester,
    ) async {
      for (final r in katalog.resep) {
        for (final sisi in [40.0, AppSpacing.sampul, 112.0, 240.0]) {
          final perekam = ui.PictureRecorder();
          expect(
            () =>
                SampulPainter(susunSampul(r, byId))
                    .paint(ui.Canvas(perekam), ui.Size.square(sisi)),
            returnsNormally,
            reason: '${r.id} @ $sisi',
          );
          perekam.endRecording().dispose();
        }
      }
    });

    testWidgets('setiap bentuk makanan terpakai oleh katalog', (tester) async {
      final terpakai = <BentukMakanan>{};
      for (final r in katalog.resep) {
        final s = susunSampul(r, byId);
        terpakai.addAll([
          ?s.utama?.bentuk,
          ...s.pendamping.map((k) => k.bentuk),
          ...s.hiasan.map((k) => k.bentuk),
          if (s.balut) BentukMakanan.gorengan,
        ]);
      }
      // "generik" hanya untuk bahan di luar katalog; "roti"/"mie" dll.
      // semuanya harus muncul.
      expect(BentukMakanan.values.toSet().difference(terpakai), {
        BentukMakanan.generik,
      });
    });

    testWidgets('60 sampul: tidak ada dua yang pikselnya identik; resep '
        'yang sama selalu menghasilkan gambar yang sama', (tester) async {
      final menurutGambar = <String, String>{};
      for (final r in katalog.resep) {
        final bita = await lukis(tester, r, AppSpacing.sampul);
        final kunci = base64Encode(bita);
        expect(
          menurutGambar[kunci],
          isNull,
          reason: '${r.id} identik dengan ${menurutGambar[kunci]}',
        );
        menurutGambar[kunci] = r.id;
      }
      expect(menurutGambar, hasLength(katalog.resep.length));

      final contoh = katalog.resepById('nasi-goreng')!;
      expect(
        await lukis(tester, contoh, 112),
        await lukis(tester, contoh, 112),
      );
    });

    testWidgets('makanan tidak keluar dari wadah: sudut ubin tetap warna '
        'latar', (tester) async {
      for (final r in katalog.resep) {
        const sisi = 80;
        final bita = await lukis(tester, r, sisi.toDouble());
        int piksel(int x, int y) {
          final i = (y * sisi + x) * 4;
          return bita[i] << 16 | bita[i + 1] << 8 | bita[i + 2];
        }

        // Wadah berjari-jari 36,5% sisi dari pusat; titik-titik di luar
        // lingkaran itu (kiri atas & bawah kiri) harus sama dengan latar.
        final latar = piksel(1, 1);
        for (final (x, y) in [(6, 6), (3, 40), (40, 3), (6, 73), (3, 60)]) {
          expect(piksel(x, y), latar, reason: '${r.id} di ($x, $y)');
        }
      }
    });

    test('ambang detail berada di antara ukuran kartu dan halaman detail', () {
      expect(SampulResep.ambangDetail, greaterThan(AppSpacing.sampul));
      expect(SampulResep.ambangDetail, lessThanOrEqualTo(112));
    });

    testWidgets('detail halus (bintik tempe) hanya digambar saat detail', (
      tester,
    ) async {
      // Kanvas yang sama besar, hanya sakelar detail yang berbeda: bintik
      // kedelai bertambah dari 3 menjadi 7 per potong tempe.
      final rancangan = rancang('tempe-goreng');
      Future<int> pikselBintik(bool detail) async {
        const sisi = 240;
        final perekam = ui.PictureRecorder();
        SampulPainter(
          rancangan,
          detailPaksa: detail,
        ).paint(ui.Canvas(perekam), const ui.Size.square(240));
        final gambar = perekam.endRecording();
        final bita = await tester.runAsync(() async {
          final citra = await gambar.toImage(sisi, sisi);
          final data = await citra.toByteData();
          citra.dispose();
          return data!.buffer.asUint8List();
        });
        gambar.dispose();
        // WarnaMakanan.tempeBintik = F1DDB5.
        var jumlah = 0;
        for (var i = 0; i < bita!.length; i += 4) {
          if (bita[i] == 0xF1 && bita[i + 1] == 0xDD && bita[i + 2] == 0xB5) {
            jumlah++;
          }
        }
        return jumlah;
      }

      final ringkas = await pikselBintik(false);
      final penuh = await pikselBintik(true);
      expect(ringkas, greaterThan(0), reason: 'bintik besar selalu ada');
      expect(penuh, greaterThan(ringkas));
    });
  });
}
