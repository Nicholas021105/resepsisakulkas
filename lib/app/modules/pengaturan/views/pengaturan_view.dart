import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../routes/app_routes.dart';
import '../../../theme/app_palet.dart';
import '../../../theme/app_spacing.dart';
import '../../../widgets/bottom_nav.dart';
import '../../../widgets/kulkas_widgets.dart';
import '../../../widgets/umum_widgets.dart';
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
    final subjudul = teks.bodyMedium?.copyWith(
      color: context.palet.tintaLembut,
    );
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
            const JudulBagian('TAMPILAN'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.l),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tema', style: teks.titleMedium),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Tema gelap lebih nyaman saat memasak malam hari.',
                      style: subjudul,
                    ),
                    const SizedBox(height: AppSpacing.m),
                    Obx(
                      () => PilihanSegmen<ThemeMode>(
                        key: const Key('pilih-tema'),
                        nilai: controller.modeTema,
                        onPilih: controller.ubahTema,
                        pilihan: const [
                          Segmen(
                            ThemeMode.system,
                            'Sistem',
                            ikon: Icons.brightness_auto_outlined,
                            kunci: Key('tema-sistem'),
                          ),
                          Segmen(
                            ThemeMode.light,
                            'Terang',
                            ikon: Icons.light_mode_outlined,
                            kunci: Key('tema-terang'),
                          ),
                          Segmen(
                            ThemeMode.dark,
                            'Gelap',
                            ikon: Icons.dark_mode_outlined,
                            kunci: Key('tema-gelap'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            const JudulBagian('DATA RESEP'),
            Card(
              child: Obx(
                () => Column(
                  children: [
                    ListTile(
                      contentPadding: _paddingBaris,
                      horizontalTitleGap: _jarakJudul,
                      leading: KotakIkon(
                        latar: context.palet.aksenLembut,
                        child: Icon(
                          ikonSumber(controller.sumber),
                          color: context.palet.aksenTua,
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
            const JudulBagian('KULKAS'),
            Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  Obx(
                    () => SwitchListTile(
                      key: const Key('opsi-bumbu-dasar'),
                      contentPadding: _paddingBaris,
                      horizontalTitleGap: _jarakJudul,
                      secondary: KotakIkon(
                        latar: context.palet.latar,
                        child: const Text(
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
                      iconColor: context.palet.bahaya,
                      textColor: context.palet.bahaya,
                      leading: KotakIkon(
                        latar: context.palet.bahayaLembut,
                        child: const Icon(Icons.delete_sweep_outlined),
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
            const JudulBagian('TENTANG'),
            Card(
              key: const Key('kartu-tentang'),
              child: Column(
                children: [
                  ListTile(
                    contentPadding: _paddingBaris,
                    horizontalTitleGap: _jarakJudul,
                    leading: KotakIkon(
                      latar: context.palet.aksenLembut,
                      child: Icon(Icons.kitchen, color: context.palet.aksenTua),
                    ),
                    title: Text('ResepSisaKulkas', style: teks.titleMedium),
                    subtitle: Obx(
                      () => Text(
                        'Versi ${controller.versiApp.value ?? '…'}',
                        key: const Key('versi-app'),
                        style: subjudul,
                      ),
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    key: const Key('lihat-pengenalan'),
                    contentPadding: _paddingBaris,
                    horizontalTitleGap: _jarakJudul,
                    leading: KotakIkon(
                      latar: context.palet.latar,
                      child: Icon(
                        Icons.waving_hand_outlined,
                        color: context.palet.tinta,
                      ),
                    ),
                    title: Text('Lihat pengenalan', style: teks.titleMedium),
                    subtitle: Text(
                      'Tiga layar singkat tentang cara pakai.',
                      style: subjudul,
                    ),
                    trailing: Icon(
                      Icons.chevron_right,
                      color: context.palet.tintaLembut,
                    ),
                    onTap: () => Get.toNamed(Routes.onboarding),
                  ),
                  const Divider(),
                  Obx(
                    () => ListTile(
                      contentPadding: _paddingBaris,
                      horizontalTitleGap: _jarakJudul,
                      leading: KotakIkon(
                        latar: context.palet.latar,
                        child: Icon(
                          Icons.menu_book_outlined,
                          color: context.palet.tinta,
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
