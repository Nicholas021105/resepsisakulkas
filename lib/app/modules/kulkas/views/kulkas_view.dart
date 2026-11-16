import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../controllers/main_controller.dart';
import '../../../data/models/bahan_model.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_palet.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_text.dart';
import '../../../utils/notifikasi.dart';
import '../../../widgets/bottom_nav.dart';
import '../../../widgets/ikon_bahan.dart';
import '../../../widgets/kerangka.dart';
import '../../../widgets/kulkas_widgets.dart';
import '../../../widgets/magnet_bahan.dart';
import '../../../widgets/umum_widgets.dart';
import '../../resep/controllers/resep_controller.dart';
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

/// Kulkas kosong: ilustrasi + ajakan. Terisi: jumlah bahan + Kosongkan,
/// lalu banner bahan yang segera habis (atau petunjuk tekan lama).
class _Ringkasan extends GetView<KulkasController> {
  const _Ringkasan();

  @override
  Widget build(BuildContext context) {
    final teks = Theme.of(context).textTheme;
    final p = context.palet;
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
                      style: teks.bodyMedium?.copyWith(color: p.tintaLembut),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }
      final terpilih = controller.bahanTerpilih;
      final segera = controller.daftarSegera;
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
                    duration: AppGerak.cepat,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PratinjauKulkas(bahan: terpilih),
                  const SizedBox(height: AppSpacing.m),
                  AnimatedSize(
                    duration: AppGerak.sedang,
                    curve: Curves.easeOut,
                    alignment: Alignment.topCenter,
                    child: segera.isEmpty
                        ? Row(
                            key: const Key('petunjuk-tekan-lama'),
                            children: [
                              Icon(
                                Icons.touch_app_outlined,
                                size: 16,
                                color: p.tintaLembut,
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Expanded(
                                child: Text(
                                  'Tekan lama magnet untuk menandai bahan '
                                  'yang harus segera dihabiskan.',
                                  style: teks.bodySmall,
                                ),
                              ),
                            ],
                          )
                        : _BannerSegera(bahan: segera),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

/// Banner kuning "n bahan segera habiskan" → membuka resep yang memakainya.
class _BannerSegera extends StatelessWidget {
  final List<Bahan> bahan;

  const _BannerSegera({required this.bahan});

  @override
  Widget build(BuildContext context) {
    final p = context.palet;
    final teks = Theme.of(context).textTheme;
    final radius = BorderRadius.circular(AppSpacing.radiusM);
    return Material(
      color: p.pisangLembut,
      borderRadius: radius,
      child: InkWell(
        key: const Key('banner-segera'),
        borderRadius: radius,
        onTap: () {
          HapticFeedback.lightImpact();
          // Resep yang memakai bahan ini ada di urutan teratas "Semua".
          Get.find<ResepController>().tampilkanPenyelamat();
          Get.find<MainController>().pindahTab(MainController.tabResep);
        },
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AppSpacing.sentuh),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.m,
              vertical: AppSpacing.s,
            ),
            child: Row(
              children: [
                Icon(Icons.hourglass_bottom, color: p.pisangTeks),
                const SizedBox(width: AppSpacing.s),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${bahan.length} bahan segera habiskan',
                        style: teks.titleSmall?.copyWith(color: p.pisangTeks),
                      ),
                      Text(
                        '${bahan.map((b) => b.nama).join(', ')} · '
                        'lihat resepnya',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: teks.bodySmall?.copyWith(color: p.pisangTeks),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: p.pisangTeks),
              ],
            ),
          ),
        ),
      ),
    );
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
                      ?.copyWith(color: context.palet.tintaLembut),
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
    final p = context.palet;
    return Obx(() {
      if (!controller.katalogSiap) return const KerangkaMagnet();
      final kelompok = controller.bahanPerKategori;
      // Dibaca di dalam Obx agar status magnet ikut diperbarui.
      final dimiliki = controller.bahanDimiliki.toSet();
      final segera = controller.bahanSegera;
      if (kelompok.isEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
          child: Text(
            'Bahan tidak ditemukan. Coba kata lain.',
            textAlign: TextAlign.center,
            style: teks.bodyMedium?.copyWith(color: p.tintaLembut),
          ),
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final MapEntry(key: kategori, value: daftar)
              in kelompok.entries) ...[
            Semantics(
              header: true,
              child: Padding(
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
                    segera: segera.contains(b.id),
                    onTap: () => controller.toggle(b.id),
                    onTekanLama: dimiliki.contains(b.id)
                        ? () => bukaLembar<void>(LembarOpsiBahan(bahan: b))
                        : null,
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

/// Lembar opsi satu bahan di kulkas (tekan lama magnet): kesegaran, tandai
/// segera habiskan / masih segar, dan lepas.
class LembarOpsiBahan extends GetView<KulkasController> {
  final Bahan bahan;

  const LembarOpsiBahan({super.key, required this.bahan});

  @override
  Widget build(BuildContext context) {
    final teks = Theme.of(context).textTheme;
    final p = context.palet;
    return Obx(() {
      final ditandai = controller.ditandaiSegera.contains(bahan.id);
      final segera = controller.bahanSegera.contains(bahan.id);
      return Column(
        key: const Key('lembar-opsi-bahan'),
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: AppSpacing.tombol,
                height: AppSpacing.tombol,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.magnet(bahan.kategori),
                  shape: BoxShape.circle,
                ),
                child: IkonBahan.dari(bahan, ukuran: 32),
              ),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(bahan.nama, style: teks.titleLarge),
                    Text(
                      controller.keterangan(bahan),
                      key: const Key('keterangan-kesegaran'),
                      style: teks.bodyMedium?.copyWith(
                        color: segera ? p.pisangTeks : p.tintaLembut,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.l),
          if (!ditandai)
            AksiLembar(
              key: const Key('opsi-segera'),
              ikon: Icons.hourglass_bottom,
              judul: 'Tandai segera habiskan',
              keterangan: 'Resep yang memakainya naik ke urutan atas.',
              latarIkon: p.pisangLembut,
              warnaIkon: p.pisangTeks,
              onTap: () {
                controller.toggleSegera(bahan.id);
                tutupOverlay();
              },
            ),
          if (segera)
            AksiLembar(
              key: const Key('opsi-segar'),
              ikon: Icons.eco_outlined,
              judul: 'Masih segar',
              keterangan: ditandai
                  ? 'Hapus tanda segera habiskan.'
                  : 'Hitung ulang kesegarannya mulai hari ini.',
              latarIkon: p.aksenLembut,
              warnaIkon: p.aksenTua,
              onTap: () {
                controller.tandaiSegar(bahan.id);
                tutupOverlay();
              },
            ),
          AksiLembar(
            key: const Key('opsi-lepas'),
            ikon: Icons.remove_circle_outline,
            judul: 'Lepas dari kulkas',
            keterangan: 'Bahan ini sudah habis atau tidak ada lagi.',
            latarIkon: p.bahayaLembut,
            warnaIkon: p.bahaya,
            onTap: () {
              controller.lepas(bahan.id);
              tutupOverlay();
            },
          ),
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
      final p = context.palet;
      final gaya = Theme.of(context).textTheme.labelLarge
          ?.copyWith(color: p.diAksen);
      return SizedBox(
        width: double.infinity,
        child: FilledButton(
          key: const Key('lihat-resep'),
          onPressed: kosong
              ? null
              : () {
                  HapticFeedback.lightImpact();
                  Get.find<MainController>().pindahTab(MainController.tabResep);
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
                        duration: AppGerak.sedang,
                        transitionBuilder: (anak, animasi) => ScaleTransition(
                          scale: animasi,
                          child: FadeTransition(opacity: animasi, child: anak),
                        ),
                        child: Text(
                          '$jumlah',
                          key: ValueKey(jumlah),
                          style: AppText.angka(18, warna: p.diAksen),
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
