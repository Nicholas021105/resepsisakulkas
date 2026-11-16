import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../controllers/main_controller.dart';
import '../../../data/models/hasil_cocok.dart';
import '../../../data/models/resep_model.dart';
import '../../../data/services/katalog_service.dart';
import '../../../theme/app_palet.dart';
import '../../../theme/app_spacing.dart';
import '../../../utils/formatter.dart';
import '../../../utils/kesegaran.dart';
import '../../../widgets/bottom_nav.dart';
import '../../../widgets/kartu_resep.dart';
import '../../../widgets/kerangka.dart';
import '../../../widgets/kulkas_widgets.dart';
import '../../../widgets/sampul_resep.dart';
import '../../../widgets/umum_widgets.dart';
import '../../kulkas/controllers/kulkas_controller.dart';
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
      body: SafeArea(
        child: CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            const SliverToBoxAdapter(child: _Kepala()),
            const SliverToBoxAdapter(child: _SaranHariIni()),
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
              onLoading: const SliverToBoxAdapter(child: _MemuatResep()),
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

/// Label sumber data, pencarian + urutan, kategori, dan chip filter.
/// Disembunyikan saat status error agar pesan galat tidak didahului chip
/// "(0)" yang menyesatkan.
class _Kepala extends GetView<ResepController> {
  const _Kepala();

  @override
  Widget build(BuildContext context) {
    final katalog = Get.find<KatalogService>();
    final teks = Theme.of(context).textTheme;
    final p = context.palet;
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
                  color: p.tintaLembut,
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
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.l,
              0,
              AppSpacing.s,
              0,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    key: const Key('cari-resep'),
                    controller: controller.teksCari,
                    onChanged: controller.cari,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Cari resep atau bahan',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: controller.kataKunci.value.isEmpty
                          ? null
                          : IconButton(
                              key: const Key('hapus-cari-resep'),
                              tooltip: 'Hapus pencarian',
                              onPressed: controller.hapusPencarian,
                              icon: const Icon(Icons.close),
                            ),
                    ),
                  ),
                ),
                const _TombolUrutan(),
              ],
            ),
          ),
          const _FilterKategori(),
          const _FilterHasil(),
          const SizedBox(height: AppSpacing.xs),
        ],
      );
    });
  }
}

/// Menu urutan; titik wortel menandai urutan selain "Paling cocok".
class _TombolUrutan extends GetView<ResepController> {
  const _TombolUrutan();

  @override
  Widget build(BuildContext context) => Obx(() => _isi(context));

