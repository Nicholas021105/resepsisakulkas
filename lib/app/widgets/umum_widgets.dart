import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_palet.dart';
import '../theme/app_spacing.dart';

/// Satu pilihan pada [PilihanSegmen].
class Segmen<T> {
  final T nilai;
  final String label;
  final IconData? ikon;
  final Key? kunci;

  const Segmen(this.nilai, this.label, {this.ikon, this.kunci});
}

/// Pemilih bersegmen berbentuk pil (mis. tema, Favorit | Riwayat). Segmen
/// terpilih memakai permukaan kebalikan, sama seperti chip terpilih.
class PilihanSegmen<T> extends StatelessWidget {
  final List<Segmen<T>> pilihan;
  final T nilai;
  final ValueChanged<T> onPilih;

  const PilihanSegmen({
    super.key,
    required this.pilihan,
    required this.nilai,
    required this.onPilih,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palet;
    final teks = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: p.permukaan,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        border: Border.all(color: p.garis),
      ),
      child: Row(
        children: [
          for (final s in pilihan)
            Expanded(
              child: Semantics(
                button: true,
                selected: s.nilai == nilai,
                inMutuallyExclusiveGroup: true,
                child: AnimatedContainer(
                  duration: AppGerak.cepat,
                  decoration: BoxDecoration(
                    color: s.nilai == nilai ? p.balik : AppColors.transparan,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                  ),
                  child: Material(
                    color: AppColors.transparan,
                    child: InkWell(
                      key: s.kunci,
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusPill,
                      ),
                      onTap: () {
                        if (s.nilai == nilai) return;
                        HapticFeedback.selectionClick();
                        onPilih(s.nilai);
                      },
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          minHeight: AppSpacing.sentuh,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.s,
                            vertical: AppSpacing.xs,
                          ),
                          child: Center(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (s.ikon != null) ...[
                                    Icon(
                                      s.ikon,
                                      size: 18,
                                      color: s.nilai == nilai
                                          ? p.diBalik
                                          : p.tintaLembut,
                                    ),
                                    const SizedBox(width: AppSpacing.xs + 2),
                                  ],
                                  Text(
                                    s.label,
                                    maxLines: 1,
                                    style: teks.labelLarge?.copyWith(
                                      color: s.nilai == nilai
                                          ? p.diBalik
                                          : p.tinta,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Judul kecil berhuruf kapital untuk bagian halaman.
class JudulBagian extends StatelessWidget {
  final String teks;

  const JudulBagian(this.teks, {super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Padding(
        padding: const EdgeInsets.only(
          left: AppSpacing.xs,
          bottom: AppSpacing.s,
        ),
        child: Text(
          teks,
          style: Theme.of(context).textTheme.labelSmall
              ?.copyWith(color: context.palet.tintaLembut),
        ),
      ),
    );
  }
}

/// Kotak ikon 40×40 yang sama untuk semua baris daftar (leading).
class KotakIkon extends StatelessWidget {
  final Widget child;
  final Color latar;

  const KotakIkon({super.key, required this.child, required this.latar});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: latar,
        borderRadius: BorderRadius.circular(AppSpacing.radiusS),
      ),
      child: child,
    );
  }
}

/// Label kecil berbentuk pil dengan ikon opsional (mis. "Segera habiskan").
class LabelPil extends StatelessWidget {
  final String teks;
  final IconData? ikon;
  final Color latar;
  final Color warna;
  final int maksBaris;

  const LabelPil({
    super.key,
    required this.teks,
    required this.latar,
    required this.warna,
    this.ikon,
    this.maksBaris = 2,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s + 2,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: latar,
        borderRadius: BorderRadius.circular(AppSpacing.radiusS),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (ikon != null) ...[
            Icon(ikon, size: 14, color: warna),
            const SizedBox(width: AppSpacing.xs),
          ],
          Flexible(
            child: Text(
              teks,
              maxLines: maksBaris,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium
                  ?.copyWith(color: warna),
            ),
          ),
        ],
      ),
    );
  }
}

/// Satu aksi di lembar bawah: ikon dalam kotak, judul, dan keterangan.
class AksiLembar extends StatelessWidget {
  final IconData ikon;
  final String judul;
  final String? keterangan;
  final Color latarIkon;
  final Color warnaIkon;
  final VoidCallback onTap;

  const AksiLembar({
    super.key,
    required this.ikon,
    required this.judul,
    required this.latarIkon,
    required this.warnaIkon,
    required this.onTap,
    this.keterangan,
  });

  @override
  Widget build(BuildContext context) {
    final teks = Theme.of(context).textTheme;
    final radius = BorderRadius.circular(AppSpacing.radiusM);
    return Material(
      color: AppColors.transparan,
      child: InkWell(
        borderRadius: radius,
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AppSpacing.tombol),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s,
              vertical: AppSpacing.s,
            ),
            child: Row(
              children: [
                KotakIkon(
                  latar: latarIkon,
                  child: Icon(ikon, color: warnaIkon),
                ),
                const SizedBox(width: AppSpacing.m),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(judul, style: teks.titleMedium),
                      if (keterangan != null)
                        Text(keterangan!, style: teks.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Tombol "Tutup" di dasar lembar bawah.
class AksiTutupLembar extends StatelessWidget {
  const AksiTutupLembar({super.key});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      key: const Key('tutup-lembar'),
      onPressed: () => Navigator.of(context).pop(),
      child: const Text('Tutup'),
    );
  }
}

/// Ikon aplikasi (aset gambar yang sama dengan ikon launcher), bersudut
/// bulat. Dekoratif kecuali diberi [label] untuk pembaca layar.
class IkonAplikasi extends StatelessWidget {
  final double ukuran;
  final String? label;

  const IkonAplikasi({super.key, this.ukuran = 40, this.label});

  static const aset = 'assets/ikon/ikon_app.png';

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(ukuran * 0.24),
      child: Image.asset(
        aset,
        width: ukuran,
        height: ukuran,
        // Sumber 1024 px diperkecil: dekode seperlunya saja.
        cacheWidth: (ukuran * MediaQuery.devicePixelRatioOf(context)).round(),
        filterQuality: FilterQuality.medium,
        semanticLabel: label,
        excludeFromSemantics: label == null,
      ),
    );
  }
}
