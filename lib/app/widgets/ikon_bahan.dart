import 'dart:math';

import 'package:flutter/material.dart';

import '../data/models/bahan_model.dart';
import '../theme/app_colors.dart';

/// Ikon bahan berukuran tetap. Digambar sendiri dengan CustomPainter bila
/// emojinya tampil polos/kurang tepat (tahu ⬜, tempe 🟫, kecap 🍶) atau
/// terlalu baru sehingga tampil sebagai kotak kosong di Android lama
/// (buncis 🫛 Unicode 15, minyak 🫗 Unicode 14, bawang 🧅🧄 / tiram 🦪 /
/// margarin 🧈 Unicode 12 = belum ada sebelum Android 10). Bahan lain memakai
/// emoji. Data JSON tidak diubah, jadi data server tetap cocok.
///
/// Test `test/ikon_bahan_test.dart` memastikan setiap bahan di dataset punya
/// pelukis atau emoji dengan code point Unicode ≤ 12.
class IkonBahan extends StatelessWidget {
  final String id;
  final String emoji;
  final double ukuran;

  const IkonBahan({
    super.key,
    required this.id,
    required this.emoji,
    this.ukuran = 28,
  });

  IkonBahan.dari(Bahan bahan, {Key? key, double ukuran = 28})
    : this(key: key, id: bahan.id, emoji: bahan.emoji, ukuran: ukuran);

  /// Emoji pengganti: 🥫 kornet sama persis dengan saus tomat.
  static const _gantiEmoji = {'kornet': '🥩'};

  static CustomPainter? _pelukis(String id) => switch (id) {
    'tahu' => const _TahuPainter(),
    'tempe' => const _TempePainter(),
    'kecap-manis' => const _KecapPainter(),
    'buncis' => const _BuncisPainter(),
    'minyak-goreng' => const _MinyakPainter(),
    'bawang-merah' => const _BawangPainter(merah: true),
    'bawang-putih' => const _BawangPainter(merah: false),
    'margarin' => const _MargarinPainter(),
    'saus-tiram' => const _SausTiramPainter(),
    _ => null,
  };

  /// Bahan ini digambar dengan CustomPainter (bukan emoji).
  static bool punyaPelukis(String id) => _pelukis(id) != null;

  /// Emoji yang benar-benar ditampilkan untuk bahan tanpa pelukis.
  static String emojiTampil(String id, String emoji) =>
      _gantiEmoji[id] ?? emoji;

  @override
  Widget build(BuildContext context) {
    final pelukis = _pelukis(id);
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: ukuran,
        child: pelukis != null
            ? CustomPaint(painter: pelukis)
            : Center(
                child: Text(
                  emojiTampil(id, emoji),
                  // Ikon: ukurannya tetap, tidak ikut textScaler.
                  textScaler: TextScaler.noScaling,
                  style: TextStyle(fontSize: ukuran * 0.8, height: 1),
                ),
              ),
      ),
    );
  }
}

Paint _isi(Color warna) => Paint()..color = warna;

Paint _garis(Color warna, double tebal) => Paint()
  ..color = warna
  ..style = PaintingStyle.stroke
  ..strokeWidth = tebal
  ..strokeJoin = StrokeJoin.round;

/// Balok 3D sederhana: muka depan, atas, dan sisi kanan.
({Path depan, Path atas, Path sisi}) _balok(
  Size s, {
  required double kiri,
  required double atas,
  required double lebar,
  required double tinggi,
  required double dalam,
}) {
  final w = s.width, h = s.height;
  final x0 = w * kiri, y0 = h * atas;
  final x1 = x0 + w * lebar, y1 = y0 + h * tinggi;
  final dx = w * dalam, dy = h * dalam * 0.8;
  return (
    depan: Path()..addRect(Rect.fromLTRB(x0, y0, x1, y1)),
    atas: Path()
      ..moveTo(x0, y0)
      ..lineTo(x0 + dx, y0 - dy)
      ..lineTo(x1 + dx, y0 - dy)
      ..lineTo(x1, y0)
      ..close(),
    sisi: Path()
      ..moveTo(x1, y0)
      ..lineTo(x1 + dx, y0 - dy)
      ..lineTo(x1 + dx, y1 - dy)
      ..lineTo(x1, y1)
      ..close(),
  );
}

