import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import '../theme/app_colors.dart';
import '../theme/app_warna_makanan.dart';

typedef _W = WarnaMakanan;

/// Bentuk dasar yang bisa digambar pelukis sampul.
enum BentukMakanan {
  telurCeplok,
  telurDadar,
  telurRebus,
  tempe,
  kubus,
  ayam,
  sosis,
  udang,
  mie,
  nasi,
  daun,
  brokoli,
  irisan,
  jagung,
  cabai,
  cincin,
  gorengan,
  roti,
  kapsul,
  remah,
  tauge,
  jamur,
  generik,
}

/// Peran sebuah bahan di sampul.
enum PeranMakanan {
  /// Makanan utama/pendamping (protein, sayur, karbohidrat).
  isi,

  /// Taburan kecil dari bumbu (cabai, bawang, daun bawang).
  hiasan,

  /// Cairan yang disiramkan (kecap, saus).
  siraman,

  /// Tidak digambar (garam, air, minyak, tepung, …).
  tanpa,
}

/// Cara satu bahan digambar di sampul.
@immutable
class Komponen {
  final String nama;
  final BentukMakanan bentuk;
  final Color warna;
  final Color warnaTua;
  final PeranMakanan peran;

  /// Jumlah potongan saat menjadi komponen utama.
  final int jumlah;

  /// Pengali ukuran potongan.
  final double skala;

  /// Tebal relatif (bentuk lonjong) atau lebar relatif (daun).
  final double rasio;

  /// Digambar satu kali besar di tengah (nasi, mie, telur dadar, roti);
  /// komponen lain ditata di atasnya.
  final bool tunggal;

  const Komponen(
    this.nama,
    this.bentuk,
    this.warna,
    this.warnaTua, {
    this.peran = PeranMakanan.isi,
    this.jumlah = 4,
    this.skala = 1,
    this.rasio = 0.5,
    this.tunggal = false,
  });

  const Komponen.hiasan(
    this.nama,
    this.bentuk,
    this.warna,
    this.warnaTua, {
    this.jumlah = 4,
    this.skala = 1,
    this.rasio = 0.5,
  }) : peran = PeranMakanan.hiasan,
       tunggal = false;

  const Komponen.siraman(this.nama, this.warna)
    : bentuk = BentukMakanan.generik,
      warnaTua = warna,
      peran = PeranMakanan.siraman,
      jumlah = 0,
      skala = 1,
      rasio = 0.5,
      tunggal = false;

  const Komponen.tanpa(this.nama)
    : bentuk = BentukMakanan.generik,
      warna = _W.generik,
      warnaTua = _W.generikTua,
      peran = PeranMakanan.tanpa,
      jumlah = 0,
      skala = 1,
      rasio = 0.5,
      tunggal = false;
}

/// Pena bersama sampul resep dan ikon bahan: garis tepi tinta, warna dari
/// [WarnaMakanan], dan sakelar [detail] untuk bintik/urat halus.
///
/// Pustaka komponen makanan: tiap bentuk digambar di titik asal dengan
/// jari-jari [r] (kanvas sudah digeser dan diputar pemanggil).
class PenaMakanan {
  PenaMakanan(this.c, this.tg, this.detail);

  final Canvas c;

  /// Tebal garis tepi.
  final double tg;

  /// Tampilkan bintik, kilau, dan urat halus.
  final bool detail;

  static const _tinta = AppColors.tinta;

  Paint isi(Color w) => Paint()..color = w;

  Paint garis(Color w, double tebal) => Paint()
    ..color = w
    ..style = PaintingStyle.stroke
    ..strokeWidth = tebal
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  void kontur(Path jalur, Color warna) => c
    ..drawPath(jalur, isi(warna))
    ..drawPath(jalur, garis(_tinta, tg));

  /// Gabungan beberapa lingkaran dengan satu garis tepi luar.
  void gabung(List<(Offset, double)> bulatan, Color warna, {Color? tepi}) {
    for (final (o, rad) in bulatan) {
      c.drawCircle(o, rad + tg, isi(tepi ?? _tinta));
    }
    for (final (o, rad) in bulatan) {
      c.drawCircle(o, rad, isi(warna));
    }
  }

