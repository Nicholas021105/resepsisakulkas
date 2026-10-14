import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/models/bahan_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'ikon_bahan.dart';

/// Bahan sebagai "magnet kulkas": chip lonjong berwarna kategori dengan
/// ikon bahan. Saat dipilih magnet "menempel": sedikit membesar, bayangan
/// lebih tegas, dan muncul tanda ✓ kecil di dalam chip (tidak menumpuk
/// chip tetangga).
class MagnetBahan extends StatelessWidget {
  final Bahan bahan;
  final bool dipilih;
  final VoidCallback onTap;

  const MagnetBahan({
    super.key,
    required this.bahan,
    required this.dipilih,
    required this.onTap,
  });

  static const _durasi = Duration(milliseconds: 200);

  @override
  Widget build(BuildContext context) {
    final teks = Theme.of(context).textTheme;
    return Semantics(
      button: true,
      selected: dipilih,
      label: bahan.nama,
      child: AnimatedScale(
        scale: dipilih ? 1.03 : 1,
        duration: _durasi,
        curve: Curves.easeOutBack,
        child: AnimatedContainer(
          duration: _durasi,
          decoration: BoxDecoration(
            color: dipilih
                ? AppColors.magnet(bahan.kategori)
                : AppColors.permukaan,
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            border: Border.all(
              color: dipilih
                  ? AppColors.tinta
                  : AppColors.magnet(bahan.kategori),
              width: dipilih ? 1.6 : 2,
            ),
            boxShadow: [
              BoxShadow(
                color: dipilih ? AppColors.bayanganTegas : AppColors.bayangan,
                blurRadius: dipilih ? 8 : 4,
                offset: Offset(0, dipilih ? 3 : 2),
              ),
            ],
          ),
          child: Material(
            color: AppColors.transparan,
            child: InkWell(
              borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
              onTap: () {
                HapticFeedback.lightImpact();
                onTap();
              },
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: AppSpacing.sentuh),
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
                          style: teks.labelLarge,
                        ),
                      ),
                      AnimatedSize(
                        duration: _durasi,
                        curve: Curves.easeOut,
                        child: dipilih
                            ? const Padding(
                                padding: EdgeInsets.only(left: AppSpacing.s),
                                child: CircleAvatar(
                                  radius: 9,
                                  backgroundColor: AppColors.aksenTua,
                                  child: Icon(
                                    Icons.check,
                                    size: 13,
                                    color: AppColors.putih,
                                  ),
                                ),
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
    );
  }
}
