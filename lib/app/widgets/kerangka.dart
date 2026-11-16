import 'package:flutter/material.dart';

import '../theme/app_palet.dart';
import '../theme/app_spacing.dart';

/// Kerangka pemuatan (skeleton): blok abu berkilau yang meniru bentuk isi
/// sebenarnya, supaya layar tidak "melompat" saat data datang.
///
/// Semua [Kerangka] di bawah satu [KilauKerangka] berkilau serempak. Bila
/// pengguna mematikan animasi, kilau diam.
class KilauKerangka extends StatefulWidget {
  final Widget child;

  const KilauKerangka({super.key, required this.child});

  static Animation<double>? _dari(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_KilauTurunan>()?.animasi;

  @override
  State<KilauKerangka> createState() => _KilauKerangkaState();
}

class _KilauKerangkaState extends State<KilauKerangka>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animasi = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _animasi.stop();
    } else if (!_animasi.isAnimating) {
      _animasi.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _animasi.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Sedang memuat',
    child: ExcludeSemantics(
      child: _KilauTurunan(animasi: _animasi, child: widget.child),
    ),
  );
}

class _KilauTurunan extends InheritedWidget {
  final Animation<double> animasi;

  const _KilauTurunan({required this.animasi, required super.child});

  @override
  bool updateShouldNotify(_KilauTurunan lama) => lama.animasi != animasi;
}

/// Satu blok kerangka.
class Kerangka extends StatelessWidget {
  final double? lebar;
  final double tinggi;
  final double radius;

  const Kerangka({
    super.key,
    this.lebar,
    required this.tinggi,
    this.radius = AppSpacing.radiusS,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palet;
    final animasi = KilauKerangka._dari(context);
    Widget kotak(Color warna) => Container(
      width: lebar,
      height: tinggi,
      decoration: BoxDecoration(
        color: warna,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
    if (animasi == null) return kotak(p.kerangka);
    return AnimatedBuilder(
      animation: animasi,
      builder: (_, _) => kotak(
        Color.lerp(
          p.kerangka,
          p.kerangkaKilau,
          Curves.easeInOut.transform(animasi.value),
        )!,
      ),
    );
  }
}

/// Kerangka daftar magnet di pintu kulkas.
class KerangkaMagnet extends StatelessWidget {
  const KerangkaMagnet({super.key});

  static const _lebar = [96.0, 108.0, 88.0, 120.0, 100.0, 92.0, 132.0, 84.0];

  @override
  Widget build(BuildContext context) {
    return KilauKerangka(
      key: const Key('kerangka-magnet'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var kelompok = 0; kelompok < 2; kelompok++) ...[
            const Padding(
              padding: EdgeInsets.only(top: AppSpacing.s, bottom: AppSpacing.m),
              child: Kerangka(lebar: 72, tinggi: AppSpacing.m),
            ),
            Wrap(
              spacing: AppSpacing.m,
              runSpacing: AppSpacing.m,
              children: [
                for (final lebar in _lebar)
                  Kerangka(
                    lebar: lebar,
                    tinggi: AppSpacing.sentuh,
                    radius: AppSpacing.radiusPill,
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.l),
          ],
        ],
      ),
    );
  }
}

/// Kerangka satu kartu resep (sampul + tiga baris teks).
class KerangkaKartuResep extends StatelessWidget {
  const KerangkaKartuResep({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.palet;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.m),
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: p.permukaan,
        borderRadius: BorderRadius.circular(AppSpacing.radiusM),
        border: Border.all(color: p.garis, width: 0.6),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Kerangka(
            lebar: AppSpacing.sampul,
            tinggi: AppSpacing.sampul,
            radius: AppSpacing.radiusM,
          ),
          SizedBox(width: AppSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Kerangka(tinggi: AppSpacing.l + AppSpacing.xs),
                SizedBox(height: AppSpacing.s),
                Kerangka(lebar: 140, tinggi: AppSpacing.m),
                SizedBox(height: AppSpacing.m),
                Kerangka(lebar: 180, tinggi: AppSpacing.xl),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
