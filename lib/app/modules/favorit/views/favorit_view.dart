import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/main_controller.dart';
import '../../../data/models/belanja_model.dart';
import '../../../data/services/katalog_service.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_palet.dart';
import '../../../theme/app_spacing.dart';
import '../../../utils/formatter.dart';
import '../../../widgets/bottom_nav.dart';
import '../../../widgets/kartu_resep.dart';
import '../../../widgets/kulkas_widgets.dart';
import '../../../widgets/sampul_resep.dart';
import '../../../widgets/umum_widgets.dart';
import '../controllers/favorit_controller.dart';
import '../controllers/riwayat_controller.dart';

/// Tab Favorit: resep yang disimpan dan riwayat masak, dipilih lewat
/// segmen di atas.
class FavoritView extends GetView<FavoritController> {
  const FavoritView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorit'),
        actions: const [
          TombolPengaturan(),
          SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.l,
                0,
                AppSpacing.l,
                AppSpacing.s,
              ),
              child: Obx(
                () => PilihanSegmen<bool>(
                  nilai: controller.lihatRiwayat.value,
                  onPilih: (v) => controller.lihatRiwayat.value = v,
                  pilihan: const [
                    Segmen(
                      false,
                      'Favorit',
                      ikon: Icons.favorite_border,
                      kunci: Key('segmen-favorit'),
                    ),
                    Segmen(
                      true,
                      'Riwayat masak',
                      ikon: Icons.history,
                      kunci: Key('segmen-riwayat'),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Obx(
                () => controller.lihatRiwayat.value
                    ? const _DaftarRiwayat()
                    : const _DaftarFavorit(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DaftarFavorit extends GetView<FavoritController> {
  const _DaftarFavorit();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final daftar = controller.resepFavorit;
      if (daftar.isEmpty) {
        return Center(
          child: SingleChildScrollView(
            child: KeadaanKosong(
              key: const Key('favorit-kosong'),
              ilustrasi: const IlustrasiHati(),
              judul: 'Belum ada resep favorit',
              pesan:
                  'Ketuk ikon hati di halaman resep untuk menyimpannya '
                  'di sini.',
              labelAksi: 'Cari resep',
              onAksi: () =>
                  Get.find<MainController>().pindahTab(MainController.tabResep),
            ),
          ),
        );
      }
      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.l,
          AppSpacing.s,
          AppSpacing.l,
          AppSpacing.xl,
        ),
        itemCount: daftar.length,
        itemBuilder: (_, i) => KartuResep(hasil: daftar[i], sumber: 'favorit'),
      );
    });
  }
}

class _DaftarRiwayat extends StatelessWidget {
  const _DaftarRiwayat();

  @override
  Widget build(BuildContext context) {
    final riwayat = Get.find<RiwayatController>();
    return Obx(() {
      final daftar = riwayat.riwayat.toList();
      if (daftar.isEmpty) {
        return Center(
          child: SingleChildScrollView(
            child: KeadaanKosong(
              key: const Key('riwayat-kosong'),
              ilustrasi: const EmojiBesar('🍽️'),
              judul: 'Belum ada riwayat masak',
              pesan:
                  'Buka sebuah resep, ketuk "Mulai memasak", dan selesaikan '
                  'langkahnya. Masakanmu akan tercatat di sini.',
              labelAksi: 'Cari resep',
              onAksi: () =>
                  Get.find<MainController>().pindahTab(MainController.tabResep),
            ),
          ),
        );
      }
      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.l,
          AppSpacing.s,
          AppSpacing.l,
          AppSpacing.xl,
        ),
        itemCount: daftar.length,
        itemBuilder: (_, i) =>
            _BarisRiwayat(catatan: daftar[i], kini: riwayat.sekarang, index: i),
      );
    });
  }
}

class _BarisRiwayat extends StatelessWidget {
  final CatatanMasak catatan;
  final DateTime kini;
  final int index;

  const _BarisRiwayat({
    required this.catatan,
    required this.kini,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palet;
    final teks = Theme.of(context).textTheme;
    final resep = Get.find<KatalogService>().katalog.value?.resepById(
      catatan.resepId,
    );
    final radius = BorderRadius.circular(AppSpacing.radiusM);
    final sumber = 'riwayat-$index';
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s),
      child: Material(
        color: p.permukaan,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(color: p.garis),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          key: Key('riwayat-$index'),
          // Resep yang sudah tidak ada di katalog tetap tercatat, tetapi
          // tidak bisa dibuka.
          onTap: resep == null ? null : () => bukaDetailResep(resep, sumber),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.m),
            child: Row(
              children: [
                resep == null
                    ? Container(
                        width: AppSpacing.tombol,
                        height: AppSpacing.tombol,
                        decoration: BoxDecoration(
                          color: p.latar,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusS,
                          ),
                        ),
                        child: Icon(
                          Icons.no_meals_outlined,
                          color: p.tintaLembut,
                        ),
                      )
                    : Hero(
                        tag: tagSampul(sumber, resep.id),
                        child: SampulResep(
                          resep: resep,
                          ukuran: AppSpacing.tombol,
                          radius: AppSpacing.radiusS,
                        ),
                      ),
                const SizedBox(width: AppSpacing.m),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        resep?.nama ?? catatan.nama,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: teks.titleMedium,
                      ),
                      Text(
                        formatWaktuMasak(catatan.waktu, kini),
                        style: teks.bodySmall,
                      ),
                    ],
                  ),
                ),
                if (resep != null)
                  Icon(Icons.chevron_right, color: p.tintaLembut)
                else
                  const SizedBox(
                    width: AppSpacing.xl,
                    child: ColoredBox(color: AppColors.transparan),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
