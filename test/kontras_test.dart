import 'dart:math';

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resepsisakulkas/app/data/models/bahan_model.dart';
import 'package:resepsisakulkas/app/theme/app_colors.dart';
import 'package:resepsisakulkas/app/theme/app_palet.dart';

/// Kontras palet terang & gelap menurut WCAG 2.1 (luminans relatif sRGB).
/// Teks ≥ 4,5:1; elemen grafis (ikon, cincin) ≥ 3:1.
double _kanal(double c) =>
    c <= 0.03928 ? c / 12.92 : pow((c + 0.055) / 1.055, 2.4).toDouble();

double luminans(Color w) =>
    0.2126 * _kanal(w.r) + 0.7152 * _kanal(w.g) + 0.0722 * _kanal(w.b);

double kontras(Color a, Color b) {
  final la = luminans(a), lb = luminans(b);
  return (max(la, lb) + 0.05) / (min(la, lb) + 0.05);
}

void main() {
  test('rumus kontras: hitam-putih 21:1, warna sama 1:1', () {
    const hitam = Color(0xFF000000), putih = Color(0xFFFFFFFF);
    expect(kontras(hitam, putih), closeTo(21, 0.01));
    expect(kontras(putih, putih), closeTo(1, 0.001));
  });

  for (final (nama, p) in [('terang', Palet.terang), ('gelap', Palet.gelap)]) {
    group('palet $nama', () {
      // (teks, latar, keterangan)
      final teks = <(Color, Color, String)>[
        (p.tinta, p.latar, 'tinta di latar'),
        (p.tinta, p.permukaan, 'tinta di permukaan'),
        (p.tinta, p.permukaanTinggi, 'tinta di permukaanTinggi'),
        (p.tinta, p.mintPucat, 'tinta di mintPucat'),
        (p.tintaLembut, p.latar, 'tintaLembut di latar'),
        (p.tintaLembut, p.permukaan, 'tintaLembut di permukaan'),
        (p.tintaLembut, p.permukaanTinggi, 'tintaLembut di permukaanTinggi'),
        (p.diAksen, p.aksenTua, 'teks tombol isi'),
        (p.aksenTua, p.latar, 'teks beraksen di latar'),
        (p.aksenTua, p.permukaan, 'teks beraksen di permukaan'),
        (p.aksenTua, p.aksenLembut, 'chip "Semua bahan ada"'),
        (p.aksenTua, p.mintPucat, 'nomor langkah'),
        (p.wortelTeks, p.wortelLembut, 'chip "kurang"'),
        (p.wortelTeks, p.permukaan, 'wortelTeks di permukaan'),
        (p.diBalik, p.wortelTeks, 'tombol konfirmasi'),
        (p.pisangTeks, p.pisangLembut, 'label "segera habiskan"'),
        (p.pisangTeks, p.permukaan, 'pisangTeks di permukaan'),
        (p.bahaya, p.permukaan, 'aksi berbahaya di permukaan'),
        (p.bahaya, p.bahayaLembut, 'ikon berbahaya di kotaknya'),
        (p.diBalik, p.balik, 'chip terpilih & snackbar'),
        for (final k in KategoriBahan.values)
          (p.diMagnet, AppColors.magnet(k), 'teks di magnet ${k.name}'),
      ];
      for (final (depan, latar, ket) in teks) {
        test('teks ≥ 4,5:1 — $ket', () {
          expect(
            kontras(depan, latar),
            greaterThanOrEqualTo(4.5),
            reason: '$ket = ${kontras(depan, latar).toStringAsFixed(2)}:1',
          );
        });
      }

      final grafis = <(Color, Color, String)>[
        (p.aksen, p.permukaan, 'cincin 100% / ikon ✓'),
        (p.hatiKoral, p.latar, 'hati favorit'),
        (p.tintaLembut, p.garis, 'ikon di jalur nonaktif'),
        if (p.modeGelap) ...[
          // Di tema gelap warna hangat menjadi terang, jadi ikut dijaga.
          (p.wortel, p.permukaan, 'ikon wortel'),
          (p.pisang, p.permukaan, 'ikon pisang'),
          (p.kuningCincin, p.permukaan, 'cincin 50–99%'),
          (p.abuCincin, p.permukaan, 'cincin < 50%'),
        ],
      ];
      for (final (depan, latar, ket) in grafis) {
        test('grafis ≥ 3:1 — $ket', () {
          expect(
            kontras(depan, latar),
            greaterThanOrEqualTo(3),
            reason: '$ket = ${kontras(depan, latar).toStringAsFixed(2)}:1',
          );
        });
      }
    });
  }

  test('tema gelap bukan warna terang yang dibalik', () {
    // Permukaan naik bertingkat: latar < permukaan < permukaanTinggi.
    const g = Palet.gelap;
    expect(luminans(g.latar), lessThan(luminans(g.permukaan)));
    expect(luminans(g.permukaan), lessThan(luminans(g.permukaanTinggi)));
    // Latar tetap berwarna (hijau-arang), bukan hitam murni.
    expect(g.latar.g, greaterThan(g.latar.r));
  });
}
