import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/main_controller.dart';
import '../../../theme/app_spacing.dart';
import '../../../widgets/bottom_nav.dart';
import '../../../widgets/kartu_resep.dart';
import '../../../widgets/kulkas_widgets.dart';
import '../controllers/favorit_controller.dart';

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
      bottomNavigationBar: const BottomNav(),
      body: SafeArea(
        child: Obx(() {
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
                  onAksi: () => Get.find<MainController>().pindahTab(1),
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
            itemBuilder: (_, i) => KartuResep(hasil: daftar[i]),
          );
        }),
      ),
    );
  }
}
