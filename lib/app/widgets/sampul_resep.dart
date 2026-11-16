import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/models/resep_model.dart';
import '../data/services/katalog_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Nada warna sampul, ditentukan dari bahan resep.
enum NadaSampul { hijau, merah, cokelat, kuning, krem, emas }

/// Nada sampul sebuah resep: kecap → cokelat, santan → krem, cabai+tomat
/// atau saus tomat → merah, sayur daun → hijau, jagung/pisang/telur utama →
/// kuning, selain itu emas (gorengan/tumisan).
NadaSampul nadaSampul(Resep resep) {
  final wajib = {for (final b in resep.bahanWajib) b.bahanId};
  bool ada(Iterable<String> ids) => ids.any(wajib.contains);
  if (ada(const ['santan'])) return NadaSampul.krem;
  if (ada(const ['saus-tomat']) ||
      (ada(const ['cabai']) && ada(const ['tomat']))) {
    return NadaSampul.merah;
  }
  if (ada(const ['kecap-manis', 'gula-merah', 'meses'])) {
    return NadaSampul.cokelat;
  }
  if (ada(const [
    'bayam',
    'kangkung',
    'sawi-hijau',
    'brokoli',
    'buncis',
    'labu-siam',
    'timun',
  ])) {
    return NadaSampul.hijau;
  }
  if (ada(const ['jagung', 'pisang', 'telur', 'keju'])) {
    return NadaSampul.kuning;
  }
  return NadaSampul.emas;
}

/// Sampul resep yang digambar dengan kode (bukan foto): ubin pastel berisi
/// ilustrasi sajian sesuai [Resep.sajian], diwarnai menurut [nadaSampul],
/// dengan taburan berwarna kategori bahan utamanya. Bersama-sama memberi
/// tiap resep wajah yang berbeda tetapi tetap satu keluarga dengan ikon
/// bahan dan magnet. Warnanya sama di tema terang dan gelap (ilustrasi).
class SampulResep extends StatelessWidget {
  final Resep resep;
  final double ukuran;
  final double radius;

  const SampulResep({
    super.key,
    required this.resep,
    this.ukuran = AppSpacing.sampul,
    this.radius = AppSpacing.radiusM,
  });

  @override
  Widget build(BuildContext context) {
    final byId =
        Get.find<KatalogService>().katalog.value?.bahanById ?? const {};
    final taburan = [
      for (final b in resep.bahanWajib)
        if (byId[b.bahanId] case final bahan? when !bahan.bumbuDasar)
          AppColors.magnet(bahan.kategori),
    ].take(4).toList();
    return ExcludeSemantics(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: SizedBox.square(
          dimension: ukuran,
          child: CustomPaint(
            painter: SampulPainter(
              sajian: resep.sajian,
              nada: nadaSampul(resep),
              taburan: taburan,
              benih: resep.id.codeUnits.fold<int>(7, (a, b) => a * 31 + b),
            ),
          ),
        ),
      ),
    );
  }
}

class SampulPainter extends CustomPainter {
  final JenisSajian sajian;
  final NadaSampul nada;
  final List<Color> taburan;
  final int benih;

  const SampulPainter({
    required this.sajian,
    required this.nada,
    required this.taburan,
    required this.benih,
  });

  static const _tinta = AppColors.tinta;

  (Color latar, Color isi, Color isiTua) get _warna => switch (nada) {
    NadaSampul.hijau => (
      AppColors.sampulHijau,
      AppColors.sajianHijau,
      AppColors.sajianHijauTua,
    ),
    NadaSampul.merah => (
      AppColors.sampulMerah,
      AppColors.sajianMerah,
      AppColors.sajianMerahTua,
    ),
    NadaSampul.cokelat => (
      AppColors.sampulCokelat,
      AppColors.sajianCokelat,
      AppColors.sajianCokelatTua,
    ),
    NadaSampul.kuning => (
      AppColors.sampulKuning,
      AppColors.sajianKuning,
      AppColors.sajianKuningTua,
    ),
    NadaSampul.krem => (
      AppColors.sampulKrem,
      AppColors.sajianKrem,
      AppColors.sajianKremTua,
    ),
    NadaSampul.emas => (
      AppColors.sampulEmas,
      AppColors.sajianEmas,
      AppColors.sajianEmasTua,
    ),
  };

