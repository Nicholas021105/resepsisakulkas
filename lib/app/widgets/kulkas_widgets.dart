import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/models/bahan_model.dart';
import '../data/models/katalog_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text.dart';

/// Ikon sumber data: server = tersinkron, cache = riwayat, bawaan = bawaan
/// aplikasi (bukan awan, karena awan berarti online).
IconData ikonSumber(SumberData sumber) => switch (sumber) {
  SumberData.server => Icons.cloud_done_outlined,
  SumberData.cache => Icons.history,
  SumberData.bawaan => Icons.inventory_2_outlined,
};

/// Bayangan sangat halus untuk kartu yang "terangkat".
const bayanganKartu = [
  BoxShadow(
    color: AppColors.bayanganHalus,
    blurRadius: 16,
    offset: Offset(0, 4),
  ),
];

/// Memudarkan tepi isi yang bisa digulir (kanan untuk baris chip, bawah
/// untuk area gulir di atas tombol) sebagai petunjuk "masih ada lagi".
class FadeTepi extends StatelessWidget {
  final Widget child;
  final Axis arah;
  final double lebar;

  const FadeTepi({
    super.key,
    required this.child,
    this.arah = Axis.horizontal,
    this.lebar = AppSpacing.xl,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (batas) {
        final panjang = arah == Axis.horizontal ? batas.width : batas.height;
        final mulai = panjang <= lebar ? 0.0 : 1 - lebar / panjang;
        return LinearGradient(
          begin: arah == Axis.horizontal
              ? Alignment.centerLeft
              : Alignment.topCenter,
          end: arah == Axis.horizontal
              ? Alignment.centerRight
              : Alignment.bottomCenter,
          colors: const [
            AppColors.putih,
            AppColors.putih,
            AppColors.transparan,
          ],
          stops: [0, mulai, 1],
        ).createShader(batas);
      },
      child: child,
    );
  }
}

/// Area "pintu kulkas": kartu besar bersudut membulat dengan garis gagang
/// tipis di sisi kanan, sedikit terangkat oleh bayangan halus.
class PintuKulkas extends StatelessWidget {
  final Widget child;

  const PintuKulkas({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.permukaan,
        borderRadius: BorderRadius.circular(AppSpacing.radiusL),
        border: Border.all(color: AppColors.garis),
        boxShadow: bayanganKartu,
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.l,
              AppSpacing.l,
              AppSpacing.xl + AppSpacing.s,
              AppSpacing.l,
            ),
            child: child,
          ),
          // Gagang pintu.
          Positioned(
            right: AppSpacing.s + 2,
            top: AppSpacing.xxxl,
            child: Container(
              width: 5,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.garis,
                borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Cincin persentase kecil: hijau 100%, kuning 50–99%, abu < 50%.
class CincinPersen extends StatelessWidget {
  final int persen;
  final double ukuran;

  const CincinPersen({super.key, required this.persen, this.ukuran = 60});

  @override
  Widget build(BuildContext context) {
    final warna = AppColors.cincin(persen);
    return Semantics(
      label: '$persen persen cocok',
      child: SizedBox.square(
        dimension: ukuran,
        child: TweenAnimationBuilder<double>(
          tween: Tween(end: persen / 100),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
          builder: (_, nilai, anak) => CustomPaint(
            painter: _CincinPainter(nilai: nilai, warna: warna),
            child: anak,
          ),
          child: Center(
            child: Padding(
              // Jarak aman dari garis cincin (tebal 10%) agar "100%" tidak
              // menyentuh cincin.
              padding: EdgeInsets.all(ukuran * 0.2),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text('$persen%', style: AppText.angka(ukuran / 4)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CincinPainter extends CustomPainter {
  final double nilai;
  final Color warna;

  _CincinPainter({required this.nilai, required this.warna});

  @override
  void paint(Canvas canvas, Size size) {
    final tebal = size.shortestSide * 0.1;
    final rect = Rect.fromCircle(
      center: size.center(Offset.zero),
      radius: size.shortestSide / 2 - tebal / 2,
    );
    final cat = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = tebal
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, 0, 2 * pi, false, cat..color = AppColors.garis);
    if (nilai > 0) {
      canvas.drawArc(rect, -pi / 2, 2 * pi * nilai, false, cat..color = warna);
    }
  }

  @override
  bool shouldRepaint(_CincinPainter lama) =>
      lama.nilai != nilai || lama.warna != warna;
}

/// Ilustrasi kulkas terbuka yang kosong (CustomPainter).
class IlustrasiKulkasKosong extends StatelessWidget {
  final double ukuran;

  const IlustrasiKulkasKosong({super.key, this.ukuran = 140});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(ukuran, ukuran),
      painter: const _KulkasPainter(),
    );
  }
}

class _KulkasPainter extends CustomPainter {
  const _KulkasPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final garis = Paint()
      ..color = AppColors.tinta
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.025
      ..strokeJoin = StrokeJoin.round;

    // Bayangan lembut di lantai.
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.52, h * 0.93),
        width: w * 0.78,
        height: h * 0.08,
      ),
      Paint()
        ..color = AppColors.bayangan
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, w * 0.02),
    );

    // Badan kulkas.
    final badan = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.16, h * 0.04, w * 0.46, h * 0.86),
      Radius.circular(w * 0.06),
    );
    canvas.drawRRect(badan, Paint()..color = AppColors.aksenLembut);
    canvas.drawRRect(badan, garis);
    // Rak kosong.
    for (final y in [0.28, 0.5, 0.72]) {
      canvas.drawLine(
        Offset(w * 0.2, h * y),
        Offset(w * 0.58, h * y),
        garis..color = AppColors.aksen,
      );
    }
    garis.color = AppColors.tinta;
    // Pintu terbuka (miring ke kanan).
    final pintu = Path()
      ..moveTo(w * 0.62, h * 0.04)
      ..lineTo(w * 0.9, h * 0.12)
      ..lineTo(w * 0.9, h * 0.82)
      ..lineTo(w * 0.62, h * 0.9)
      ..close();
    canvas.drawPath(pintu, Paint()..color = AppColors.permukaan);
    canvas.drawPath(pintu, garis);
    // Gagang pintu.
    canvas.drawLine(
      Offset(w * 0.67, h * 0.4),
      Offset(w * 0.67, h * 0.56),
      Paint()
        ..color = AppColors.garis
        ..strokeWidth = w * 0.03
        ..strokeCap = StrokeCap.round,
    );
    // Magnet kecil berwarna kategori di pintu, sedikit miring.
    for (final (x, y, sudut, kategori) in [
      (0.77, 0.26, -0.2, KategoriBahan.protein),
      (0.8, 0.46, 0.15, KategoriBahan.sayur),
      (0.76, 0.66, -0.1, KategoriBahan.karbohidrat),
    ]) {
      canvas
        ..save()
        ..translate(w * x, h * y)
        ..rotate(sudut);
      final magnet = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: w * 0.13, height: h * 0.08),
        Radius.circular(w * 0.04),
      );
      canvas
        ..drawRRect(magnet, Paint()..color = AppColors.magnet(kategori))
        ..drawRRect(
          magnet,
          Paint()
            ..color = AppColors.tinta
            ..style = PaintingStyle.stroke
            ..strokeWidth = w * 0.012,
        )
        ..restore();
    }
    // Udara dingin.
    final dingin = Paint()
      ..color = AppColors.aksen
      ..strokeWidth = w * 0.02
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(w * 0.04, h * 0.38),
      Offset(w * 0.1, h * 0.38),
      dingin,
    );
    canvas.drawLine(
      Offset(w * 0.02, h * 0.48),
      Offset(w * 0.1, h * 0.48),
      dingin,
    );
  }

  @override
  bool shouldRepaint(_KulkasPainter lama) => false;
}

