import 'dart:math';

import 'package:flutter/material.dart';

import '../data/models/bahan_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_palet.dart';

/// Ilustrasi kulkas kosong (CustomPainter, kanvas 1:1).
///
/// Kulkas tampak depan: pintu freezer di atas berhias magnet, kompartemen
/// bawah terbuka dengan lampu menyala dan rak yang hanya berisi siluet
/// putus-putus (telur, tomat, botol, sayur) sebagai tanda "kosong", pintu
/// bawah terayun ke kanan, udara dingin mengalir di kiri.
///
/// Saat pertama tampil pintu terbuka, lalu magnet muncul satu per satu.
/// Bila pengguna mengaktifkan "kurangi gerak", ilustrasi langsung tampil
/// dalam keadaan akhir.
class IlustrasiKulkasKosong extends StatefulWidget {
  final double ukuran;

  const IlustrasiKulkasKosong({super.key, this.ukuran = 140});

  /// Lama animasi pembuka.
  static const durasi = Duration(milliseconds: 1400);

  @override
  State<IlustrasiKulkasKosong> createState() => _IlustrasiKulkasKosongState();
}

class _IlustrasiKulkasKosongState extends State<IlustrasiKulkasKosong>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animasi = AnimationController(
    vsync: this,
    duration: IlustrasiKulkasKosong.durasi,
  );
  bool _dimulai = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _animasi.value = 1;
    } else if (!_dimulai) {
      _animasi.forward();
    }
    _dimulai = true;
  }

  @override
  void dispose() {
    _animasi.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palet;
    return ExcludeSemantics(
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _animasi,
          builder: (_, _) => CustomPaint(
            size: Size.square(widget.ukuran),
            painter: KulkasKosongPainter(p, maju: _animasi.value),
          ),
        ),
      ),
    );
  }
}

/// Pelukis kulkas kosong. [maju] 0 → 1: pintu bawah terbuka (paruh awal),
/// lalu magnet, udara dingin, dan kilau muncul berurutan.
class KulkasKosongPainter extends CustomPainter {
  const KulkasKosongPainter(this.p, {this.maju = 1});

  final Palet p;
  final double maju;

  // Geometri (pecahan sisi kanvas).
  static const _kiri = 0.15, _kanan = 0.66, _atas = 0.05, _bawah = 0.9;
  static const _sekat = 0.33; // batas freezer / kompartemen bawah
  static const _dalamAtas = 0.365, _dalamBawah = 0.87;

  /// Sudut akhir ayunan pintu (0 = tertutup, π/2 = tegak lurus).
  static const _sudutBuka = 2.05;

  static double _selang(double t, double awal, double akhir, Curve kurva) =>
      kurva.transform(((t - awal) / (akhir - awal)).clamp(0.0, 1.0));

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final buka = _selang(maju, 0, 0.5, Curves.easeInOutCubic);
    final dingin = _selang(maju, 0.4, 0.75, Curves.easeOut);

    Paint isi(Color c) => Paint()..color = c;
    Paint garis(Color c, double tebal) => Paint()
      ..color = c
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * tebal
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    Offset o(double x, double y) => Offset(s * x, s * y);
    Rect kotak(double l, double t, double r, double b) =>
        Rect.fromLTRB(s * l, s * t, s * r, s * b);