/// Tahu: kubus kuning krem dengan sisi 3D tipis.
class _TahuPainter extends CustomPainter {
  const _TahuPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final b = _balok(
      size,
      kiri: 0.12,
      atas: 0.34,
      lebar: 0.6,
      tinggi: 0.56,
      dalam: 0.18,
    );
    final tepi = _garis(AppColors.tahuGaris, size.width * 0.045);
    canvas
      ..drawPath(b.depan, _isi(AppColors.tahuMuka))
      ..drawPath(b.atas, _isi(AppColors.tahuAtas))
      ..drawPath(b.sisi, _isi(AppColors.tahuSisi))
      ..drawPath(b.depan, tepi)
      ..drawPath(b.atas, tepi)
      ..drawPath(b.sisi, tepi);
    // Pori-pori halus di muka depan.
    final pori = _isi(AppColors.tahuSisi);
    for (final (x, y) in [(0.3, 0.55), (0.52, 0.7), (0.36, 0.78)]) {
      canvas.drawCircle(
        Offset(size.width * x, size.height * y),
        size.width * 0.03,
        pori,
      );
    }
  }

  @override
  bool shouldRepaint(_TahuPainter lama) => false;
}

/// Tempe: balok cokelat pipih dengan titik-titik kedelai.
class _TempePainter extends CustomPainter {
  const _TempePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final b = _balok(
      size,
      kiri: 0.06,
      atas: 0.42,
      lebar: 0.72,
      tinggi: 0.42,
      dalam: 0.16,
    );
    final tepi = _garis(AppColors.tempeSisi, size.width * 0.04);
    canvas
      ..drawPath(b.depan, _isi(AppColors.tempeMuka))
      ..drawPath(b.atas, _isi(AppColors.tempeAtas))
      ..drawPath(b.sisi, _isi(AppColors.tempeSisi))
      ..drawPath(b.depan, tepi)
      ..drawPath(b.atas, tepi);
    final titik = _isi(AppColors.tempeTitik);
    for (final (x, y) in [
      (0.17, 0.53),
      (0.33, 0.66),
      (0.5, 0.52),
      (0.64, 0.7),
      (0.22, 0.76),
      (0.46, 0.79),
      (0.68, 0.56),
    ]) {
      canvas.drawCircle(
        Offset(size.width * x, size.height * y),
        size.width * 0.04,
        titik,
      );
    }
  }

  @override
  bool shouldRepaint(_TempePainter lama) => false;
}

/// Kecap manis: botol gelap dengan label krem dan tutup merah.
class _KecapPainter extends CustomPainter {
  const _KecapPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final botol = Path()
      ..moveTo(w * 0.42, h * 0.16)
      ..lineTo(w * 0.58, h * 0.16)
      ..lineTo(w * 0.58, h * 0.34)
      ..quadraticBezierTo(w * 0.72, h * 0.4, w * 0.72, h * 0.52)
      ..lineTo(w * 0.72, h * 0.9)
      ..quadraticBezierTo(w * 0.72, h * 0.95, w * 0.67, h * 0.95)
      ..lineTo(w * 0.33, h * 0.95)
      ..quadraticBezierTo(w * 0.28, h * 0.95, w * 0.28, h * 0.9)
      ..lineTo(w * 0.28, h * 0.52)
      ..quadraticBezierTo(w * 0.28, h * 0.4, w * 0.42, h * 0.34)
      ..close();
    canvas
      ..drawPath(botol, _isi(AppColors.kecapBotol))
      ..drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(w * 0.4, h * 0.05, w * 0.6, h * 0.17),
          Radius.circular(w * 0.03),
        ),
        _isi(AppColors.kecapTutup),
      )
      ..drawRect(
        Rect.fromLTRB(w * 0.28, h * 0.58, w * 0.72, h * 0.8),
        _isi(AppColors.kecapLabel),
      )
      // Kilau kaca.
      ..drawLine(
        Offset(w * 0.36, h * 0.48),
        Offset(w * 0.36, h * 0.54),
        _garis(AppColors.kecapKilau, w * 0.04)..strokeCap = StrokeCap.round,
      );
  }

  @override
  bool shouldRepaint(_KecapPainter lama) => false;
}