/// Empty state: ilustrasi, judul, pesan, dan satu ajakan bertindak.
class KeadaanKosong extends StatelessWidget {
  final Widget ilustrasi;
  final String judul;
  final String pesan;
  final String? labelAksi;
  final VoidCallback? onAksi;
  final Key? kunciAksi;

  const KeadaanKosong({
    super.key,
    required this.ilustrasi,
    required this.judul,
    required this.pesan,
    this.labelAksi,
    this.onAksi,
    this.kunciAksi,
  });

  @override
  Widget build(BuildContext context) {
    final teks = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xxl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ilustrasi,
          const SizedBox(height: AppSpacing.l),
          Text(judul, textAlign: TextAlign.center, style: teks.titleLarge),
          const SizedBox(height: AppSpacing.s),
          Text(
            pesan,
            textAlign: TextAlign.center,
            style: teks.bodyMedium?.copyWith(color: AppColors.tintaLembut),
          ),
          if (labelAksi != null && onAksi != null) ...[
            const SizedBox(height: AppSpacing.xl),
            FilledButton(
              key: kunciAksi,
              onPressed: () {
                HapticFeedback.lightImpact();
                onAksi!();
              },
              child: Text(labelAksi!, textAlign: TextAlign.center),
            ),
          ],
        ],
      ),
    );
  }
}

/// Ilustrasi emoji besar dalam lingkaran (untuk empty state lain).
class EmojiBesar extends StatelessWidget {
  final String emoji;

  const EmojiBesar(this.emoji, {super.key});

  @override
  Widget build(BuildContext context) {
    return _LingkaranIlustrasi(
      child: Text(
        emoji,
        textScaler: TextScaler.noScaling,
        style: const TextStyle(fontSize: 48, height: 1),
      ),
    );
  }
}

/// Hati koral besar (CustomPainter) untuk keadaan Favorit kosong.
class IlustrasiHati extends StatelessWidget {
  const IlustrasiHati({super.key});

  @override
  Widget build(BuildContext context) {
    return const _LingkaranIlustrasi(
      ukuran: 120,
      child: CustomPaint(size: Size(60, 56), painter: _HatiPainter()),
    );
  }
}

/// Lingkaran mint pucat dengan bayangan halus sebagai latar ilustrasi.
class _LingkaranIlustrasi extends StatelessWidget {
  final Widget child;
  final double ukuran;

  const _LingkaranIlustrasi({required this.child, this.ukuran = 104});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ukuran,
      height: ukuran,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppColors.aksenLembut,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.bayangan,
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _HatiPainter extends CustomPainter {
  const _HatiPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final hati = Path()
      ..moveTo(w * 0.5, h * 0.96)
      ..cubicTo(w * 0.1, h * 0.68, -w * 0.02, h * 0.4, w * 0.08, h * 0.2)
      ..cubicTo(w * 0.18, 0, w * 0.42, -h * 0.02, w * 0.5, h * 0.2)
      ..cubicTo(w * 0.58, -h * 0.02, w * 0.82, 0, w * 0.92, h * 0.2)
      ..cubicTo(w * 1.02, h * 0.4, w * 0.9, h * 0.68, w * 0.5, h * 0.96)
      ..close();
    canvas.drawPath(hati, Paint()..color = AppColors.hatiKoral);
    // Kilau kecil di kiri atas.
    canvas.drawArc(
      Rect.fromLTWH(w * 0.16, h * 0.14, w * 0.26, h * 0.3),
      pi * 1.05,
      pi * 0.45,
      false,
      Paint()
        ..color = AppColors.putih
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.055
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_HatiPainter lama) => false;
}