  /// Gumpalan berombak (sambal, genangan saus, gundukan nasi).
  void gumpal(Offset o, double r, Color warna, int benih, {Color? tepi}) {
    final acak = Random(benih);
    final bulatan = <(Offset, double)>[
      (o, r * 0.78),
      for (var i = 0; i < 9; i++)
        (
          o +
              Offset(cos(i * 2 * pi / 9), sin(i * 2 * pi / 9)) *
                  r *
                  (0.62 + acak.nextDouble() * 0.1),
          r * (0.26 + acak.nextDouble() * 0.1),
        ),
    ];
    if (tepi == null) {
      for (final (p, rad) in bulatan) {
        c.drawCircle(p, rad, isi(warna));
      }
    } else {
      gabung(bulatan, warna, tepi: tepi);
    }
  }

  void gambar(
    BentukMakanan bentuk,
    Komponen k,
    double r,
    Random acak, {
    Color? warna,
  }) {
    final w = warna ?? k.warna;
    switch (bentuk) {
      case BentukMakanan.telurCeplok:
        gabung([
          (Offset.zero, r * 0.8),
          (Offset(r * 0.4, r * 0.24), r * 0.52),
          (Offset(-r * 0.32, -r * 0.38), r * 0.46),
          (Offset(-r * 0.22, r * 0.44), r * 0.4),
        ], w);
        final kuning = Offset(-r * 0.04, -r * 0.02);
        c
          ..drawCircle(kuning, r * 0.36, isi(_W.telurKuning))
          ..drawCircle(kuning, r * 0.36, garis(_W.telurKuningTua, tg * 0.8));
        if (detail) {
          c.drawArc(
            Rect.fromCircle(center: kuning, radius: r * 0.22),
            pi * 1.1,
            pi * 0.4,
            false,
            garis(_W.telurPutih, tg * 0.8),
          );
        }
      case BentukMakanan.telurDadar:
        final dadar = Rect.fromCenter(
          center: Offset.zero,
          width: r * 2,
          height: r * 1.72,
        );
        kontur(Path()..addOval(dadar), w);
        c.drawOval(dadar.deflate(r * 0.13), garis(k.warnaTua, tg));
        if (detail) {
          for (var i = 0; i < 5; i++) {
            final sudut = acak.nextDouble() * 2 * pi;
            c.drawCircle(
              Offset(cos(sudut), sin(sudut) * 0.85) *
                  r *
                  (0.2 + acak.nextDouble() * 0.45),
              r * 0.05,
              isi(k.warnaTua.withValues(alpha: 0.7)),
            );
          }
        }
      case BentukMakanan.telurRebus:
        kontur(
          Path()..addOval(
            Rect.fromCenter(center: Offset.zero, width: r * 1.5, height: r * 2),
          ),
          w,
        );
        c
          ..drawCircle(Offset(0, r * 0.12), r * 0.42, isi(_W.telurKuning))
          ..drawCircle(
            Offset(0, r * 0.12),
            r * 0.42,
            garis(_W.telurKuningTua, tg * 0.8),
          );
      case BentukMakanan.tempe:
        kontur(
          Path()..addRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(
                center: Offset.zero,
                width: r * 2,
                height: r * 1.26,
              ),
              Radius.circular(r * 0.2),
            ),
          ),
          w,
        );
        // Kedelai: bintik besar selalu ada, bintik halus hanya saat detail.
        const bintik = [
          (-0.55, -0.2),
          (0.1, 0.22),
          (0.6, -0.12),
          (-0.15, -0.3),
          (-0.6, 0.3),
          (0.45, 0.32),
          (0.25, -0.34),
        ];
        final n = detail ? bintik.length : 3;
        for (var i = 0; i < n; i++) {
          c.drawCircle(
            Offset(r * bintik[i].$1, r * bintik[i].$2),
            r * (i < 3 ? 0.13 : 0.08),
            isi(_W.tempeBintik),
          );
        }
      case BentukMakanan.kubus:
        final luar = RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: r * 1.6, height: r * 1.6),
          Radius.circular(r * 0.26),
        );
        kontur(Path()..addRRect(luar), k.warnaTua);
        c.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset(-r * 0.1, -r * 0.1),
              width: r * 1.12,
              height: r * 1.12,
            ),
            Radius.circular(r * 0.18),
          ),
          isi(w),
        );
      case BentukMakanan.ayam:
        // Paha: tulang dulu, daging menutup pangkalnya.
        final a = Offset(r * 0.3, 0), b = Offset(r * 0.78, 0);
        c
          ..drawLine(a, b, garis(_tinta, r * 0.3 + tg * 2))
          ..drawCircle(b, r * 0.2 + tg, isi(_tinta))
          ..drawLine(a, b, garis(_W.tulang, r * 0.3))
          ..drawCircle(b, r * 0.2, isi(_W.tulang));
        kontur(
          Path()..addOval(
            Rect.fromCenter(
              center: Offset(-r * 0.22, 0),
              width: r * 1.5,
              height: r * 1.2,
            ),
          ),
          w,
        );
        if (detail) {
          c
            ..drawArc(
              Rect.fromCenter(
                center: Offset(-r * 0.22, 0),
                width: r * 1.0,
                height: r * 0.75,
              ),
              pi * 0.15,
              pi * 0.5,
              false,
              garis(k.warnaTua, tg * 0.8),
            )
            ..drawCircle(Offset(-r * 0.5, -r * 0.2), r * 0.06, isi(k.warnaTua));
        }
      case BentukMakanan.sosis:
        final badan = RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: r * 2, height: r * 0.84),
          Radius.circular(r * 0.42),
        );
        kontur(Path()..addRRect(badan), w);
        if (detail) {
          for (final x in [-0.4, 0.0, 0.4]) {
            c.drawLine(
              Offset(r * (x - 0.1), -r * 0.22),
              Offset(r * (x + 0.1), r * 0.22),
              garis(k.warnaTua, tg * 0.8),
            );
          }
        }
      case BentukMakanan.udang:
        final busur = Rect.fromCircle(center: Offset.zero, radius: r * 0.56);
        const awal = 0.5, sapu = 4.3;
        final ujung = Offset(cos(awal + sapu), sin(awal + sapu)) * r * 0.56;
        final arah = awal + sapu + pi / 2;
        final ekor = Path()
          ..moveTo(ujung.dx, ujung.dy)
          ..lineTo(
            ujung.dx + cos(arah - 0.6) * r * 0.5,
            ujung.dy + sin(arah - 0.6) * r * 0.5,
          )
          ..lineTo(
            ujung.dx + cos(arah + 0.6) * r * 0.5,
            ujung.dy + sin(arah + 0.6) * r * 0.5,
          )
          ..close();
        kontur(ekor, k.warnaTua);
        c
          ..drawArc(busur, awal, sapu, false, garis(_tinta, r * 0.5 + tg * 2))
          ..drawArc(busur, awal, sapu, false, garis(w, r * 0.5));
        if (detail) {
          for (var i = 1; i <= 3; i++) {
            final sudut = awal + sapu * i / 4;
            c.drawLine(
              Offset(cos(sudut), sin(sudut)) * r * 0.36,
              Offset(cos(sudut), sin(sudut)) * r * 0.76,
              garis(k.warnaTua, tg * 0.8),
            );
          }
        }
      case BentukMakanan.mie:
        kontur(
          Path()..addOval(Rect.fromCircle(center: Offset.zero, radius: r)),
          k.warnaTua,
        );
        // Gulungan: busur-busur bergeser mengelilingi pusat.
        for (var i = 0; i < 5; i++) {
          final sudut = i * 1.9 + acak.nextDouble();
          final helai = Rect.fromCircle(
            center: Offset(cos(sudut), sin(sudut)) * r * 0.14,
            radius: r * (0.78 - i * 0.15),
          );
          final sapu = 3.6 + acak.nextDouble();
          c
            ..drawArc(
              helai,
              sudut,
              sapu,
              false,
              garis(Color.lerp(k.warnaTua, _tinta, 0.45)!, r * 0.14 + tg),
            )
            ..drawArc(helai, sudut, sapu, false, garis(w, r * 0.14));
        }
      case BentukMakanan.nasi:
        final bulatan = <(Offset, double)>[
          (Offset.zero, r * 0.8),
          for (var i = 0; i < 10; i++)
            (
              Offset(cos(i * pi / 5), sin(i * pi / 5)) * r * 0.7,
              r * (0.26 + acak.nextDouble() * 0.06),
            ),
        ];
        gabung(bulatan, w);
        if (detail) {
          final butir = garis(Color.lerp(w, k.warnaTua, 0.8)!, tg * 0.8);
          for (var i = 0; i < 14; i++) {
            final sudut = acak.nextDouble() * 2 * pi;
            final o =
                Offset(cos(sudut), sin(sudut)) * r * acak.nextDouble() * 0.7;
            final arah = acak.nextDouble() * pi;
            c.drawLine(o, o + Offset(cos(arah), sin(arah)) * r * 0.1, butir);
          }
        }
      case BentukMakanan.daun:
        final lebar = r * k.rasio * 1.5;
        final daun = Path()
          ..moveTo(-r, 0)
          ..quadraticBezierTo(-r * 0.1, -lebar, r, 0)
          ..quadraticBezierTo(-r * 0.1, lebar, -r, 0)
          ..close();
        kontur(daun, w);
        c.drawLine(
          Offset(-r * 0.8, 0),
          Offset(r * 0.75, 0),
          garis(k.warnaTua, tg * 0.9),
        );
        if (detail) {
          for (final x in [-0.35, 0.0, 0.35]) {
            for (final arah in [-1, 1]) {
              c.drawLine(
                Offset(r * x, 0),
                Offset(r * (x + 0.18), arah * lebar * 0.32),
                garis(k.warnaTua, tg * 0.6),
              );
            }
          }
        }
      case BentukMakanan.brokoli:
        final batang = RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(0, r * 0.62),
            width: r * 0.42,
            height: r * 0.7,
          ),
          Radius.circular(r * 0.12),
        );
        kontur(Path()..addRRect(batang), _W.daunMuda);
        gabung([
          (Offset(-r * 0.4, -r * 0.05), r * 0.46),
          (Offset(r * 0.38, -r * 0.1), r * 0.48),
          (Offset(0, -r * 0.42), r * 0.48),
          (Offset(0, r * 0.08), r * 0.42),
        ], w);
        if (detail) {
          for (final (x, y) in [
            (-0.4, -0.1),
            (0.3, -0.2),
            (0.0, -0.5),
            (0.1, 0.1),
          ]) {
            c.drawCircle(Offset(r * x, r * y), r * 0.08, isi(k.warnaTua));
          }
        }
      case BentukMakanan.irisan:
        kontur(
          Path()..addOval(Rect.fromCircle(center: Offset.zero, radius: r)),
          k.warnaTua,
        );
        c.drawCircle(Offset.zero, r * 0.7, isi(w));
        if (detail) {
          for (var i = 0; i < 3; i++) {
            final sudut = i * pi / 3;
            c.drawLine(
              Offset(cos(sudut), sin(sudut)) * r * 0.5,
              Offset(cos(sudut), sin(sudut)) * -r * 0.5,
              garis(k.warnaTua.withValues(alpha: 0.55), tg * 0.6),
            );
          }
        }
      case BentukMakanan.jagung:
        for (final y in [-0.3, 0.3]) {
          for (final x in [-0.62, 0.0, 0.62]) {
            final butir = RRect.fromRectAndRadius(
              Rect.fromCenter(
                center: Offset(r * x, r * y),
                width: r * 0.58,
                height: r * 0.54,
              ),
              Radius.circular(r * 0.18),
            );
            c
              ..drawRRect(butir, isi(w))
              ..drawRRect(butir, garis(_tinta, tg * 0.75));
          }
        }
        if (detail) {
          for (final x in [-0.7, -0.08, 0.54]) {
            c.drawCircle(
              Offset(r * x, -r * 0.38),
              r * 0.06,
              isi(_W.telurPutih),
            );
          }
        }
      case BentukMakanan.cabai:
        final badan = Path()
          ..moveTo(-r * 0.75, r * 0.05)
          ..quadraticBezierTo(0, -r * 0.55, r * 0.9, r * 0.1);
        c
          ..drawLine(
            Offset(-r * 0.75, r * 0.05),
            Offset(-r, -r * 0.14),
            garis(k.warnaTua, r * 0.2),
          )
          ..drawPath(badan, garis(_tinta, r * 0.4 + tg * 1.6))
          ..drawPath(badan, garis(w, r * 0.4));
      case BentukMakanan.cincin:
        c
          ..drawCircle(Offset.zero, r * 0.66, garis(k.warnaTua, r * 0.5))
          ..drawCircle(Offset.zero, r * 0.66, garis(w, r * 0.3));
      case BentukMakanan.gorengan:
        // Balutan tepung keemasan; warna bahan aslinya mengintip.
        final tebal = max(k.rasio, 0.62).clamp(0.62, 0.92);
        final balut = RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: r * 2,
            height: r * 2 * tebal,
          ),
          Radius.circular(r * tebal),
        );
        kontur(Path()..addRRect(balut), _W.gorengan);
        if (detail) {
          for (var i = 0; i < 9; i++) {
            final sudut = i * 2 * pi / 9 + acak.nextDouble() * 0.3;
            c.drawCircle(
              Offset(cos(sudut) * r * 0.82, sin(sudut) * r * tebal * 0.8),
              r * 0.07,
              isi(_W.gorenganTua),
            );
          }
        }
        for (final (x, y) in [(-0.35, -0.08), (0.3, 0.12), (0.02, -0.2)]) {
          final o = Offset(r * x, r * y * tebal / 0.62);
          c
            ..drawCircle(o, r * 0.15, isi(k.warna))
            ..drawCircle(o, r * 0.15, garis(_W.gorenganTua, tg * 0.7));
        }
      case BentukMakanan.roti:
        // Dua lembar bertumpuk miring.
        for (final (dx, dy, putar) in [
          (-0.2, -0.14, -0.22),
          (0.2, 0.14, 0.2),
        ]) {
          c
            ..save()
            ..translate(r * dx, r * dy)
            ..rotate(putar);
          final lembar = RRect.fromRectAndCorners(
            Rect.fromCenter(
              center: Offset.zero,
              width: r * 1.34,
              height: r * 1.34,
            ),
            topLeft: Radius.circular(r * 0.42),
            topRight: Radius.circular(r * 0.42),
            bottomLeft: Radius.circular(r * 0.14),
            bottomRight: Radius.circular(r * 0.14),
          );
          kontur(Path()..addRRect(lembar), k.warnaTua);
          c.drawRRect(lembar.deflate(r * 0.12), isi(w));
          if (detail) {
            for (var i = 0; i < 4; i++) {
              c.drawCircle(
                Offset(
                  (acak.nextDouble() - 0.5) * r * 0.8,
                  (acak.nextDouble() - 0.5) * r * 0.8,
                ),
                r * 0.05,
                isi(k.warnaTua.withValues(alpha: 0.45)),
              );
            }
          }
          c.restore();
        }
      case BentukMakanan.kapsul:
        final tinggi = r * 2 * k.rasio;
        kontur(
          Path()..addRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(
                center: Offset.zero,
                width: r * 2,
                height: tinggi,
              ),
              Radius.circular(tinggi / 2),
            ),
          ),
          w,
        );
        if (detail && tinggi > tg * 5) {
          c.drawLine(
            Offset(-r * 0.55, tinggi * 0.18),
            Offset(r * 0.55, tinggi * 0.18),
            garis(k.warnaTua, tg * 0.8),
          );
        }
      case BentukMakanan.remah:
        const titik = [
          (-0.45, -0.3, 0.34),
          (0.4, -0.25, 0.3),
          (0.0, 0.35, 0.36),
          (-0.5, 0.4, 0.22),
          (0.5, 0.4, 0.24),
        ];
        gabung(
          [for (final (x, y, rad) in titik) (Offset(r * x, r * y), r * rad)],
          w,
          tepi: k.warnaTua,
        );
      case BentukMakanan.tauge:
        final batang = Path()
          ..moveTo(-r, r * 0.1)
          ..quadraticBezierTo(0, -r * 0.7, r * 0.75, r * 0.15);
        c
          ..drawPath(batang, garis(_tinta, r * 0.26 + tg * 1.4))
          ..drawPath(batang, garis(w, r * 0.26))
          ..drawCircle(
            Offset(r * 0.78, r * 0.15),
            r * 0.22 + tg * 0.7,
            isi(_tinta),
          )
          ..drawCircle(Offset(r * 0.78, r * 0.15), r * 0.22, isi(k.warnaTua));
      case BentukMakanan.jamur:
        kontur(
          Path()..addRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTRB(-r * 0.24, -r * 0.1, r * 0.24, r * 0.9),
              Radius.circular(r * 0.14),
            ),
          ),
          _W.telurPutih,
        );
        final tudung = Path()
          ..moveTo(-r, r * 0.05)
          ..arcToPoint(
            Offset(r, r * 0.05),
            radius: Radius.elliptical(r, r * 0.95),
          )
          ..quadraticBezierTo(0, r * 0.3, -r, r * 0.05)
          ..close();
        kontur(tudung, w);
        if (detail) {
          c.drawArc(
            Rect.fromCenter(
              center: Offset(0, -r * 0.1),
              width: r * 1.2,
              height: r * 0.9,
            ),
            pi * 1.15,
            pi * 0.4,
            false,
            garis(k.warnaTua, tg * 0.8),
          );
        }
      case BentukMakanan.generik:
        gabung([
          (Offset(-r * 0.2, 0), r * 0.7),
          (Offset(r * 0.35, -r * 0.15), r * 0.55),
          (Offset(r * 0.2, r * 0.3), r * 0.5),
        ], w);
        if (detail) {
          c.drawCircle(Offset(-r * 0.2, -r * 0.1), r * 0.16, isi(k.warnaTua));
        }
    }
  }
}
