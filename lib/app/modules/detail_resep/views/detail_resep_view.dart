import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../data/models/bahan_model.dart';
import '../../../data/models/hasil_cocok.dart';
import '../../../data/models/resep_model.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/bottom_nav.dart';
import '../../../widgets/ikon_bahan.dart';
import '../../../widgets/kulkas_widgets.dart';
import '../controllers/detail_resep_controller.dart';

class DetailResepView extends GetView<DetailResepController> {
  const DetailResepView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final hasil = controller.hasil.value;
      if (!controller.katalogSiap) {
        return Scaffold(
          appBar: AppBar(leading: const TombolKembali()),
          body: const Center(child: CircularProgressIndicator()),
        );
      }
      if (hasil == null) return const _TidakDitemukan();
      final favorit = controller.favorit;
      return Scaffold(
        appBar: AppBar(
          leading: const TombolKembali(),
          actions: [
            IconButton(
              key: const Key('toggle-favorit'),
              tooltip: favorit ? 'Hapus dari favorit' : 'Simpan ke favorit',
              onPressed: () {
                HapticFeedback.lightImpact();
                controller.toggleFavorit();
              },
              // Key berganti saat status berubah → animasi "pop"
              // 1 → 1,25 → 1 diputar ulang.
              icon: TweenAnimationBuilder<double>(
                key: ValueKey(favorit),
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeOut,
                builder: (_, t, anak) =>
                    Transform.scale(scale: 1 + 0.25 * sin(pi * t), child: anak),
                child: Icon(
                  favorit ? Icons.favorite : Icons.favorite_border,
                  color: favorit ? AppColors.hatiKoral : AppColors.tinta,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
          ],
        ),
        body: SafeArea(child: _Isi(hasil: hasil)),
      );
    });
  }
}

class _Isi extends GetView<DetailResepController> {
  final HasilCocok hasil;

  const _Isi({required this.hasil});

  @override
  Widget build(BuildContext context) {
    final teks = Theme.of(context).textTheme;
    final r = hasil.resep;
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.l,
        0,
        AppSpacing.l,
        AppSpacing.xxl,
      ),
      children: [
        _PanelHeader(hasil: hasil),
        const SizedBox(height: AppSpacing.l),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(r.nama, style: teks.headlineMedium),
              const SizedBox(height: AppSpacing.xs),
              Text(
                r.deskripsi,
                style: teks.bodyMedium?.copyWith(color: AppColors.tintaLembut),
              ),
              const SizedBox(height: AppSpacing.l),
              Wrap(
                spacing: AppSpacing.s,
                runSpacing: AppSpacing.s,
                children: [
                  _Info(
                    ikon: Icons.timer_outlined,
                    teks: '${r.waktuMenit} menit',
                  ),
                  _Info(ikon: Icons.people_outline, teks: '${r.porsi} porsi'),
                  _Info(ikon: Icons.signal_cellular_alt, teks: r.tingkat.label),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                children: [
                  Expanded(child: Text('Bahan', style: teks.titleLarge)),
                  Text(
                    hasil.siapDimasak
                        ? 'Semua ada ✓'
                        : 'Kurang ${hasil.kurang.length}',
                    style: teks.labelLarge?.copyWith(
                      color: hasil.siapDimasak
                          ? AppColors.aksenTua
                          : AppColors.wortelTeks,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.s),
        _KartuBahan(bahan: r.bahan),
        const SizedBox(height: AppSpacing.xl),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          child: Text('Langkah', style: teks.titleLarge),
        ),
        const SizedBox(height: AppSpacing.m),
        for (var i = 0; i < r.langkah.length; i++)
          _BarisLangkah(
            nomor: i + 1,
            teks: r.langkah[i],
            terakhir: i == r.langkah.length - 1,
          ),
      ],
    );
  }
}

/// Panel mint pucat: ikon bahan utama (maks 4) sebagai "magnet" + cincin
/// persentase, supaya halaman tidak hanya teks.
class _PanelHeader extends GetView<DetailResepController> {
  final HasilCocok hasil;

  const _PanelHeader({required this.hasil});

  static const maks = 4;

  @override
  Widget build(BuildContext context) {
    final byId = controller.bahanById;
    final utama = <Bahan>[
      for (final b in hasil.resep.bahan)
        if (!b.opsional && !(byId[b.bahanId]?.bumbuDasar ?? true))
          byId[b.bahanId]!,
    ].take(maks);
    return Container(
      key: const Key('detail-header'),
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: AppColors.mintPucat,
        borderRadius: BorderRadius.circular(AppSpacing.radiusL),
      ),
      child: Row(
        children: [
          Expanded(
            child: Wrap(
              spacing: AppSpacing.s,
              runSpacing: AppSpacing.s,
              children: [
                for (final b in utama)
                  Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.permukaan,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.magnet(b.kategori),
                        width: 2,
                      ),
                      boxShadow: bayanganKartu,
                    ),
                    child: IkonBahan.dari(b, ukuran: 32),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.m),
          CincinPersen(persen: hasil.persen, ukuran: 68),
        ],
      ),
    );
  }
}

class _Info extends StatelessWidget {
  final IconData ikon;
  final String teks;