/// Buncis: tiga polong hijau melengkung berujung runcing dengan tonjolan biji.
class _BuncisPainter extends CustomPainter {
  const _BuncisPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    // (ujung awal, kontrol lengkung, ujung akhir, warna isi), belakang dulu.
    for (final (a, c, b, isi) in [
      (
        Offset(w * 0.08, h * 0.62),
        Offset(w * 0.36, h * 0.12),
        Offset(w * 0.9, h * 0.18),
        AppColors.buncisTua,
      ),
      (
        Offset(w * 0.06, h * 0.84),
        Offset(w * 0.42, h * 0.34),
        Offset(w * 0.94, h * 0.42),
        AppColors.buncisMuda,
      ),
      (
        Offset(w * 0.14, h * 0.96),
        Offset(w * 0.5, h * 0.6),
        Offset(w * 0.92, h * 0.7),
        AppColors.buncisMuda,
      ),
    ]) {
      _polong(canvas, w, a, c, b, isi);
    }
  }

  static Offset _kuadrat(Offset a, Offset c, Offset b, double t) =>
      a * ((1 - t) * (1 - t)) + c * (2 * (1 - t) * t) + b * (t * t);

  void _polong(
    Canvas canvas,
    double w,
    Offset a,
    Offset c,
    Offset b,
    Color isi,
  ) {
    // Normal terhadap garis a→b untuk membentuk polong lonjong.
    final arah = b - a;
    final normal = Offset(-arah.dy, arah.dx) / arah.distance * (w * 0.11);
    final polong = Path()
      ..moveTo(a.dx, a.dy)
      ..quadraticBezierTo(c.dx - normal.dx, c.dy - normal.dy, b.dx, b.dy)
      ..quadraticBezierTo(c.dx + normal.dx, c.dy + normal.dy, a.dx, a.dy)
      ..close();
    canvas
      ..drawPath(polong, _isi(isi))
      ..drawPath(polong, _garis(AppColors.buncisTua, w * 0.04));
    // Tonjolan biji di sepanjang polong.
    final biji = _isi(AppColors.buncisBiji);
    for (final t in [0.3, 0.46, 0.62, 0.78]) {
      canvas.drawCircle(_kuadrat(a, c, b, t), w * 0.045, biji);
    }
  }

  @override
  bool shouldRepaint(_BuncisPainter lama) => false;
}

