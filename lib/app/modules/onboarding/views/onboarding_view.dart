import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/resep_model.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_palet.dart';
import '../../../theme/app_spacing.dart';
import '../../../widgets/kulkas_widgets.dart';
import '../../../widgets/sampul_resep.dart';
import '../controllers/onboarding_controller.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  static const _halaman = [
    (
      judul: 'Tempel isi kulkasmu',
      isi:
          'Ketuk magnet bahan yang kamu punya. Tekan lama untuk menandai '
          'bahan yang harus segera dihabiskan.',
    ),
    (
      judul: 'Temukan resep yang cocok',
      isi:
          'Resep rumahan diurutkan dari yang paling bisa dimasak sekarang. '
          'Yang menyelamatkan bahan hampir basi naik ke atas.',
    ),
    (
      judul: 'Belanja, masak, selesai',
      isi:
          'Bahan yang kurang masuk daftar belanja. Mode masak memandu '
          'langkah demi langkah, lengkap dengan timer.',
    ),
  ];

  Widget _ilustrasi(int index) => switch (index) {
    0 => const IlustrasiKulkasKosong(ukuran: 168),
    1 => const _IlustrasiResep(),
    _ => const IlustrasiKeranjang(),
  };

  @override
  Widget build(BuildContext context) {
    final teks = Theme.of(context).textTheme;
    final p = context.palet;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(
                  top: AppSpacing.xs,
                  right: AppSpacing.s,
                ),
                child: TextButton(
                  key: const Key('onboarding-lewati'),
                  onPressed: controller.selesai,
                  child: const Text('Lewati'),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                key: const Key('onboarding-halaman'),
                controller: controller.pageController,
                onPageChanged: controller.halamanBerubah,
                itemCount: _halaman.length,
                itemBuilder: (_, i) => Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                      vertical: AppSpacing.l,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: AppSpacing.lebarIsi,
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 176,
                            child: Center(child: _ilustrasi(i)),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          Semantics(
                            header: true,
                            child: Text(
                              _halaman[i].judul,
                              textAlign: TextAlign.center,
                              style: teks.headlineMedium,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.m),
                          Text(
                            _halaman[i].isi,
                            textAlign: TextAlign.center,
                            style: teks.bodyLarge?.copyWith(
                              color: p.tintaLembut,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Obx(() {
              final aktif = controller.halaman.value;
              return Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.s,
                  AppSpacing.xl,
                  AppSpacing.l,
                ),
                child: Column(
                  children: [
                    Semantics(
                      label:
                          'Halaman ${aktif + 1} dari '
                          '${OnboardingController.jumlahHalaman}',
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (var i = 0; i < _halaman.length; i++)
                            AnimatedContainer(
                              duration: AppGerak.sedang,
                              margin: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.xs,
                              ),
                              width: i == aktif ? AppSpacing.xl : AppSpacing.s,
                              height: AppSpacing.s,
                              decoration: BoxDecoration(
                                color: i == aktif ? p.aksenTua : p.garis,
                                borderRadius: BorderRadius.circular(
                                  AppSpacing.radiusPill,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.l),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        key: const Key('onboarding-lanjut'),
                        onPressed: controller.lanjut,
                        child: Text(
                          controller.terakhir ? 'Mulai tempel bahan' : 'Lanjut',
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

/// Dua sampul resep bertumpuk miring + cincin 100%.
class _IlustrasiResep extends StatelessWidget {
  const _IlustrasiResep();

  // Dua resep contoh untuk ilustrasi (bukan dari katalog).
  static const _sop = Resep(
    id: 'contoh-sayur-bening',
    nama: 'Sayur bening',
    deskripsi: '',
    waktuMenit: 15,
    porsi: 2,
    tingkat: TingkatResep.mudah,
    sajian: JenisSajian.kuah,
    bahan: [
      BahanResep(bahanId: 'bayam', takaran: ''),
      BahanResep(bahanId: 'jagung', takaran: ''),
      BahanResep(bahanId: 'wortel', takaran: ''),
    ],
    langkah: [],
  );
  static const _tempe = Resep(
    id: 'contoh-tempe-goreng',
    nama: 'Tempe goreng',
    deskripsi: '',
    waktuMenit: 15,
    porsi: 2,
    tingkat: TingkatResep.mudah,
    sajian: JenisSajian.goreng,
    bahan: [
      BahanResep(bahanId: 'tempe', takaran: ''),
      BahanResep(bahanId: 'cabai', takaran: ''),
      BahanResep(bahanId: 'bawang-putih', takaran: ''),
    ],
    langkah: [],
  );

  static Widget _ubin(double sudut, Resep resep) => Transform.rotate(
    angle: sudut,
    child: Container(
      width: 104,
      height: 104,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusL),
        border: Border.all(color: AppColors.putih, width: 3),
      ),
      clipBehavior: Clip.antiAlias,
      child: CustomPaint(painter: SampulPainter(susunSampul(resep))),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final p = context.palet;
    return ExcludeSemantics(
      child: SizedBox(
        width: 208,
        height: 168,
        child: Stack(
          children: [
            Positioned(left: 8, top: 8, child: _ubin(-0.14, _sop)),
            Positioned(right: 12, top: 36, child: _ubin(0.1, _tempe)),
            Positioned(
              left: 76,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: p.permukaan,
                  shape: BoxShape.circle,
                  boxShadow: p.bayanganKartu,
                ),
                child: const CincinPersen(persen: 100, ukuran: 56),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
