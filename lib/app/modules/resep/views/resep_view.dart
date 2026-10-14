import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/main_controller.dart';
import '../../../data/models/hasil_cocok.dart';
import '../../../data/services/katalog_service.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import '../../../utils/formatter.dart';
import '../../../widgets/bottom_nav.dart';
import '../../../widgets/kartu_resep.dart';
import '../../../widgets/kulkas_widgets.dart';
import '../controllers/resep_controller.dart';

class ResepView extends GetView<ResepController> {
  const ResepView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resep'),
        actions: const [
          TombolPengaturan(),
          SizedBox(width: AppSpacing.xs),
        ],
      ),
      bottomNavigationBar: const BottomNav(),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(child: _Kepala()),
            controller.obx(
              (data) => SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.l,
                  AppSpacing.s,
                  AppSpacing.l,
                  AppSpacing.xl,
                ),
                sliver: SliverList.builder(
                  itemCount: data!.length,
                  itemBuilder: (_, i) => KartuResep(hasil: data[i]),
                ),
              ),
              onLoading: const SliverFillRemaining(
                hasScrollBody: false,
                child: _MemuatResep(),
              ),
              onEmpty: const SliverFillRemaining(
                hasScrollBody: false,
                child: _KosongResep(),
              ),
              onError: (pesan) => SliverFillRemaining(
                hasScrollBody: false,
                child: _GagalMuat(
                  pesan: pesan ?? 'Terjadi kesalahan.',
                  onCobaLagi: controller.cobaLagi,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Label sumber data + chip filter. Disembunyikan saat status error agar
/// pesan galat tidak didahului chip "(0)" yang menyesatkan.
class _Kepala extends GetView<ResepController> {
  const _Kepala();

  @override
  Widget build(BuildContext context) {
    final katalog = Get.find<KatalogService>();
    final teks = Theme.of(context).textTheme;
    return Obx(() {
      if (controller.gagalMuat) return const SizedBox.shrink();
      final sumber = katalog.sumber.value;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.l,
              0,
              AppSpacing.l,
              AppSpacing.s,
            ),
            child: Row(
              children: [
                Icon(
                  ikonSumber(sumber),
                  key: Key('ikon-sumber-${sumber.name}'),
                  size: 16,
                  color: AppColors.tintaLembut,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    labelSumber(sumber, katalog.diperbarui.value),
                    key: const Key('label-sumber'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: teks.bodySmall,
                  ),
                ),
              ],
            ),
          ),
          const _FilterHasil(),
          const SizedBox(height: AppSpacing.xs),
        ],
      );
    });
  }
}

class _FilterHasil extends GetView<ResepController> {
  const _FilterHasil();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Obx(() {
        final aktif = controller.filter.value;
        final jumlah = controller.jumlahPerFilter;
        return FadeTepi(
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
            itemCount: FilterHasil.values.length,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.s),
            itemBuilder: (_, i) {
              final f = FilterHasil.values[i];
              return Center(
                child: ChoiceChip(
                  key: Key('filter-${f.name}'),
                  label: Text('${f.label} (${jumlah[f] ?? 0})'),
                  selected: aktif == f,
                  onSelected: (_) => controller.pilihFilter(f),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}

class _MemuatResep extends StatelessWidget {
  const _MemuatResep();

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const Key('status-memuat'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: AppSpacing.l),
        Text('Memuat resep…', style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

class _KosongResep extends StatelessWidget {
  const _KosongResep();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: KeadaanKosong(
        key: const Key('status-kosong'),
        ilustrasi: const EmojiBesar('🍳'),
        judul: 'Belum ada resep yang cocok',
        pesan:
            'Tempel lebih banyak bahan, atau pilih filter lain untuk melihat '
            'resep yang kurang sedikit bahan.',
        labelAksi: 'Tambah bahan',
        onAksi: () => Get.find<MainController>().pindahTab(0),
      ),
    );
  }
}

class _GagalMuat extends StatelessWidget {
  final String pesan;
  final VoidCallback onCobaLagi;

  const _GagalMuat({required this.pesan, required this.onCobaLagi});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: KeadaanKosong(
        key: const Key('status-error'),
        ilustrasi: const EmojiBesar('🧊'),
        judul: 'Resep belum bisa dimuat',
        pesan: pesan,
        labelAksi: 'Coba lagi',
        onAksi: onCobaLagi,
        kunciAksi: const Key('coba-lagi'),
      ),
    );
  }
}