  Paint _isi(Color c) => Paint()..color = c;

  Paint _garis(double s, [double tebal = 0.028, Color warna = _tinta]) =>
      Paint()
        ..color = warna
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * tebal
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final (latar, isi, isiTua) = _warna;
    canvas.drawRect(Offset.zero & size, _isi(latar));
    // Lingkaran lembut di belakang sajian, posisinya berbeda tiap resep.
    final acak = Random(benih);
    canvas.drawCircle(
      Offset(
        s * (0.2 + acak.nextDouble() * 0.6),
        s * (0.15 + acak.nextDouble() * 0.2),
      ),
      s * (0.2 + acak.nextDouble() * 0.12),
      _isi(AppColors.putih.withValues(alpha: 0.45)),
    );

    switch (sajian) {
      case JenisSajian.kuah:
        _mangkuk(canvas, s, isi);
        _taburan(canvas, s, acak, const Offset(0.5, 0.5), 0.22, 0.05);
        _uap(canvas, s);
      case JenisSajian.mie:
        _mangkuk(canvas, s, isi);
        _mie(canvas, s);
        _taburan(canvas, s, acak, const Offset(0.5, 0.47), 0.2, 0.04);
        _sumpit(canvas, s);
      case JenisSajian.tumis:
        _wajan(canvas, s);
        _gundukan(canvas, s, isi, isiTua, const Offset(0.44, 0.57), 0.27, 0.13);
        _taburan(canvas, s, acak, const Offset(0.44, 0.55), 0.2, 0.06);
      case JenisSajian.sambal:
        _cobek(canvas, s, isi, isiTua);
        _taburan(canvas, s, acak, const Offset(0.46, 0.56), 0.16, 0.03);
      case JenisSajian.goreng:
        _piring(canvas, s);
        _gorengan(canvas, s, isi, isiTua, acak);
      case JenisSajian.nasi:
        _piring(canvas, s);
        _nasi(canvas, s, isi, acak);
      case JenisSajian.telur:
        _piring(canvas, s);
        _telur(canvas, s, isi, isiTua);
      case JenisSajian.roti:
        _piring(canvas, s);
        _roti(canvas, s, isi, isiTua);
      case JenisSajian.manis:
        _piring(canvas, s);
        _manis(canvas, s, isi, isiTua, acak);
      case JenisSajian.piring:
        _piring(canvas, s);
        _gundukan(canvas, s, isi, isiTua, const Offset(0.5, 0.57), 0.25, 0.14);
        _taburan(canvas, s, acak, const Offset(0.5, 0.55), 0.2, 0.07);
    }
  }

  /// Piring putih dilihat agak dari atas.
  void _piring(Canvas canvas, double s) {
    final luar = Rect.fromCenter(
      center: Offset(s * 0.5, s * 0.6),
      width: s * 0.84,
      height: s * 0.5,
    );
    canvas
      ..drawOval(luar.shift(Offset(0, s * 0.03)), _isi(AppColors.bayangan))
      ..drawOval(luar, _isi(AppColors.putih))
      ..drawOval(luar, _garis(s))
      ..drawOval(
        Rect.fromCenter(center: luar.center, width: s * 0.6, height: s * 0.33),
        _garis(s, 0.018, AppColors.garis),
      );
  }

  /// Gundukan makanan (setengah elips) dengan sisi bawah lebih gelap.
  void _gundukan(
    Canvas canvas,
    double s,
    Color isi,
    Color isiTua,
    Offset pusat,
    double lebar,
    double tinggi,
  ) {
    final kotak = Rect.fromCenter(
      center: Offset(s * pusat.dx, s * pusat.dy),
      width: s * lebar * 2,
      height: s * tinggi * 2,
    );
    canvas
      ..drawOval(kotak, _isi(isiTua))
      ..drawOval(
        Rect.fromLTRB(
          kotak.left + s * 0.02,
          kotak.top,
          kotak.right - s * 0.02,
          kotak.bottom - s * 0.05,
        ),
        _isi(isi),
      )
      ..drawOval(kotak, _garis(s, 0.022));
  }

  /// Taburan kecil berwarna kategori bahan utama.
  void _taburan(
    Canvas canvas,
    double s,
    Random acak,
    Offset pusat,
    double sebarX,
    double sebarY,
  ) {
    final warna = taburan.isEmpty ? const [AppColors.putih] : taburan;
    for (var i = 0; i < 5; i++) {
      final sudut = acak.nextDouble() * 2 * pi;
      final jarak = 0.3 + acak.nextDouble() * 0.7;
      final titik = Offset(
        s * (pusat.dx + cos(sudut) * sebarX * jarak),
        s * (pusat.dy + sin(sudut) * sebarY * jarak),
      );
      canvas
        ..drawCircle(titik, s * 0.035, _isi(warna[i % warna.length]))
        ..drawCircle(titik, s * 0.035, _garis(s, 0.014));
    }
  }

  void _mangkuk(Canvas canvas, double s, Color kuah) {
    final mulut = Rect.fromCenter(
      center: Offset(s * 0.5, s * 0.5),
      width: s * 0.76,
      height: s * 0.28,
    );
    final badan = Path()
      ..moveTo(mulut.left, mulut.center.dy)
      ..quadraticBezierTo(s * 0.16, s * 0.9, s * 0.5, s * 0.9)
      ..quadraticBezierTo(s * 0.84, s * 0.9, mulut.right, mulut.center.dy)
      ..close();
    canvas
      ..drawOval(
        Rect.fromCenter(
          center: Offset(s * 0.5, s * 0.9),
          width: s * 0.5,
          height: s * 0.08,
        ),
        _isi(AppColors.bayangan),
      )
      ..drawPath(badan, _isi(AppColors.putih))
      ..drawPath(badan, _garis(s))
      // Garis hias di badan mangkuk.
      ..drawArc(
        Rect.fromCenter(
          center: Offset(s * 0.5, s * 0.6),
          width: s * 0.6,
          height: s * 0.36,
        ),
        pi * 0.15,
        pi * 0.7,
        false,
        _garis(s, 0.02, AppColors.aksen),
      )
      ..drawOval(mulut, _isi(AppColors.putih))
      ..drawOval(mulut.deflate(s * 0.035), _isi(kuah))
      ..drawOval(mulut, _garis(s));
  }

  void _uap(Canvas canvas, double s) {
    for (final x in [0.38, 0.52, 0.66]) {
      final uap = Path()
        ..moveTo(s * x, s * 0.3)
        ..quadraticBezierTo(s * (x - 0.05), s * 0.23, s * x, s * 0.17)
        ..quadraticBezierTo(s * (x + 0.05), s * 0.11, s * x, s * 0.06);
      canvas.drawPath(uap, _garis(s, 0.024, AppColors.putih));
    }
  }

  void _mie(Canvas canvas, double s) {
    final mie = _garis(s, 0.03, AppColors.sajianKuning);
    for (var i = 0; i < 4; i++) {
      final y = s * (0.455 + i * 0.03);
      final jalur = Path()..moveTo(s * 0.26, y);
      for (var j = 0; j < 4; j++) {
        final x0 = s * (0.26 + j * 0.12);
        jalur.quadraticBezierTo(
          x0 + s * 0.06,
          y + (j.isEven ? -1 : 1) * s * 0.035,
          x0 + s * 0.12,
          y,
        );
      }
      canvas.drawPath(jalur, mie);
    }
  }

  void _sumpit(Canvas canvas, double s) {
    final kayu = _garis(s, 0.035, AppColors.sajianCokelat);
    canvas
      ..drawLine(Offset(s * 0.58, s * 0.5), Offset(s * 0.9, s * 0.14), kayu)
      ..drawLine(Offset(s * 0.66, s * 0.52), Offset(s * 0.95, s * 0.22), kayu);
  }

  void _wajan(Canvas canvas, double s) {
    final wajan = Rect.fromCenter(
      center: Offset(s * 0.44, s * 0.6),
      width: s * 0.74,
      height: s * 0.44,
    );
    // Gagang.
    canvas
      ..drawLine(
        Offset(s * 0.76, s * 0.5),
        Offset(s * 0.95, s * 0.36),
        _garis(s, 0.09, _tinta),
      )
      ..drawLine(
        Offset(s * 0.78, s * 0.485),
        Offset(s * 0.94, s * 0.37),
        _garis(s, 0.04, AppColors.sajianCokelat),
      )
      ..drawOval(wajan.shift(Offset(0, s * 0.03)), _isi(AppColors.bayangan))
      ..drawOval(wajan, _isi(AppColors.wajan))
      ..drawOval(wajan.deflate(s * 0.05), _isi(AppColors.wajanDalam))
      ..drawOval(wajan, _garis(s));
  }

  void _cobek(Canvas canvas, double s, Color isi, Color isiTua) {
    final cobek = Rect.fromCenter(
      center: Offset(s * 0.46, s * 0.6),
      width: s * 0.76,
      height: s * 0.46,
    );
    canvas
      ..drawOval(cobek.shift(Offset(0, s * 0.03)), _isi(AppColors.bayangan))
      ..drawOval(cobek, _isi(AppColors.batu))
      ..drawOval(cobek, _garis(s))
      ..drawOval(cobek.deflate(s * 0.06), _isi(AppColors.batuDalam));
    _gundukan(canvas, s, isi, isiTua, const Offset(0.46, 0.6), 0.22, 0.1);
    // Ulekan.
    canvas
      ..drawLine(
        Offset(s * 0.6, s * 0.52),
        Offset(s * 0.86, s * 0.2),
        _garis(s, 0.13, _tinta),
      )
      ..drawLine(
        Offset(s * 0.6, s * 0.52),
        Offset(s * 0.86, s * 0.2),
        _garis(s, 0.08, AppColors.batu),
      );
  }

  void _gorengan(
    Canvas canvas,
    double s,
    Color isi,
    Color isiTua,
    Random acak,
  ) {
    for (final (x, y, sudut) in [
      (0.34, 0.58, -0.35),
      (0.62, 0.6, 0.3),
      (0.48, 0.47, 0.05 + acak.nextDouble() * 0.3),
    ]) {
      canvas
        ..save()
        ..translate(s * x, s * y)
        ..rotate(sudut);
      final potong = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: s * 0.3, height: s * 0.17),
        Radius.circular(s * 0.06),
      );
      canvas
        ..drawRRect(potong.shift(Offset(0, s * 0.02)), _isi(isiTua))
        ..drawRRect(potong, _isi(isi))
        ..drawRRect(potong, _garis(s, 0.022))
        // Remah renyah.
        ..drawCircle(Offset(-s * 0.06, -s * 0.02), s * 0.014, _isi(isiTua))
        ..drawCircle(Offset(s * 0.05, s * 0.025), s * 0.014, _isi(isiTua))
        ..restore();
    }
    if (taburan.isNotEmpty) {
      canvas
        ..drawCircle(Offset(s * 0.78, s * 0.47), s * 0.045, _isi(taburan.first))
        ..drawCircle(Offset(s * 0.78, s * 0.47), s * 0.045, _garis(s, 0.016));
    }
  }

  void _nasi(Canvas canvas, double s, Color isi, Random acak) {
    final kubah = Path()
      ..moveTo(s * 0.26, s * 0.62)
      ..quadraticBezierTo(s * 0.28, s * 0.3, s * 0.5, s * 0.3)
      ..quadraticBezierTo(s * 0.72, s * 0.3, s * 0.74, s * 0.62)
      ..quadraticBezierTo(s * 0.5, s * 0.72, s * 0.26, s * 0.62)
      ..close();
    canvas
      ..drawPath(kubah, _isi(Color.lerp(AppColors.putih, isi, 0.35)!))
      ..drawPath(kubah, _garis(s, 0.024));
    // Butir & bumbu.
    for (var i = 0; i < 9; i++) {
      final titik = Offset(
        s * (0.34 + acak.nextDouble() * 0.32),
        s * (0.38 + acak.nextDouble() * 0.24),
      );
      canvas.drawCircle(
        titik,
        s * 0.016,
        _isi(
          i.isEven
              ? isi
              : (taburan.isEmpty ? isi : taburan[i % taburan.length]),
        ),
      );
    }
  }

  void _telur(Canvas canvas, double s, Color isi, Color isiTua) {
    final putih = Path()
      ..addOval(
        Rect.fromCenter(
          center: Offset(s * 0.48, s * 0.57),
          width: s * 0.5,
          height: s * 0.3,
        ),
      )
      ..addOval(
        Rect.fromCenter(
          center: Offset(s * 0.62, s * 0.62),
          width: s * 0.3,
          height: s * 0.2,
        ),
      );
    canvas
      ..drawPath(putih, _isi(AppColors.bawangPutih))
      ..drawPath(putih, _garis(s, 0.02, AppColors.bawangPutihGaris));
    final kuning = Rect.fromCenter(
      center: Offset(s * 0.47, s * 0.55),
      width: s * 0.2,
      height: s * 0.14,
    );
    canvas
      ..drawOval(kuning, _isi(AppColors.sajianKuning))
      ..drawOval(kuning, _garis(s, 0.02, AppColors.sajianKuningTua))
      ..drawArc(
        kuning.deflate(s * 0.025),
        pi * 1.1,
        pi * 0.4,
        false,
        _garis(s, 0.018, AppColors.putih),
      );
  }

  void _roti(Canvas canvas, double s, Color isi, Color isiTua) {
    canvas
      ..save()
      ..translate(s * 0.5, s * 0.52)
      ..rotate(-0.12);
    final roti = RRect.fromRectAndCorners(
      Rect.fromCenter(center: Offset.zero, width: s * 0.44, height: s * 0.4),
      topLeft: Radius.circular(s * 0.16),
      topRight: Radius.circular(s * 0.16),
      bottomLeft: Radius.circular(s * 0.05),
      bottomRight: Radius.circular(s * 0.05),
    );
    canvas
      ..drawRRect(
        roti.shift(Offset(s * 0.03, s * 0.03)),
        _isi(AppColors.sajianEmasTua),
      )
      ..drawRRect(roti, _isi(AppColors.sajianEmasTua))
      ..drawRRect(roti.deflate(s * 0.035), _isi(AppColors.sajianKrem))
      ..drawRRect(roti, _garis(s, 0.024))
      // Olesan/isi berwarna nada.
      ..drawOval(
        Rect.fromCenter(
          center: Offset(0, s * 0.02),
          width: s * 0.24,
          height: s * 0.18,
        ),
        _isi(isi),
      )
      ..restore();
  }

  void _manis(Canvas canvas, double s, Color isi, Color isiTua, Random acak) {
    for (final (x, y, sudut) in [(0.4, 0.55, -0.25), (0.6, 0.6, 0.2)]) {
      canvas
        ..save()
        ..translate(s * x, s * y)
        ..rotate(sudut);
      final potong = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: s * 0.36, height: s * 0.13),
        Radius.circular(s * 0.065),
      );
      canvas
        ..drawRRect(potong, _isi(AppColors.sajianKuning))
        ..drawRRect(potong, _garis(s, 0.022))
        ..restore();
    }
    // Siraman cokelat berkelok.
    final siram = Path()..moveTo(s * 0.26, s * 0.5);
    for (var i = 0; i < 5; i++) {
      siram.lineTo(s * (0.33 + i * 0.1), s * (i.isEven ? 0.66 : 0.48));
    }
    canvas.drawPath(siram, _garis(s, 0.03, AppColors.sajianCokelat));
    for (var i = 0; i < 6; i++) {
      canvas.drawCircle(
        Offset(
          s * (0.3 + acak.nextDouble() * 0.4),
          s * (0.5 + acak.nextDouble() * 0.14),
        ),
        s * 0.014,
        _isi(i.isEven ? AppColors.putih : isiTua),
      );
    }
  }

  @override
  bool shouldRepaint(SampulPainter lama) =>
      lama.sajian != sajian ||
      lama.nada != nada ||
      lama.benih != benih ||
      lama.taburan.length != taburan.length;
}
