import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import '../../../widgets/bottom_nav.dart';
import '../../../widgets/kulkas_widgets.dart';
import '../controllers/pengaturan_controller.dart';

/// Semua baris memakai ikon dalam kotak 40×40 dan jarak judul yang sama,
/// sehingga teks setiap baris mulai di x yang sama.
const _jarakJudul = AppSpacing.m;
const _paddingBaris = EdgeInsets.symmetric(horizontal: AppSpacing.l);

class PengaturanView extends GetView<PengaturanController> {
  const PengaturanView({super.key});

  @override
  Widget build(BuildContext context) {
    final teks = Theme.of(context).textTheme;
    final subjudul = teks.bodyMedium?.copyWith(color: AppColors.tintaLembut);
    return Scaffold(
      appBar: AppBar(
        leading: const TombolKembali(),
        title: const Text('Pengaturan'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.l,
            AppSpacing.s,
            AppSpacing.l,
            AppSpacing.xxl,
          ),
          children: [
            const _JudulBagian('DATA RESEP'),
            Card(
              child: Obx(
                () => Column(
                  children: [
                    ListTile(
                      contentPadding: _paddingBaris,
                      horizontalTitleGap: _jarakJudul,
                      leading: _KotakIkon(
                        latar: AppColors.aksenLembut,
                        child: Icon(
                          ikonSumber(controller.sumber),
                          color: AppColors.aksenTua,
                        ),
                      ),
                      title: Text(
                        controller.labelSumberData,
                        key: const Key('sumber-data'),
                        style: teks.titleMedium,
                      ),
                      subtitle: Text(
                        '${controller.jumlahResep} resep tersedia',
                        style: subjudul,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.l,
                        AppSpacing.xs,
                        AppSpacing.l,
                        AppSpacing.l,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          key: const Key('perbarui-data'),
                          onPressed: controller.memuat
                              ? null
                              : () {
                                  HapticFeedback.lightImpact();
                                  controller.perbaruiData();
                                },
                          icon: controller.memuat
                              ? const SizedBox.square(
                                  dimension: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.sync),
                          label: Text(
                            controller.memuat
                                ? 'Memperbarui…'
                                : 'Perbarui data',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            const _JudulBagian('KULKAS'),
            Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  Obx(
                    () => SwitchListTile(
                      key: const Key('opsi-bumbu-dasar'),
                      contentPadding: _paddingBaris,
                      horizontalTitleGap: _jarakJudul,
                      secondary: const _KotakIkon(
                        latar: AppColors.latar,
                        child: Text(
                          '🧂',
                          textScaler: TextScaler.noScaling,
                          style: TextStyle(fontSize: 22, height: 1),
                        ),
                      ),
                      title: Text('Bumbu dasar', style: teks.titleMedium),
                      subtitle: Text(
                        'Garam, gula, minyak goreng, dan air dianggap '
                        'selalu ada.',
                        style: subjudul,
                      ),
                      value: controller.kulkas.bumbuDasarAda.value,
                      onChanged: controller.ubahBumbuDasar,
                    ),
                  ),
                  const Divider(),
                  Obx(
                    () => ListTile(
                      key: const Key('pengaturan-kosongkan'),
                      contentPadding: _paddingBaris,
                      horizontalTitleGap: _jarakJudul,
                      iconColor: AppColors.bahaya,
                      textColor: AppColors.bahaya,
                      leading: const _KotakIkon(
                        latar: AppColors.bahayaLembut,
                        child: Icon(Icons.delete_sweep_outlined),
                      ),
                      // Warna judul dari textColor (otomatis abu saat
                      // nonaktif).
                      titleTextStyle: teks.titleMedium,
                      title: const Text('Kosongkan kulkas'),
                      subtitle: Text(
                        '${controller.kulkas.bahanDimiliki.length} bahan '
                        'ditempel',
                        style: subjudul,
                      ),
                      enabled: !controller.kulkas.kulkasKosong,
                      onTap: controller.kulkas.konfirmasiKosongkan,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            const _JudulBagian('TENTANG'),
            Card(
              key: const Key('kartu-tentang'),
              child: Column(
                children: [
                  ListTile(
                    contentPadding: _paddingBaris,
                    horizontalTitleGap: _jarakJudul,
                    leading: const _KotakIkon(
                      latar: AppColors.aksenLembut,
                      child: Icon(Icons.kitchen, color: AppColors.aksenTua),
                    ),
                    title: Text('ResepSisaKulkas', style: teks.titleMedium),
                    subtitle: Text(
                      'Versi ${PengaturanController.versiApp}',
                      key: const Key('versi-app'),
                      style: subjudul,
                    ),
                  ),
                  const Divider(),
                  Obx(
                    () => ListTile(
                      contentPadding: _paddingBaris,
                      horizontalTitleGap: _jarakJudul,
                      leading: const _KotakIkon(
                        latar: AppColors.latar,
                        child: Icon(
                          Icons.menu_book_outlined,
                          color: AppColors.tinta,
                        ),
                      ),
                      title: Text('Data resep', style: teks.titleMedium),
                      subtitle: Text(
                        '${controller.jumlahResep} resep, '
                        '${controller.jumlahBahan} bahan',
                        key: const Key('info-data-resep'),
                        style: subjudul,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _JudulBagian extends StatelessWidget {
  final String teks;

  const _JudulBagian(this.teks);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.xs, bottom: AppSpacing.s),
      child: Text(teks, style: Theme.of(context).textTheme.labelSmall),
    );
  }
}

/// Kotak ikon 40×40 yang sama untuk semua baris (leading).
class _KotakIkon extends StatelessWidget {
  final Widget child;
  final Color latar;

  const _KotakIkon({required this.child, required this.latar});

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
