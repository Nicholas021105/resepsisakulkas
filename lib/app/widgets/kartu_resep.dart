import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/models/bahan_model.dart';
import '../data/models/hasil_cocok.dart';
import '../data/services/katalog_service.dart';
import '../routes/app_routes.dart';
import '../theme/app_palet.dart';
import '../theme/app_spacing.dart';
import 'ikon_bahan.dart';
import 'kulkas_widgets.dart';

/// Kartu resep: strip status di kiri, cincin persentase, nama, info singkat,
/// pratinjau bahan, dan chip bahan yang kurang.
class KartuResep extends StatelessWidget {
  final HasilCocok hasil;

  const KartuResep({super.key, required this.hasil});

  static const lebarStrip = 4.0;

  @override
  Widget build(BuildContext context) {
    final teks = Theme.of(context).textTheme;
    final r = hasil.resep;
    final byId = Get.find<KatalogService>().katalog.value?.bahanById ?? {};
    final namaKurang = [for (final id in hasil.kurang) byId[id]?.nama ?? id];
    final radius = BorderRadius.circular(AppSpacing.radiusM);
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.m),
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: context.palet.bayanganKartu,
      ),
      child: Material(
        color: context.palet.permukaan,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(color: context.palet.garis, width: 0.6),
        ),
        child: InkWell(
          key: Key('resep-${r.id}'),
          onTap: () => Get.toNamed(Routes.keDetail(r.id)),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.l + lebarStrip,
                  AppSpacing.l,
                  AppSpacing.l,
                  AppSpacing.l,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CincinPersen(persen: hasil.persen),
                    const SizedBox(width: AppSpacing.m + 2),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r.nama,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: teks.titleLarge,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${r.waktuMenit} menit · ${r.porsi} porsi · '
                            '${r.tingkat.label}',
                            style: teks.bodySmall,
                          ),
                          const SizedBox(height: AppSpacing.s),
                          _PratinjauBahan(hasil: hasil, byId: byId),
                          const SizedBox(height: AppSpacing.s),
                          hasil.siapDimasak
                              ? const ChipStatus(
                                  teks: '✓ Semua bahan ada',
                                  kurang: false,
                                )
                              : ChipStatus(
                                  teks: 'kurang: ${namaKurang.join(', ')}',
                                  kurang: true,
                                ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Strip status: hijau 100%, kuning 50–99%, abu < 50%.
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: lebarStrip,
                child: ColoredBox(color: context.palet.cincin(hasil.persen)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Chip kecil status bahan: mint ("Semua bahan ada") atau wortel ("kurang").
class ChipStatus extends StatelessWidget {
  final String teks;
  final bool kurang;

  const ChipStatus({super.key, required this.teks, required this.kurang});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s + 2,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: kurang ? context.palet.wortelLembut : context.palet.aksenLembut,
        borderRadius: BorderRadius.circular(AppSpacing.radiusS),
      ),
      child: Text(
        teks,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: kurang ? context.palet.wortelTeks : context.palet.aksenTua,
        ),
      ),
    );
  }
}

/// Maksimal 5 ikon bahan wajib (bumbu dasar di belakang). Bahan yang kurang
/// diberi lingkaran wortel tipis; sisanya ditampilkan sebagai "+n".
class _PratinjauBahan extends StatelessWidget {
  final HasilCocok hasil;
  final Map<String, Bahan> byId;

  const _PratinjauBahan({required this.hasil, required this.byId});

  static const maks = 5;
  static const ukuranIkon = 20.0;
  static const ukuranSlot = 26.0;

  @override
  Widget build(BuildContext context) {
    final wajib = [
      for (final b in hasil.resep.bahan)
        if (!b.opsional && byId[b.bahanId] != null) byId[b.bahanId]!,
    ];
    // Bahan utama dulu, bumbu dasar (garam, minyak, …) paling belakang.
    final urut = [
      ...wajib.where((b) => !b.bumbuDasar),
      ...wajib.where((b) => b.bumbuDasar),
    ];
    final tampil = urut.take(maks).toList();
    final sisa = urut.length - tampil.length;
    final kurang = hasil.kurang.toSet();
    return Wrap(
      key: Key('pratinjau-${hasil.resep.id}'),
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final b in tampil)
          Container(
            key: Key('pratinjau-${hasil.resep.id}-${b.id}'),
            width: ukuranSlot,
            height: ukuranSlot,
            alignment: Alignment.center,
            decoration: kurang.contains(b.id)
                ? BoxDecoration(
                    color: context.palet.wortelLembut,
                    shape: BoxShape.circle,
                    border: Border.all(color: context.palet.wortel, width: 1.2),
                  )
                : null,
            child: IkonBahan.dari(b, ukuran: ukuranIkon),
          ),
        if (sisa > 0)
          Text(
            '+$sisa',
            style: Theme.of(context).textTheme.labelMedium
                ?.copyWith(color: context.palet.tintaLembut),
          ),
      ],
    );
  }
}