  Widget _isi(BuildContext context) {
    final p = context.palet;
    final teks = Theme.of(context).textTheme;
    final aktif = controller.urutan.value;
    return PopupMenuButton<UrutanResep>(
      key: const Key('urutkan'),
      tooltip: 'Urutkan: ${aktif.label}',
      initialValue: aktif,
      onSelected: (u) {
        HapticFeedback.selectionClick();
        controller.pilihUrutan(u);
      },
      itemBuilder: (_) => [
        for (final u in UrutanResep.values)
          PopupMenuItem(
            key: Key('urutan-${u.name}'),
            value: u,
            child: Row(
              children: [
                Icon(
                  u == aktif
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  size: 20,
                  color: u == aktif ? p.aksenTua : p.tintaLembut,
                ),
                const SizedBox(width: AppSpacing.m),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(u.label, style: teks.titleSmall),
                      Text(u.keterangan, style: teks.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
      child: SizedBox.square(
        dimension: AppSpacing.sentuh,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(Icons.swap_vert, color: p.tinta),
            if (aktif != UrutanResep.cocok)
              Positioned(
                top: AppSpacing.m,
                right: AppSpacing.m,
                child: Container(
                  key: const Key('urutan-aktif'),
                  width: AppSpacing.s,
                  height: AppSpacing.s,
                  decoration: BoxDecoration(
                    color: p.wortel,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FilterKategori extends GetView<ResepController> {
  const _FilterKategori();

  @override
  Widget build(BuildContext context) => Obx(() => _isi(context));

  Widget _isi(BuildContext context) {
    final daftar = controller.kategoriTersedia;
    if (daftar.length < 2) return const SizedBox(height: AppSpacing.s);
    final aktif = controller.kategori.value;
    final pilihan = <(KategoriResep?, String)>[
      (null, 'Semua hidangan'),
      for (final k in daftar) (k, k.label),
    ];
    return SizedBox(
      height: 52,
      child: FadeTepi(
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
          itemCount: pilihan.length,
          separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.s),
          itemBuilder: (_, i) {
            final (k, label) = pilihan[i];
            return Center(
              child: ChoiceChip(
                key: Key('kategori-${k?.name ?? 'semua'}'),
                label: Text(label),
                selected: aktif == k,
                onSelected: (_) => controller.kategori.value = k,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _FilterHasil extends GetView<ResepController> {
  const _FilterHasil();

  @override
  Widget build(BuildContext context) => Obx(() => _isi(context));

  Widget _isi(BuildContext context) {
    final aktif = controller.filter.value;
    final jumlah = controller.jumlahPerFilter;
    return SizedBox(
      height: 52,
      child: FadeTepi(
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
      ),
    );
  }
}

/// Kartu "Masak apa hari ini?": satu saran (resep penyelamat bahan segera
/// habis lebih dulu). Disembunyikan saat pengguna sedang mencari.
class _SaranHariIni extends GetView<ResepController> {
  const _SaranHariIni();

  static const sumber = 'saran';

  @override
  Widget build(BuildContext context) {
    final teks = Theme.of(context).textTheme;
    final p = context.palet;
    final kulkas = Get.find<KulkasController>();
    final katalog = Get.find<KatalogService>();
    return Obx(() {
      final saran = controller.katalogSiap && !controller.sedangMenjelajah
          ? controller.saran
          : null;
      if (saran == null) return const SizedBox.shrink();
      final byId = katalog.katalog.value?.bahanById ?? const {};
      final (ikon, alasan, latar, warna) = saran.pakaiSegera
          ? (
              Icons.hourglass_bottom,
              labelPakaiSegera([
                for (final id in saran.segera) byId[id]?.nama ?? id,
              ]),
              p.pisangLembut,
              p.pisangTeks,
            )
          : kulkas.kulkasKosong || saran.persen == 0
          ? (
              Icons.lightbulb_outline,
              'Inspirasi hari ini',
              p.permukaan,
              p.tintaLembut,
            )
          : saran.siapDimasak
          ? (
              Icons.check_circle_outline,
              'Semua bahan ada',
              p.aksenLembut,
              p.aksenTua,
            )
          : (
              Icons.shopping_basket_outlined,
              'Kurang ${saran.kurang.length} bahan',
              p.wortelLembut,
              p.wortelTeks,
            );
      final r = saran.resep;
      final radius = BorderRadius.circular(AppSpacing.radiusL);
      return Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.l,
          AppSpacing.xs,
          AppSpacing.l,
          AppSpacing.s,
        ),
        child: Material(
          color: p.mintPucat,
          borderRadius: radius,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            key: const Key('saran-hari-ini'),
            onTap: () => bukaDetailResep(r, sumber),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.m,
                AppSpacing.m,
                AppSpacing.xs,
                AppSpacing.xs,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Hero(
                    tag: tagSampul(sumber, r.id),
                    child: SampulResep(resep: r, ukuran: 88),
                  ),
                  const SizedBox(width: AppSpacing.m),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MASAK APA HARI INI?',
                          style: teks.labelSmall?.copyWith(color: p.aksenTua),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          r.nama,
                          key: const Key('nama-saran'),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: teks.titleLarge,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        LabelPil(
                          ikon: ikon,
                          teks: alasan,
                          latar: latar,
                          warna: warna,
                        ),
                        // Wrap: di layar sempit/huruf besar tombol turun
                        // ke baris berikutnya, bukan meluap.
                        Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: AppSpacing.s,
                          children: [
                            Text(
                              '${r.waktuMenit} menit · ${r.tingkat.label}',
                              style: teks.bodySmall,
                            ),
                            TextButton.icon(
                              key: const Key('saran-lain'),
                              onPressed: () {
                                HapticFeedback.selectionClick();
                                controller.saranLain();
                              },
                              icon: const Icon(Icons.casino_outlined, size: 18),
                              label: const Text('Saran lain'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}

/// Kerangka daftar resep selama katalog dimuat.
class _MemuatResep extends StatelessWidget {
  const _MemuatResep();

  @override
  Widget build(BuildContext context) {
    return Padding(
      key: const Key('status-memuat'),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.l,
        AppSpacing.s,
        AppSpacing.l,
        AppSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Memuat resep…', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: AppSpacing.m),
          const KilauKerangka(
            child: Column(
              children: [
                KerangkaKartuResep(),
                KerangkaKartuResep(),
                KerangkaKartuResep(),
                KerangkaKartuResep(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Tidak ada hasil. Saat sedang mencari/menyaring kategori, pesannya
/// menunjukkan jalan keluar (lihat di "Semua" atau hapus pencarian).
class _KosongResep extends GetView<ResepController> {
  const _KosongResep();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.sedangMenjelajah) {
        return Center(
          child: KeadaanKosong(
            key: const Key('status-kosong'),
            ilustrasi: const EmojiBesar('🍳'),
            judul: 'Belum ada resep yang cocok',
            pesan:
                'Tempel lebih banyak bahan, atau pilih filter lain untuk '
                'melihat resep yang kurang sedikit bahan.',
            labelAksi: 'Tambah bahan',
            onAksi: () =>
                Get.find<MainController>().pindahTab(MainController.tabKulkas),
          ),
        );
      }
      final diSemua = controller.jumlahPerFilter[FilterHasil.semua] ?? 0;
      final adaDiSemua =
          diSemua > 0 && controller.filter.value != FilterHasil.semua;
      return Center(
        child: KeadaanKosong(
          key: const Key('status-kosong'),
          ilustrasi: const EmojiBesar('🔍'),
          judul: adaDiSemua
              ? 'Tidak ada di "${controller.filter.value.label}"'
              : 'Resep tidak ditemukan',
          pesan: adaDiSemua
              ? 'Ada $diSemua resep yang cocok dengan pencarianmu bila '
                    'filter kecocokan dilepas.'
              : 'Coba kata lain, mis. nama bahan seperti "tempe", atau '
                    'pilih kategori lain.',
          labelAksi: adaDiSemua ? 'Lihat $diSemua resep' : 'Hapus pencarian',
          kunciAksi: const Key('aksi-kosong'),
          onAksi: adaDiSemua
              ? () => controller.pilihFilter(FilterHasil.semua)
              : () {
                  controller.hapusPencarian();
                  controller.kategori.value = null;
                },
        ),
      );
    });
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
