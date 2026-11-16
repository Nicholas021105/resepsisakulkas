import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/models/bahan_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_palet.dart';
import '../theme/app_spacing.dart';
import 'ikon_bahan.dart';

/// Bahan sebagai "magnet kulkas": chip lonjong berwarna kategori dengan
/// ikon bahan.
///
/// Saat dipilih magnet "menempel": menghentak seperti tertarik ke pintu
/// kulkas, lalu diam sedikit miring (tiap magnet punya kemiringan sendiri,
/// seperti magnet sungguhan), dengan bayangan lebih tegas dan tanda ✓.
/// Bahan yang perlu segera dihabiskan memakai lencana jam pasir kuning.
class MagnetBahan extends StatefulWidget {
  final Bahan bahan;
  final bool dipilih;

  /// Bahan ini perlu segera dihabiskan.
  final bool segera;
  final VoidCallback onTap;

  /// Tekan lama (opsi kesegaran); null = tidak ada aksi.
  final VoidCallback? onTekanLama;

  const MagnetBahan({
    super.key,
    required this.bahan,
    required this.dipilih,
    required this.onTap,
    this.segera = false,
    this.onTekanLama,
  });

  @override
  State<MagnetBahan> createState() => _MagnetBahanState();
}

class _MagnetBahanState extends State<MagnetBahan>
    with SingleTickerProviderStateMixin {
  late final AnimationController _hentak = AnimationController(
    vsync: this,
    duration: AppGerak.tempel,
    value: 1,
  );

  /// Mundur sedikit, melesat menempel, lalu memantul diam.
  static final _skalaHentak = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween(
        begin: 1.0,
        end: 0.9,
      ).chain(CurveTween(curve: Curves.easeOut)),
      weight: 20,
    ),
    TweenSequenceItem(
      tween: Tween(
        begin: 0.9,
        end: 1.12,
      ).chain(CurveTween(curve: Curves.easeOutCubic)),
      weight: 35,
    ),
    TweenSequenceItem(
      tween: Tween(
        begin: 1.12,
        end: 1.0,
      ).chain(CurveTween(curve: Curves.elasticOut)),
      weight: 45,
    ),
  ]);

  /// Kemiringan tetap per bahan: −2° … +2°.
  double get _miring {
    final benih = widget.bahan.id.codeUnits.fold<int>(0, (a, b) => a * 31 + b);
    return ((benih % 9) - 4) / 2 / 360;
  }

  @override
  void didUpdateWidget(MagnetBahan lama) {
    super.didUpdateWidget(lama);
    if (widget.dipilih && !lama.dipilih) {
      if (MediaQuery.disableAnimationsOf(context)) {
        _hentak.value = 1;
      } else {
        _hentak.forward(from: 0);
      }
    }
  }

  @override
  void dispose() {
    _hentak.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palet;
    final teks = Theme.of(context).textTheme;
    final bahan = widget.bahan;
    final dipilih = widget.dipilih;
    final warnaMagnet = AppColors.magnet(bahan.kategori);
    final radius = BorderRadius.circular(AppSpacing.radiusPill);
    return Semantics(
      button: true,
      selected: dipilih,
      label: bahan.nama,
      value: dipilih && widget.segera ? 'Segera habiskan' : null,
      hint: dipilih
          ? 'Ketuk untuk melepas dari kulkas'
          : 'Ketuk untuk menempel ke kulkas',
      onLongPressHint: widget.onTekanLama == null ? null : 'Opsi kesegaran',
      child: ScaleTransition(
        scale: _skalaHentak.animate(_hentak),
        child: AnimatedRotation(
          turns: dipilih ? _miring : 0,
          duration: AppGerak.sedang,
          curve: Curves.easeOutBack,
          child: AnimatedContainer(
            duration: AppGerak.sedang,
            decoration: BoxDecoration(
              color: dipilih ? warnaMagnet : p.permukaanTinggi,
              borderRadius: radius,
              border: Border.all(
                color: dipilih ? p.diMagnet : warnaMagnet,
                width: dipilih ? 1.6 : 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: dipilih ? p.bayanganTegas : p.bayangan,
                  blurRadius: dipilih ? 8 : 4,
                  offset: Offset(0, dipilih ? 3 : 2),
                ),
              ],
            ),
            child: Material(
              color: AppColors.transparan,
              child: InkWell(
                borderRadius: radius,
                onTap: () {
                  if (dipilih) {
                    HapticFeedback.selectionClick();
                  } else {
                    HapticFeedback.mediumImpact();
                  }
                  widget.onTap();
                },
                onLongPress: widget.onTekanLama == null
                    ? null
                    : () {
                        HapticFeedback.heavyImpact();
                        widget.onTekanLama!();
                      },
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minHeight: AppSpacing.sentuh,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.s,
                      AppSpacing.xs,
                      AppSpacing.m,
                      AppSpacing.xs,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IkonBahan.dari(bahan),
                        const SizedBox(width: AppSpacing.s),
                        Flexible(
                          child: Text(
                            bahan.nama,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: teks.labelLarge?.copyWith(
                              color: dipilih ? p.diMagnet : p.tinta,
                            ),
                          ),
                        ),
                        AnimatedSize(
                          duration: AppGerak.sedang,
                          curve: Curves.easeOut,
                          child: dipilih
                              ? Padding(
                                  padding: const EdgeInsets.only(
                                    left: AppSpacing.s,
                                  ),
                                  child: _Lencana(segera: widget.segera),
                                )
                              : const SizedBox.shrink(),
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
    );
  }
}

/// Lencana di ujung magnet terpilih: ✓ hijau, atau jam pasir kuning bila
/// bahan perlu segera dihabiskan. Warnanya tetap (di atas magnet pastel
/// yang sama di kedua tema).
class _Lencana extends StatelessWidget {
  final bool segera;

  const _Lencana({required this.segera});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      key: Key(segera ? 'lencana-segera' : 'lencana-ada'),
      duration: AppGerak.sedang,
      width: 20,
      height: 20,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: segera ? AppColors.pisangLembut : AppColors.aksenTua,
        shape: BoxShape.circle,
        border: segera
            ? Border.all(color: AppColors.pisangTeks, width: 1.2)
            : null,
      ),
      child: Icon(
        segera ? Icons.hourglass_bottom : Icons.check,
        size: 13,
        color: segera ? AppColors.pisangTeks : AppColors.putih,
      ),
    );
  }
}
