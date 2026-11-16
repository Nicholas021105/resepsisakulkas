import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/main_controller.dart';
import '../../../theme/app_spacing.dart';
import '../../../widgets/bottom_nav.dart';
import '../../belanja/views/belanja_view.dart';
import '../../favorit/views/favorit_view.dart';
import '../../kulkas/views/kulkas_view.dart';
import '../../resep/views/resep_view.dart';

/// Cangkang tab utama: semua tab ditumpuk dan tetap hidup, hanya tab aktif
/// yang terlihat. Tombol kembali sistem di tab lain membawa ke tab Kulkas
/// dulu, baru keluar aplikasi.
class BerandaView extends GetView<MainController> {
  const BerandaView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final index = controller.indexTab.value;
      return PopScope(
        canPop: index == MainController.tabKulkas,
        onPopInvokedWithResult: (sudahKeluar, _) {
          if (!sudahKeluar) controller.pindahTab(MainController.tabKulkas);
        },
        child: Scaffold(
          body: TumpukanTab(
            index: index,
            halaman: const [
              KulkasView(),
              ResepView(),
              FavoritView(),
              BelanjaView(),
            ],
          ),
          bottomNavigationBar: const BottomNav(),
        ),
      );
    });
  }
}

/// Seperti IndexedStack, tetapi tab baru dibangun saat pertama dibuka
/// (controller-nya ikut malas) dan tab aktif muncul dengan fade singkat.
/// Tab yang tersembunyi tidak menjalankan animasi (TickerMode) dan tidak
/// terbaca pembaca layar (Offstage).
class TumpukanTab extends StatefulWidget {
  final int index;
  final List<Widget> halaman;

  const TumpukanTab({super.key, required this.index, required this.halaman});

  @override
  State<TumpukanTab> createState() => _TumpukanTabState();
}

class _TumpukanTabState extends State<TumpukanTab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _muncul = AnimationController(
    vsync: this,
    duration: AppGerak.cepat,
    value: 1,
  );
  late final Set<int> _dibuka = {widget.index};

  @override
  void didUpdateWidget(TumpukanTab lama) {
    super.didUpdateWidget(lama);
    if (lama.index != widget.index) {
      _dibuka.add(widget.index);
      if (MediaQuery.disableAnimationsOf(context)) {
        _muncul.value = 1;
      } else {
        _muncul.forward(from: 0.4);
      }
    }
  }

  @override
  void dispose() {
    _muncul.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        for (var i = 0; i < widget.halaman.length; i++)
          if (_dibuka.contains(i))
            Offstage(
              key: ValueKey('tab-$i'),
              offstage: i != widget.index,
              child: TickerMode(
                enabled: i == widget.index,
                child: FadeTransition(
                  opacity: i == widget.index
                      ? _muncul
                      : kAlwaysCompleteAnimation,
                  child: widget.halaman[i],
                ),
              ),
            ),
      ],
    );
  }
}