/// Minyak goreng: botol kuning keemasan bertutup hijau, label putih dengan
/// tetes minyak. Sengaja berbeda dari garam (botol tabur putih kebiruan).
class _MinyakPainter extends CustomPainter {
  const _MinyakPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final botol = Path()
      ..moveTo(w * 0.42, h * 0.2)
      ..lineTo(w * 0.58, h * 0.2)
      ..lineTo(w * 0.58, h * 0.3)
      ..quadraticBezierTo(w * 0.74, h * 0.36, w * 0.74, h * 0.48)
      ..lineTo(w * 0.74, h * 0.9)
      ..quadraticBezierTo(w * 0.74, h * 0.96, w * 0.68, h * 0.96)
      ..lineTo(w * 0.32, h * 0.96)
      ..quadraticBezierTo(w * 0.26, h * 0.96, w * 0.26, h * 0.9)
      ..lineTo(w * 0.26, h * 0.48)
      ..quadraticBezierTo(w * 0.26, h * 0.36, w * 0.42, h * 0.3)
      ..close();
    canvas
      ..drawPath(botol, _isi(AppColors.minyakEmas))
      ..drawPath(botol, _garis(AppColors.minyakTepi, w * 0.04))
      ..drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(w * 0.39, h * 0.04, w * 0.61, h * 0.2),
          Radius.circular(w * 0.04),
        ),
        _isi(AppColors.minyakTutup),
      )
      // Label putih.
      ..drawRect(
        Rect.fromLTRB(w * 0.26, h * 0.56, w * 0.74, h * 0.82),
        _isi(AppColors.putih),
      );
    // Tetes minyak emas di label.
    final tetes = Path()
      ..moveTo(w * 0.5, h * 0.59)
      ..quadraticBezierTo(w * 0.6, h * 0.71, w * 0.5, h * 0.79)
      ..quadraticBezierTo(w * 0.4, h * 0.71, w * 0.5, h * 0.59)
      ..close();
    canvas
      ..drawPath(tetes, _isi(AppColors.minyakEmas))
      // Kilau kaca.
      ..drawLine(
        Offset(w * 0.33, h * 0.42),
        Offset(w * 0.33, h * 0.5),
        _garis(AppColors.minyakKilau, w * 0.05)..strokeCap = StrokeCap.round,
      );
  }

  @override
  bool shouldRepaint(_MinyakPainter lama) => false;
}

/// Bawang merah (ungu kemerahan) atau bawang putih (putih krem bersiung),
/// dengan pucuk kering dan akar kecil.
class _BawangPainter extends CustomPainter {
  final bool merah;

  const _BawangPainter({required this.merah});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final isi = merah ? AppColors.bawangMerah : AppColors.bawangPutih;
    final tepi = merah ? AppColors.bawangMerahTua : AppColors.bawangPutihGaris;
    final umbi = Path()
      ..moveTo(w * 0.5, h * 0.14)
      ..cubicTo(w * 0.58, h * 0.3, w * 0.92, h * 0.4, w * 0.88, h * 0.64)
      ..cubicTo(w * 0.84, h * 0.86, w * 0.64, h * 0.9, w * 0.5, h * 0.9)
      ..cubicTo(w * 0.36, h * 0.9, w * 0.16, h * 0.86, w * 0.12, h * 0.64)
      ..cubicTo(w * 0.08, h * 0.4, w * 0.42, h * 0.3, w * 0.5, h * 0.14)
      ..close();
    final akar = _garis(AppColors.bawangAkar, w * 0.035)
      ..strokeCap = StrokeCap.round;
    for (final dx in [-0.08, 0.0, 0.08]) {
      canvas.drawLine(
        Offset(w * (0.5 + dx * 0.5), h * 0.89),
        Offset(w * (0.5 + dx), h * 0.97),
        akar,
      );
    }
    canvas
      ..drawPath(umbi, _isi(isi))
      // Garis siung / lapisan kulit.
      ..drawPath(
        Path()
          ..moveTo(w * 0.5, h * 0.2)
          ..quadraticBezierTo(w * 0.26, h * 0.56, w * 0.42, h * 0.88)
          ..moveTo(w * 0.5, h * 0.2)
          ..quadraticBezierTo(w * 0.74, h * 0.56, w * 0.58, h * 0.88),
        _garis(tepi, w * 0.03),
      )
      ..drawPath(umbi, _garis(tepi, w * 0.045))
      // Pucuk kering.
      ..drawLine(
        Offset(w * 0.5, h * 0.15),
        Offset(w * 0.53, h * 0.04),
        _garis(AppColors.bawangAkar, w * 0.06)..strokeCap = StrokeCap.round,
      );
    if (merah) {
      canvas.drawArc(
        Rect.fromLTWH(w * 0.2, h * 0.46, w * 0.22, h * 0.28),
        3.4,
        1.0,
        false,
        _garis(AppColors.bawangMerahKilau, w * 0.05)
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_BawangPainter lama) => lama.merah != merah;
}

/// Margarin: balok kuning cerah di atas piring kecil (beda dari tahu yang
/// berupa kubus krem tanpa piring).
class _MargarinPainter extends CustomPainter {
  const _MargarinPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    canvas.drawOval(
      Rect.fromLTRB(w * 0.04, h * 0.66, w * 0.96, h * 0.92),
      _isi(AppColors.abuCincin),
    );
    final b = _balok(
      size,
      kiri: 0.14,
      atas: 0.44,
      lebar: 0.6,
      tinggi: 0.32,
      dalam: 0.16,
    );
    final tepi = _garis(AppColors.margarinSisi, w * 0.04);
    canvas
      ..drawPath(b.depan, _isi(AppColors.margarinMuka))
      ..drawPath(b.atas, _isi(AppColors.margarinAtas))
      ..drawPath(b.sisi, _isi(AppColors.margarinSisi))
      ..drawPath(b.depan, tepi)
      ..drawPath(b.atas, tepi)
      // Bekas olesan pisau di atas.
      ..drawLine(
        Offset(w * 0.3, h * 0.38),
        Offset(w * 0.6, h * 0.38),
        _garis(AppColors.margarinSisi, w * 0.035)..strokeCap = StrokeCap.round,
      );
  }

