import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../controllers/main_controller.dart';
import '../../../data/models/bahan_model.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/bottom_nav.dart';
import '../../../widgets/ikon_bahan.dart';
import '../../../widgets/kulkas_widgets.dart';
import '../../../widgets/magnet_bahan.dart';
import '../controllers/kulkas_controller.dart';

class KulkasView extends GetView<KulkasController> {
  const KulkasView({super.key});

  @override
  Widget build(BuildContext context) {
    final isi = <Widget>[
      const SliverToBoxAdapter(child: _Ringkasan()),
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.l,
          AppSpacing.l,
          AppSpacing.l,
          AppSpacing.s,
        ),
        sliver: SliverToBoxAdapter(
          child: TextField(
            key: const Key('cari-bahan'),
            onChanged: (teks) => controller.keyword.value = teks,
            textInputAction: TextInputAction.search,
            decoration: const InputDecoration(
              hintText: 'Cari bahan, mis. telur',
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),
      ),
      const SliverToBoxAdapter(child: _FilterKategori()),
      const SliverPadding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.l,
          AppSpacing.s,
          AppSpacing.l,
          // Ruang untuk fade bawah agar magnet terakhir tidak tertutup.
          AppSpacing.xl + AppSpacing.l,
        ),
        sliver: SliverToBoxAdapter(child: PintuKulkas(child: _DaftarBahan())),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kulkasku'),
        actions: const [
          TombolPengaturan(),
          SizedBox(width: AppSpacing.xs),
        ],
      ),
      bottomNavigationBar: const BottomNav(),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, batas) {
            // Ruang sempit (landscape + keyboard): tombol ikut digulir.
            if (batas.maxHeight < 220) {
              return CustomScrollView(
                slivers: [
                  ...isi,
                  const SliverPadding(
                    padding: EdgeInsets.all(AppSpacing.l),
                    sliver: SliverToBoxAdapter(child: _TombolLihatResep()),
                  ),
                ],
              );
            }
            return Column(
              children: [
                Expanded(
                  child: FadeTepi(
                    arah: Axis.vertical,
                    child: CustomScrollView(slivers: isi),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.l,
                    AppSpacing.s,
                    AppSpacing.l,
                    AppSpacing.m,
                  ),
                  child: _TombolLihatResep(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Kulkas kosong: ilustrasi + ajakan. Terisi: jumlah bahan + Kosongkan.
class _Ringkasan extends GetView<KulkasController> {
  const _Ringkasan();

  @override
  Widget build(BuildContext context) {
    final teks = Theme.of(context).textTheme;
    return Obx(() {
      if (controller.kulkasKosong) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.l,
            AppSpacing.s,
            AppSpacing.l,
            0,
          ),
          child: Row(
            children: [
              const IlustrasiKulkasKosong(ukuran: 112),
              const SizedBox(width: AppSpacing.l),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Kulkasmu masih kosong', style: teks.titleLarge),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Tempel bahan pertamamu dengan mengetuk magnet di '
                      'bawah.',
                      style: teks.bodyMedium?.copyWith(
                        color: AppColors.tintaLembut,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }
      final terpilih = controller.bahanTerpilih;
      return Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.l,
          AppSpacing.s,
          AppSpacing.s,
          0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Judul sebaris dengan tombol "Kosongkan".
            Row(
              children: [
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    layoutBuilder: (anak, sebelumnya) => Stack(
                      alignment: Alignment.centerLeft,
                      children: [...sebelumnya, ?anak],
                    ),
                    child: Text(
                      '${terpilih.length} bahan di kulkas',
                      key: ValueKey(terpilih.length),
                      style: teks.titleLarge,
                    ),
                  ),
                ),
                TextButton(
                  key: const Key('kosongkan-kulkas'),
                  onPressed: controller.konfirmasiKosongkan,
                  child: const Text('Kosongkan'),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.s),
              child: _PratinjauKulkas(bahan: terpilih),
            ),
          ],
        ),
      );
    });
  }
}

/// Satu baris ikon bahan di kulkas; yang tidak muat diringkas jadi "+n".
class _PratinjauKulkas extends StatelessWidget {
  final List<Bahan> bahan;

  const _PratinjauKulkas({required this.bahan});

  static const ukuran = 24.0;
  static const jarak = AppSpacing.xs + 2;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, batas) {
        // Sisakan ruang untuk label "+n" bila tidak semua muat.
        final muat = ((batas.maxWidth + jarak) / (ukuran + jarak)).floor();
        final tampil = bahan.length <= muat
            ? bahan.length
            : (muat - 2).clamp(0, bahan.length);
        final sisa = bahan.length - tampil;
        return Row(
          key: const Key('pratinjau-kulkas'),
          children: [
            for (var i = 0; i < tampil; i++) ...[
              if (i > 0) const SizedBox(width: jarak),
              IkonBahan.dari(bahan[i], ukuran: ukuran),
            ],
            if (sisa > 0) ...[
              const SizedBox(width: jarak),
              Flexible(
                child: Text(
                  '+$sisa',
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  style: Theme.of(context).textTheme.labelMedium
                      ?.copyWith(color: AppColors.tintaLembut),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _FilterKategori extends GetView<KulkasController> {
  const _FilterKategori();

  @override
  Widget build(BuildContext context) {
    final pilihan = [
      ('', 'Semua'),
      for (final k in KategoriBahan.values) (k.name, k.label),
    ];
    return SizedBox(
      height: 56,
      child: Obx(() {
        final aktif = controller.kategoriAktif.value;
        return FadeTepi(
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
            itemCount: pilihan.length,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.s),
            itemBuilder: (_, i) => Center(
              child: ChoiceChip(
                label: Text(pilihan[i].$2),
                selected: aktif == pilihan[i].$1,
                onSelected: (_) => controller.pilihKategori(pilihan[i].$1),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _DaftarBahan extends GetView<KulkasController> {
  const _DaftarBahan();

  @override
  Widget build(BuildContext context) {
    final teks = Theme.of(context).textTheme;
    return Obx(() {
      if (!controller.katalogSiap) {
        return const Padding(
          padding: EdgeInsets.all(AppSpacing.xxl),
          child: Center(child: CircularProgressIndicator()),
        );
      }
      final kelompok = controller.bahanPerKategori;
      // Dibaca di dalam Obx agar status magnet ikut diperbarui.
      final dimiliki = controller.bahanDimiliki.toSet();
      if (kelompok.isEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
          child: Text(
            'Bahan tidak ditemukan. Coba kata lain.',
            textAlign: TextAlign.center,
            style: teks.bodyMedium?.copyWith(color: AppColors.tintaLembut),
          ),
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final MapEntry(key: kategori, value: daftar)
              in kelompok.entries) ...[
            Padding(
              padding: const EdgeInsets.only(
                top: AppSpacing.s,
                bottom: AppSpacing.m,
              ),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppColors.magnet(kategori),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s),
                  Text(kategori.label.toUpperCase(), style: teks.labelSmall),
                ],
              ),
            ),
            Wrap(
              spacing: AppSpacing.m,
              runSpacing: AppSpacing.m,
              children: [
                for (final b in daftar)
                  MagnetBahan(
                    key: Key('magnet-${b.id}'),
                    bahan: b,
                    dipilih: dimiliki.contains(b.id),
                    onTap: () => controller.toggle(b.id),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.l),
          ],
        ],
      );
    });
  }
}

/// Pill lebar "Lihat n resep cocok" dengan angka beranimasi.
class _TombolLihatResep extends GetView<KulkasController> {
  const _TombolLihatResep();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final kosong = controller.kulkasKosong;
      final jumlah = controller.jumlahResepCocok;
      final gaya = Theme.of(context).textTheme.labelLarge
          ?.copyWith(color: AppColors.putih);
      return SizedBox(
        width: double.infinity,
        child: FilledButton(
          key: const Key('lihat-resep'),
          onPressed: kosong
              ? null
              : () {
                  HapticFeedback.lightImpact();
                  Get.find<MainController>().pindahTab(1);
                },
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: kosong
                ? const Text('Tempel bahan dulu')
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Lihat ', style: gaya),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        transitionBuilder: (anak, animasi) => ScaleTransition(
                          scale: animasi,
                          child: FadeTransition(opacity: animasi, child: anak),
                        ),
                        child: Text(
                          '$jumlah',
                          key: ValueKey(jumlah),
                          style: AppText.angka(18, warna: AppColors.putih),
                        ),
                      ),
                      Text(' resep cocok', style: gaya),
                      const SizedBox(width: AppSpacing.s),
                      const Icon(Icons.arrow_forward, size: 20),
                    ],
                  ),
          ),
        ),
      );
    });
  }
}