  const _Info({required this.ikon, required this.teks});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.m,
        vertical: AppSpacing.s,
      ),
      decoration: BoxDecoration(
        color: AppColors.permukaan,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        border: Border.all(color: AppColors.garis),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(ikon, size: 16, color: AppColors.tintaLembut),
          const SizedBox(width: AppSpacing.xs),
          Text(teks, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}

/// Semua bahan dalam satu kartu putih dengan pemisah tipis antar baris.
class _KartuBahan extends StatelessWidget {
  final List<BahanResep> bahan;

  const _KartuBahan({required this.bahan});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('kartu-bahan'),
      decoration: BoxDecoration(
        color: AppColors.permukaan,
        borderRadius: BorderRadius.circular(AppSpacing.radiusM),
        border: Border.all(color: AppColors.garis),
        boxShadow: bayanganKartu,
      ),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, batas) {
          // Kolom takaran selebar tetap agar semua baris sejajar.
          final lebarTakaran = batas.maxWidth * 0.38;
          return Column(
            children: [
              for (var i = 0; i < bahan.length; i++) ...[
                if (i > 0) const Divider(height: 1, thickness: 1),
                _BarisBahan(bahan: bahan[i], lebarTakaran: lebarTakaran),
              ],
            ],
          );
        },
      ),
    );
  }
}

/// Bahan dimiliki: ✓ hijau. Kurang: wortel dengan latar tipis.
class _BarisBahan extends GetView<DetailResepController> {
  final BahanResep bahan;
  final double lebarTakaran;

  const _BarisBahan({required this.bahan, required this.lebarTakaran});

  @override
  Widget build(BuildContext context) {
    final teks = Theme.of(context).textTheme;
    final data = controller.bahanById[bahan.bahanId];
    final ada = controller.dimiliki(bahan.bahanId);
    final kurang = !ada && !bahan.opsional;
    return Container(
      key: Key('bahan-${bahan.bahanId}'),
      color: kurang ? AppColors.wortelLembut : AppColors.permukaan,
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            ada ? Icons.check_circle : Icons.remove_circle_outline,
            size: 22,
            color: ada
                ? AppColors.aksen
                : (kurang ? AppColors.wortelTeks : AppColors.tintaLembut),
          ),
          const SizedBox(width: AppSpacing.s),
          data != null
              ? IkonBahan.dari(data, ukuran: 22)
              : const SizedBox.square(dimension: 22),
          const SizedBox(width: AppSpacing.s),
          Expanded(
            child: Wrap(
              spacing: AppSpacing.xs + 2,
              runSpacing: AppSpacing.xs,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(data?.nama ?? bahan.bahanId, style: teks.titleSmall),
                if (bahan.opsional) const _ChipLabel('opsional', kurang: false),
                if (kurang) const _ChipLabel('kurang', kurang: true),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.s),
          SizedBox(
            key: Key('takaran-${bahan.bahanId}'),
            width: lebarTakaran,
            // Sejajarkan baseline dengan nama bahan (titleSmall lebih tinggi).
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(bahan.takaran, style: teks.bodySmall),
            ),
          ),
        ],
      ),
    );
  }
}

/// Label kecil "opsional" / "kurang" dengan gaya yang sama.
class _ChipLabel extends StatelessWidget {
  final String teks;
  final bool kurang;

  const _ChipLabel(this.teks, {required this.kurang});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s - 2),
      decoration: BoxDecoration(
        color: AppColors.permukaan,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        border: Border.all(color: kurang ? AppColors.wortel : AppColors.garis),
      ),
      child: Text(
        teks,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          letterSpacing: 0,
          color: kurang ? AppColors.wortelTeks : AppColors.tintaLembut,
        ),
      ),
    );
  }
}

/// Langkah memasak: nomor dalam lingkaran mint pucat, dihubungkan garis
/// vertikal tipis ke langkah berikutnya.
class _BarisLangkah extends StatelessWidget {
  final int nomor;
  final String teks;
  final bool terakhir;

  const _BarisLangkah({
    required this.nomor,
    required this.teks,
    required this.terakhir,
  });

  static const diameter = 36.0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: diameter + AppSpacing.m,
            bottom: terakhir ? 0 : AppSpacing.l,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: diameter),
            child: Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              child: Text(teks, style: Theme.of(context).textTheme.bodyLarge),
            ),
          ),
        ),
        if (!terakhir)
          const Positioned(
            left: diameter / 2 - 1,
            top: diameter + 2,
            bottom: 2,
            width: 2,
            child: ColoredBox(color: AppColors.garis),
          ),
        Positioned(
          left: 0,
          top: 0,
          width: diameter,
          height: diameter,
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(AppSpacing.xs + 2),
            decoration: const BoxDecoration(
              color: AppColors.mintPucat,
              shape: BoxShape.circle,
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '$nomor',
                style: AppText.angka(18, warna: AppColors.aksenTua),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TidakDitemukan extends GetView<DetailResepController> {
  const _TidakDitemukan();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: const TombolKembali()),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: KeadaanKosong(
              key: const Key('resep-tidak-ditemukan'),
              ilustrasi: const EmojiBesar('🔍'),
              judul: 'Resep tidak ditemukan',
              pesan:
                  'Resep ini mungkin sudah dihapus atau tautannya salah. '
                  'Kembali untuk memilih resep lain.',
              labelAksi: 'Kembali',
              onAksi: controller.kembali,
              kunciAksi: const Key('kembali'),
            ),
          ),
        ),
      ),
    );
  }
}
