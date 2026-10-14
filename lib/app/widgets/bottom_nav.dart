import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../controllers/main_controller.dart';
import '../routes/app_routes.dart';

/// Navigasi utama: Kulkas · Resep · Favorit. Tab yang menyala diambil dari
/// route halaman ini sendiri, jadi selalu benar walau halaman dibuka
/// langsung atau lewat `Get.offAllNamed` di luar [MainController.pindahTab].
class BottomNav extends GetView<MainController> {
  const BottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    final rute = ModalRoute.of(context)?.settings.name;
    final index = MainController.ruteTab.indexOf(rute ?? '');
    return NavigationBar(
      selectedIndex: index < 0 ? controller.indexTab.value : index,
      onDestinationSelected: (i) {
        HapticFeedback.lightImpact();
        controller.pindahTab(i);
      },
      destinations: const [
        NavigationDestination(
          key: Key('nav-kulkas'),
          icon: Icon(Icons.kitchen_outlined),
          selectedIcon: Icon(Icons.kitchen),
          label: 'Kulkas',
        ),
        NavigationDestination(
          key: Key('nav-resep'),
          icon: Icon(Icons.menu_book_outlined),
          selectedIcon: Icon(Icons.menu_book),
          label: 'Resep',
        ),
        NavigationDestination(
          key: Key('nav-favorit'),
          icon: Icon(Icons.favorite_border),
          selectedIcon: Icon(Icons.favorite),
          label: 'Favorit',
        ),
      ],
    );
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