    // Bayangan di lantai.
    canvas.drawOval(
      Rect.fromCenter(
        center: o(0.44, 0.945),
        width: s * 0.66,
        height: s * 0.07,
      ),
      isi(p.bayangan),
    );
    // Dua kaki kecil.
    for (final x in [_kiri + 0.07, _kanan - 0.07]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: o(x, 0.915),
            width: s * 0.07,
            height: s * 0.05,
          ),
          Radius.circular(s * 0.015),
        ),
        isi(p.tinta),
      );
    }

    // Badan.
    final badan = RRect.fromRectAndRadius(
      kotak(_kiri, _atas, _kanan, _bawah),
      Radius.circular(s * 0.07),
    );
    canvas.drawRRect(badan, isi(p.permukaan));

    // Pintu freezer.
    canvas
      ..save()
      ..clipRRect(badan)
      ..drawRect(kotak(_kiri, _atas, _kanan, _sekat), isi(p.aksenLembut))
      ..restore()
      ..drawLine(o(_kiri, _sekat), o(_kanan, _sekat), garis(p.tinta, 0.022))
      // Gagang vertikal di kiri.
      ..drawLine(o(0.22, 0.12), o(0.22, 0.26), garis(p.tinta, 0.05))
      ..drawLine(o(0.22, 0.12), o(0.22, 0.26), garis(p.permukaan, 0.022));

    // Interior kompartemen bawah.
    final dalam = RRect.fromRectAndRadius(
      kotak(_kiri + 0.04, _dalamAtas, _kanan - 0.04, _dalamBawah),
      Radius.circular(s * 0.03),
    );
    canvas
      ..drawRRect(dalam, isi(p.mintPucat))
      ..save()
      ..clipRRect(dalam);
    // Cahaya lampu: trapesium melebar ke bawah.
    final cahaya = Path()
      ..moveTo(s * 0.36, s * _dalamAtas)
      ..lineTo(s * 0.45, s * _dalamAtas)
      ..lineTo(s * 0.6, s * _dalamBawah)
      ..lineTo(s * 0.21, s * _dalamBawah)
      ..close();
    canvas
      ..drawPath(cahaya, isi(p.pisangLembut.withValues(alpha: 0.75 * buka)))
      ..restore()
      // Lampu kecil.
      ..drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: o(0.405, _dalamAtas + 0.016),
            width: s * 0.1,
            height: s * 0.032,
          ),
          Radius.circular(s * 0.016),
        ),
        isi(p.pisang),
      );
    // Dua rak.
    const rak1 = 0.535, rak2 = 0.695;
    for (final y in [rak1, rak2]) {
      canvas.drawLine(
        o(_kiri + 0.04, y),
        o(_kanan - 0.04, y),
        garis(p.aksen, 0.02),
      );
    }
    // Laci.
    final laci = RRect.fromRectAndRadius(
      kotak(_kiri + 0.065, 0.745, _kanan - 0.065, 0.845),
      Radius.circular(s * 0.022),
    );
    canvas
      ..drawRRect(laci, isi(p.permukaan))
      ..drawRRect(laci, garis(p.tinta, 0.016))
      ..drawLine(o(0.36, 0.795), o(0.45, 0.795), garis(p.tinta, 0.02));

    // Siluet putus-putus: yang seharusnya ada di rak.
    final siluet = garis(p.tintaLembut, 0.011);
    void putus(Path jalur) =>
        canvas.drawPath(_putusPutus(jalur, s * 0.022, s * 0.016), siluet);
    // Telur (lonjong, lancip di atas) & tomat (pipih, bertangkai) di rak
    // atas: dibedakan bentuknya agar terbaca juga di ukuran kecil.
    putus(
      Path()
        ..moveTo(s * 0.265, s * (rak1 - 0.008))
        ..cubicTo(
          s * 0.222,
          s * (rak1 - 0.008),
          s * 0.232,
          s * (rak1 - 0.112),
          s * 0.265,
          s * (rak1 - 0.112),
        )
        ..cubicTo(
          s * 0.298,
          s * (rak1 - 0.112),
          s * 0.308,
          s * (rak1 - 0.008),
          s * 0.265,
          s * (rak1 - 0.008),
        ),
    );
    putus(
      Path()..addOval(
        Rect.fromCenter(
          center: o(0.4, rak1 - 0.045),
          width: s * 0.105,
          height: s * 0.078,
        ),
      ),
    );
    // Tangkai tomat: garis utuh (bukan putus-putus) supaya tetap terlihat.
    canvas
      ..drawLine(o(0.4, rak1 - 0.084), o(0.4, rak1 - 0.108), siluet)
      ..drawLine(o(0.4, rak1 - 0.088), o(0.378, rak1 - 0.1), siluet)
      ..drawLine(o(0.4, rak1 - 0.088), o(0.422, rak1 - 0.1), siluet);
    // Botol & sayur di rak bawah.
    putus(
      Path()
        ..moveTo(s * 0.245, s * (rak2 - 0.008))
        ..lineTo(s * 0.245, s * (rak2 - 0.085))
        ..lineTo(s * 0.262, s * (rak2 - 0.105))
        ..lineTo(s * 0.262, s * (rak2 - 0.135))
        ..lineTo(s * 0.288, s * (rak2 - 0.135))
        ..lineTo(s * 0.288, s * (rak2 - 0.105))
        ..lineTo(s * 0.305, s * (rak2 - 0.085))
        ..lineTo(s * 0.305, s * (rak2 - 0.008))
        ..close(),
    );
    putus(
      Path()
        // Wortel/sayur: badan lancip + dua helai daun.
        ..moveTo(s * 0.375, s * (rak2 - 0.012))
        ..quadraticBezierTo(
          s * 0.45,
          s * (rak2 - 0.03),
          s * 0.5,
          s * (rak2 - 0.095),
        )
        ..quadraticBezierTo(
          s * 0.43,
          s * (rak2 - 0.085),
          s * 0.375,
          s * (rak2 - 0.012),
        )
        ..moveTo(s * 0.5, s * (rak2 - 0.095))
        ..lineTo(s * 0.545, s * (rak2 - 0.13))
        ..moveTo(s * 0.5, s * (rak2 - 0.095))
        ..lineTo(s * 0.555, s * (rak2 - 0.085)),
    );
    canvas.drawRRect(dalam, garis(p.tinta, 0.016));

    // Pintu bawah: trapesium LURUS berengsel di tepi kanan badan. Sisi luar
    // (tepi bebas) lebih tinggi: tepi atas naik dan tepi bawah turun sama
    // besar. Di bawah 90° terlihat sisi luarnya (menutup interior);
    // setelahnya sisi dalam, terayun ke kanan.
    final sudut = _sudutBuka * buka;
    final xBebas = _kanan - (_kanan - _kiri) * cos(sudut);
    final miring = 0.05 * sin(sudut);
    final sisiLuar = sudut < pi / 2;
    final rentang = xBebas - _kanan;
    // Tepi atas/bawah pintu sebagai fungsi x. Semua isi pintu dihitung
    // dengan interpolasi di antara keduanya: y = atas(x) + f × tinggi(x),
    // sehingga rak ikut perspektif pintu (rak atas hampir datar, rak bawah
    // miring searah tepi bawah).
    double porsi(double x) => rentang.abs() < 1e-9 ? 0 : (x - _kanan) / rentang;
    double atasPintu(double x) => _sekat - miring * porsi(x);
    double bawahPintu(double x) => _bawah + miring * porsi(x);
    Offset diPintu(double t, double f) {
      final x = _kanan + rentang * t;
      return o(x, atasPintu(x) + f * (bawahPintu(x) - atasPintu(x)));
    }

    /// Segi empat di pintu: t0–t1 dari engsel ke tepi bebas, f0–f1 dari
    /// tepi atas ke tepi bawah.
    Path segi(double t0, double t1, double f0, double f1) {
      final a = diPintu(t0, f0), b = diPintu(t1, f0);
      final c = diPintu(t1, f1), d = diPintu(t0, f1);
      return Path()
        ..moveTo(a.dx, a.dy)
        ..lineTo(b.dx, b.dy)
        ..lineTo(c.dx, c.dy)
        ..lineTo(d.dx, d.dy)
        ..close();
    }

    Path jalur(List<(double, double)> titik) {
      final awal = diPintu(titik.first.$1, titik.first.$2);
      final hasil = Path()..moveTo(awal.dx, awal.dy);
      for (final (t, f) in titik.skip(1)) {
        final p = diPintu(t, f);
        hasil.lineTo(p.dx, p.dy);
      }
      return hasil;
    }

    final daunPintu = segi(0, 1, 0, 1);
    if (sisiLuar) {
      canvas
        ..save()
        ..clipRRect(badan)
        ..drawPath(daunPintu, isi(p.permukaan))
        ..restore();
      if (cos(sudut) > 0.25) {
        canvas
          ..drawLine(
            diPintu(0.86, 0.14),
            diPintu(0.86, 0.42),
            garis(p.tinta, 0.05),
          )
          ..drawLine(
            diPintu(0.86, 0.14),
            diPintu(0.86, 0.42),
            garis(p.aksenLembut, 0.022),
          );
      }
    } else {
      // Ketebalan pintu: strip tipis di tepi luar.
      final tebal = rentang.abs() < 1e-9 ? 0.0 : 0.045 / rentang;
      final strip = segi(1, 1 + tebal, 0, 1);
      canvas
        ..drawPath(strip, isi(p.abuCincin))
        ..drawPath(strip, garis(p.tinta, 0.014))
        ..drawPath(daunPintu, isi(p.permukaan))
        // Panel dalam.
        ..drawPath(segi(0.1, 0.9, 0.07, 0.93), isi(p.aksenLembut));
      // Siluet stoples (rak atas) dan botol (rak bawah) digambar SEBELUM
      // bilah rak, sehingga bagian bawahnya tertutup bilah.
      putus(
        jalur(const [
          (0.3, 0.46),
          (0.3, 0.25),
          (0.38, 0.25),
          (0.38, 0.19),
          (0.62, 0.19),
          (0.62, 0.25),
          (0.7, 0.25),
          (0.7, 0.46),
        ]),
      );
      putus(
        jalur(const [
          (0.36, 0.8),
          (0.36, 0.64),
          (0.45, 0.6),
          (0.45, 0.54),
          (0.57, 0.54),
          (0.57, 0.6),
          (0.66, 0.64),
          (0.66, 0.8),
        ]),
      );
      // Dua bilah rak pintu.
      for (final (f0, f1) in const [(0.40, 0.50), (0.74, 0.84)]) {
        final bilah = segi(0.12, 0.88, f0, f1);
        canvas
          ..drawPath(bilah, isi(p.permukaan))
          ..drawPath(bilah, garis(p.aksen, 0.016));
      }
      canvas.drawPath(daunPintu, garis(p.tinta, 0.022));
    }

    // Garis tepi badan di atas segalanya (pintu terbuka keluar dari badan).
    canvas.drawRRect(badan, garis(p.tinta, 0.032));
    if (!sisiLuar) {
      canvas.drawLine(
        o(_kanan, _sekat),
        o(_kanan, _bawah),
        garis(p.tinta, 0.032),
      );
    }
    // Dua titik engsel di sisi badan.
    for (final y in [_sekat + 0.085, _bawah - 0.085]) {
      canvas
        ..drawCircle(o(_kanan, y), s * 0.024, isi(p.tinta))
        ..drawCircle(o(_kanan, y), s * 0.011, isi(p.abuCincin));
    }

    // Empat magnet pil di pintu freezer, muncul berurutan.
    const magnet = [
      (0.33, 0.13, -0.3, KategoriBahan.protein),
      (0.5, 0.12, 0.22, KategoriBahan.sayur),
      (0.4, 0.24, 0.12, KategoriBahan.karbohidrat),
      (0.56, 0.235, -0.24, KategoriBahan.bumbu),
    ];
    for (var i = 0; i < magnet.length; i++) {
      final (x, y, miring, kategori) = magnet[i];
      final awal = 0.5 + i * 0.09;
      final skala = _selang(maju, awal, awal + 0.22, Curves.easeOutBack);
      if (skala <= 0) continue;
      canvas
        ..save()
        ..translate(s * x, s * y)
        ..rotate(miring)
        ..scale(skala);
      final pil = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset.zero,
          width: s * 0.125,
          height: s * 0.07,
        ),
        Radius.circular(s * 0.035),
      );
      canvas
        ..drawRRect(pil.shift(Offset(0, s * 0.008)), isi(p.bayangan))
        ..drawRRect(pil, isi(AppColors.magnet(kategori)))
        ..drawRRect(pil, garis(p.tinta, 0.014))
        ..restore();
    }

    // Udara dingin: tiga garis gelombang di kiri.
    if (dingin > 0) {
      final hijau = AppColors.magnet(KategoriBahan.sayur);
      for (var i = 0; i < 3; i++) {
        final y = 0.5 + i * 0.1;
        final geser = (1 - dingin) * 0.05;
        final panjang = i == 1 ? 0.11 : 0.085;
        final x0 = 0.125 - panjang + geser;
        final ombak = Path()
          ..moveTo(s * x0, s * y)
          ..quadraticBezierTo(
            s * (x0 + panjang * 0.25),
            s * (y - 0.028),
            s * (x0 + panjang * 0.5),
            s * y,
          )
          ..quadraticBezierTo(
            s * (x0 + panjang * 0.75),
            s * (y + 0.028),
            s * (x0 + panjang),
            s * y,
          );
        canvas.drawPath(ombak, garis(hijau.withValues(alpha: dingin), 0.024));
      }
    }

    // Kilau bintang empat sudut dan titik kecil.
    void kilau(double x, double y, double r, Color warna, double awal) {
      final k = _selang(maju, awal, awal + 0.2, Curves.easeOutBack);
      if (k <= 0) return;
      final jari = s * r * k;
      final c = o(x, y);
      final bintang = Path()..moveTo(c.dx, c.dy - jari);
      for (var i = 1; i <= 4; i++) {
        final sudutUjung = -pi / 2 + i * pi / 2;
        final sudutLekuk = sudutUjung - pi / 4;
        bintang
          ..lineTo(
            c.dx + cos(sudutLekuk) * jari * 0.32,
            c.dy + sin(sudutLekuk) * jari * 0.32,
          )
          ..lineTo(
            c.dx + cos(sudutUjung) * jari,
            c.dy + sin(sudutUjung) * jari,
          );
      }
      canvas.drawPath(bintang..close(), isi(warna));
    }

    kilau(0.87, 0.14, 0.06, p.aksen, 0.7);
    kilau(0.065, 0.24, 0.045, p.wortel, 0.8);
    final titik = _selang(maju, 0.85, 1, Curves.easeOut);
    if (titik > 0) {
      canvas
        ..drawCircle(o(0.955, 0.2), s * 0.014 * titik, isi(p.wortel))
        ..drawCircle(o(0.045, 0.36), s * 0.012 * titik, isi(p.aksen));
    }
  }

  /// Mengubah [sumber] menjadi garis putus-putus.
  static Path _putusPutus(Path sumber, double garis, double jeda) {
    final hasil = Path();
    for (final metrik in sumber.computeMetrics()) {
      var jarak = 0.0;
      while (jarak < metrik.length) {
        hasil.addPath(
          metrik.extractPath(jarak, min(jarak + garis, metrik.length)),
          Offset.zero,
        );
        jarak += garis + jeda;
      }
    }
    return hasil;
  }

  @override
  bool shouldRepaint(KulkasKosongPainter lama) =>
      lama.p != p || lama.maju != maju;
}
