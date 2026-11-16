import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../controllers/main_controller.dart';
import '../modules/belanja/controllers/belanja_controller.dart';
import '../routes/app_routes.dart';

/// Navigasi utama: Kulkas · Resep · Favorit · Belanja. Tab yang menyala
/// mengikuti [MainController.indexTab]; tab Belanja berlencana jumlah bahan
/// yang masih perlu dibeli.
class BottomNav extends GetView<MainController> {
  const BottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    final belanja = Get.find<BelanjaController>();
    return Obx(() {
      final perlu = belanja.jumlahPerlu;
      Widget lencana(IconData ikon) => Badge(
        isLabelVisible: perlu > 0,
        label: Text('$perlu'),
        child: Icon(ikon),
      );
      return NavigationBar(
        selectedIndex: controller.indexTab.value,
        onDestinationSelected: (i) {
          HapticFeedback.selectionClick();
          controller.pindahTab(i);
        },
        destinations: [
          const NavigationDestination(
            key: Key('nav-kulkas'),
            icon: Icon(Icons.kitchen_outlined),
            selectedIcon: Icon(Icons.kitchen),
            label: 'Kulkas',
          ),
          const NavigationDestination(
            key: Key('nav-resep'),
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Resep',
          ),
          const NavigationDestination(
            key: Key('nav-favorit'),
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favorit',
          ),
          NavigationDestination(
            key: const Key('nav-belanja'),
            icon: lencana(Icons.shopping_basket_outlined),
            selectedIcon: lencana(Icons.shopping_basket),
            label: 'Belanja',
            tooltip: perlu > 0 ? 'Belanja, $perlu bahan perlu dibeli' : null,
          ),
        ],
      );
    });
  }
}

/// Tombol kembali di AppBar (leading) untuk halaman di luar tab. Tetap
/// tampil walau halaman dibuka langsung: tanpa riwayat → ke Kulkas.
class TombolKembali extends GetView<MainController> {
  const TombolKembali({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      key: const Key('appbar-kembali'),
      tooltip: 'Kembali',
      onPressed: controller.kembali,
      icon: const Icon(Icons.arrow_back),
    );
  }
}

/// Ikon Pengaturan di AppBar.
class TombolPengaturan extends StatelessWidget {
  const TombolPengaturan({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      key: const Key('buka-pengaturan'),
      tooltip: 'Pengaturan',
      onPressed: () => Get.toNamed(Routes.pengaturan),
      icon: const Icon(Icons.tune),
    );
  }
}