  @override
  bool shouldRepaint(_MargarinPainter lama) => false;
}

/// Saus tiram: botol gemuk cokelat gelap bertutup oranye, label krem dengan
/// cangkang tiram (beda dari kecap: botol ramping, tutup merah).
class _SausTiramPainter extends CustomPainter {
  const _SausTiramPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final botol = Path()
      ..moveTo(w * 0.4, h * 0.22)
      ..lineTo(w * 0.6, h * 0.22)
      ..lineTo(w * 0.6, h * 0.34)
      ..quadraticBezierTo(w * 0.82, h * 0.38, w * 0.82, h * 0.52)
      ..lineTo(w * 0.82, h * 0.88)
      ..quadraticBezierTo(w * 0.82, h * 0.96, w * 0.74, h * 0.96)
      ..lineTo(w * 0.26, h * 0.96)
      ..quadraticBezierTo(w * 0.18, h * 0.96, w * 0.18, h * 0.88)
      ..lineTo(w * 0.18, h * 0.52)
      ..quadraticBezierTo(w * 0.18, h * 0.38, w * 0.4, h * 0.34)
      ..close();
    canvas
      ..drawPath(botol, _isi(AppColors.tiramBotol))
      ..drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(w * 0.36, h * 0.06, w * 0.64, h * 0.22),
          Radius.circular(w * 0.04),
        ),
        _isi(AppColors.wortel),
      )
      ..drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(w * 0.24, h * 0.54, w * 0.76, h * 0.88),
          Radius.circular(w * 0.04),
        ),
        _isi(AppColors.tiramLabel),
      );
    // Cangkang tiram: kipas setengah lingkaran dengan rusuk.
    final pusat = Offset(w * 0.5, h * 0.8);
    final r = w * 0.17;
    canvas.drawArc(
      Rect.fromCircle(center: pusat, radius: r),
      pi,
      pi,
      true,
      _isi(AppColors.tiramCangkang),
    );
    final rusuk = _garis(AppColors.tiramLabel, w * 0.025);
    for (final sudut in [-2.5, -1.9, -1.25, -0.65]) {
      canvas.drawLine(
        pusat,
        pusat + Offset.fromDirection(sudut, r * 0.95),
        rusuk,
      );
    }
  }

  @override
  bool shouldRepaint(_SausTiramPainter lama) => false;
}
