import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/bahan_model.dart';
import '../../../data/models/resep_model.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_palet.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_text.dart';
import '../../../utils/durasi_langkah.dart';
import '../../../utils/notifikasi.dart';
import '../../../widgets/ikon_bahan.dart';
import '../../../widgets/kulkas_widgets.dart';
import '../../../widgets/sampul_resep.dart';
import '../../../widgets/umum_widgets.dart';
import '../controllers/masak_controller.dart';

class MasakView extends GetView<MasakController> {
  const MasakView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final resep = controller.resep;
      if (resep == null) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              key: const Key('tutup-masak'),
              tooltip: 'Tutup',
              onPressed: controller.keluar,
              icon: const Icon(Icons.close),
            ),
          ),
          body: Center(
            child: controller.katalogSiap
                ? SingleChildScrollView(
                    child: KeadaanKosong(
                      key: const Key('masak-tidak-ditemukan'),
                      ilustrasi: const EmojiBesar('🔍'),
                      judul: 'Resep tidak ditemukan',
                      pesan: 'Resep ini mungkin sudah dihapus dari katalog.',
                      labelAksi: 'Kembali',
                      onAksi: controller.keluar,
                    ),
                  )
                : const CircularProgressIndicator(),
          ),
        );
      }
      final jumlah = resep.langkah.length;
      final halaman = controller.halaman.value;
      final selesai = halaman >= jumlah;
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (sudahKeluar, _) {
          if (!sudahKeluar) controller.keluar();
        },
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              key: const Key('tutup-masak'),
              tooltip: 'Tutup mode masak',
              onPressed: controller.keluar,
              icon: const Icon(Icons.close),
            ),
            title: Text(
              selesai ? 'Selesai' : 'Langkah ${halaman + 1} dari $jumlah',
              key: const Key('judul-masak'),
            ),
            actions: [
              IconButton(
                key: const Key('lihat-bahan'),
                tooltip: 'Lihat bahan dan takaran',
                onPressed: () =>
                    bukaLembar<void>(LembarBahanMasak(resep: resep)),
                icon: const Icon(Icons.format_list_bulleted),
              ),
              const SizedBox(width: AppSpacing.xs),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(AppSpacing.m),
              child: _Kemajuan(jumlah: jumlah, halaman: halaman),
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    key: const Key('halaman-masak'),
                    controller: controller.pageController,
                    onPageChanged: controller.halamanBerubah,
                    itemCount: jumlah + 1,
                    itemBuilder: (_, i) => i < jumlah
                        ? _HalamanLangkah(resep: resep, index: i)
                        : _HalamanSelesai(resep: resep),
                  ),
                ),
                if (!selesai)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.l,
                      AppSpacing.s,
                      AppSpacing.l,
                      AppSpacing.m,
                    ),
                    child: Row(
                      children: [
                        if (halaman > 0) ...[
                          IconButton.outlined(
                            key: const Key('langkah-sebelum'),
                            tooltip: 'Langkah sebelumnya',
                            onPressed: controller.sebelum,
                            icon: const Icon(Icons.arrow_back),
                          ),
                          const SizedBox(width: AppSpacing.m),
                        ],
                        Expanded(
                          child: FilledButton(
                            key: const Key('langkah-berikut'),
                            onPressed: controller.berikut,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                halaman == jumlah - 1
                                    ? 'Selesai memasak'
                                    : 'Langkah berikutnya',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

/// Batang kemajuan bersegmen: satu segmen per langkah.
class _Kemajuan extends StatelessWidget {
  final int jumlah;
  final int halaman;

  const _Kemajuan({required this.jumlah, required this.halaman});

  @override
  Widget build(BuildContext context) {
    final p = context.palet;
    return Semantics(
      label: halaman >= jumlah
          ? 'Semua langkah selesai'
          : 'Langkah ${halaman + 1} dari $jumlah',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.l,
          0,
          AppSpacing.l,
          AppSpacing.s,
        ),
        child: Row(
          children: [
            for (var i = 0; i < jumlah; i++) ...[
              if (i > 0) const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: AnimatedContainer(
                  duration: AppGerak.sedang,
                  height: AppSpacing.xs,
                  decoration: BoxDecoration(
                    color: i <= halaman ? p.aksen : p.garis,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Satu langkah: nomor besar, teks besar, dan timer bila berdurasi.
class _HalamanLangkah extends GetView<MasakController> {
  final Resep resep;
  final int index;

  const _HalamanLangkah({required this.resep, required this.index});

  @override
  Widget build(BuildContext context) {
    final p = context.palet;
    final adaTimer = controller.durasi(index) != null;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.l,
          AppSpacing.xl,
          AppSpacing.l,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppSpacing.lebarIsi),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: AppSpacing.tombol,
                height: AppSpacing.tombol,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: p.mintPucat,
                  shape: BoxShape.circle,
                ),
                child: ExcludeSemantics(
                  child: Text(
                    '${index + 1}',
                    style: AppText.angka(26, warna: p.aksenTua),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.l),
              Text(
                resep.langkah[index],
                key: Key('teks-langkah-$index'),
                style: AppText.langkahBesar(p),
              ),
              if (adaTimer) ...[
                const SizedBox(height: AppSpacing.xl),
                _KartuTimer(index: index),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _KartuTimer extends GetView<MasakController> {
  final int index;

  const _KartuTimer({required this.index});

  @override
  Widget build(BuildContext context) {
    final p = context.palet;
    final teks = Theme.of(context).textTheme;
    return Obx(() {
      final sisa = controller.sisaUntuk(index);
      final jalan = controller.berjalanDi(index);
      final habis = controller.habisDi(index);
      final penuh = controller.durasi(index)!.inSeconds;
      final sudahMulai = controller.langkahTimer.value == index;
      return Container(
        key: Key('timer-$index'),
        padding: const EdgeInsets.all(AppSpacing.l),
        decoration: BoxDecoration(
          color: habis ? p.aksenLembut : p.permukaan,
          borderRadius: BorderRadius.circular(AppSpacing.radiusL),
          border: Border.all(color: habis ? p.aksen : p.garis),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  habis ? Icons.notifications_active : Icons.timer_outlined,
                  size: 18,
                  color: p.tintaLembut,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    habis
                        ? 'Waktu habis'
                        : (jalan ? 'Timer berjalan' : 'Timer langkah ini'),
                    style: teks.labelMedium?.copyWith(color: p.tintaLembut),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s),
            Semantics(
              label: 'Sisa waktu ${ucapTimer(sisa)}',
              liveRegion: habis,
              child: ExcludeSemantics(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    formatTimer(sisa),
                    key: Key('sisa-timer-$index'),
                    style: AppText.angka(48, warna: p.tinta),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.m),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
              child: LinearProgressIndicator(
                value: sudahMulai && sisa <= penuh ? 1 - sisa / penuh : 0,
                minHeight: AppSpacing.xs + 2,
              ),
            ),
            const SizedBox(height: AppSpacing.m),
            Wrap(
              spacing: AppSpacing.s,
              runSpacing: AppSpacing.s,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                FilledButton.icon(
                  key: Key('timer-mulai-$index'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(
                      AppSpacing.sentuh,
                      AppSpacing.sentuh,
                    ),
                  ),
                  onPressed: () => controller.mulaiAtauJeda(index),
                  icon: Icon(jalan ? Icons.pause : Icons.play_arrow),
                  label: Text(
                    jalan
                        ? 'Jeda'
                        : (habis
                              ? 'Ulangi'
                              : (sudahMulai && sisa < penuh
                                    ? 'Lanjutkan'
                                    : 'Mulai timer')),
                  ),
                ),
                OutlinedButton(
                  key: Key('timer-tambah-$index'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(
                      AppSpacing.sentuh,
                      AppSpacing.sentuh,
                    ),
                  ),
                  onPressed: () => controller.tambahSemenit(index),
                  child: const Text('+1 menit'),
                ),
                if (sudahMulai)
                  IconButton(
                    key: Key('timer-ulang-$index'),
                    tooltip: 'Setel ulang timer',
                    onPressed: () => controller.ulangTimer(index),
                    icon: const Icon(Icons.replay),
                  ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

/// Layar terakhir: perayaan kecil, bahan mana yang habis, simpan riwayat.
class _HalamanSelesai extends GetView<MasakController> {
  final Resep resep;

  const _HalamanSelesai({required this.resep});

  @override
  Widget build(BuildContext context) {
    final p = context.palet;
    final teks = Theme.of(context).textTheme;
    return Stack(
      children: [
        Center(
          child: SingleChildScrollView(
            key: const Key('halaman-selesai'),
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.l,
              AppSpacing.xl,
              AppSpacing.xl,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: AppSpacing.lebarIsi),
              child: Obx(() {
                final terpakai = controller.bahanTerpakai;
                return Column(
                  children: [
                    SampulResep(
                      resep: resep,
                      ukuran: 120,
                      radius: AppSpacing.radiusL,
                    ),
                    const SizedBox(height: AppSpacing.l),
                    Text(
                      'Selamat makan!',
                      textAlign: TextAlign.center,
                      style: teks.headlineMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${resep.nama} sudah jadi.',
                      textAlign: TextAlign.center,
                      style: teks.bodyLarge?.copyWith(color: p.tintaLembut),
                    ),
                    if (terpakai.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xl),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Ada bahan yang habis?',
                          style: teks.titleLarge,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Yang dicentang akan dilepas dari kulkasmu.',
                          style: teks.bodyMedium?.copyWith(
                            color: p.tintaLembut,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.m),
                      for (final b in terpakai)
                        _BarisHabis(
                          bahan: b,
                          dicentang: controller.habis.contains(b.id),
                          onTap: () => controller.toggleHabis(b.id),
                        ),
                    ],
                    const SizedBox(height: AppSpacing.xl),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        key: const Key('simpan-selesai'),
                        onPressed: controller.simpanSelesai,
                        icon: const Icon(Icons.check),
                        label: Text(
                          controller.habis.isEmpty
                              ? 'Catat ke riwayat masak'
                              : 'Catat & lepas ${controller.habis.length} '
                                    'bahan',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
        const Positioned.fill(child: IgnorePointer(child: HujanMagnet())),
      ],
    );
  }
}

class _BarisHabis extends StatelessWidget {
  final Bahan bahan;
  final bool dicentang;
  final VoidCallback onTap;

  const _BarisHabis({
    required this.bahan,
    required this.dicentang,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palet;
    final radius = BorderRadius.circular(AppSpacing.radiusM);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s),
      child: Semantics(
        checked: dicentang,
        label: '${bahan.nama} habis',
        excludeSemantics: true,
        child: Material(
          color: dicentang ? p.wortelLembut : p.permukaan,
          shape: RoundedRectangleBorder(
            borderRadius: radius,
            side: BorderSide(color: dicentang ? p.wortel : p.garis),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            key: Key('habis-${bahan.id}'),
            onTap: onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: AppSpacing.tombol),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.m,
                  vertical: AppSpacing.s,
                ),
                child: Row(
                  children: [
                    IkonBahan.dari(bahan),
                    const SizedBox(width: AppSpacing.m),
                    Expanded(
                      child: Text(
                        bahan.nama,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    Text(
                      dicentang ? 'Habis' : 'Masih ada',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: dicentang ? p.wortelTeks : p.tintaLembut,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s),
                    Icon(
                      dicentang
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: dicentang ? p.wortelTeks : p.tintaLembut,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Lembar bahan + takaran, bisa dibuka kapan saja saat memasak.
class LembarBahanMasak extends GetView<MasakController> {
  final Resep resep;

  const LembarBahanMasak({super.key, required this.resep});

  @override
  Widget build(BuildContext context) {
    final teks = Theme.of(context).textTheme;
    final p = context.palet;
    final byId = controller.bahanById;
    return Column(
      key: const Key('lembar-bahan-masak'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Bahan', style: teks.titleLarge),
        Text('${resep.nama} · ${resep.porsi} porsi', style: teks.bodySmall),
        const SizedBox(height: AppSpacing.m),
        for (final b in resep.bahan)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs + 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                byId[b.bahanId] == null
                    ? const SizedBox.square(dimension: 24)
                    : IkonBahan.dari(byId[b.bahanId]!, ukuran: 24),
                const SizedBox(width: AppSpacing.m),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        byId[b.bahanId]?.nama ?? b.bahanId,
                        style: teks.titleSmall,
                      ),
                      Text(
                        b.opsional ? '${b.takaran} (opsional)' : b.takaran,
                        style: teks.bodyMedium?.copyWith(color: p.tintaLembut),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: AppSpacing.m),
        const AksiTutupLembar(),
      ],
    );
  }
}

/// Hujan magnet warna-warni sekali jalan di layar selesai. Tidak tampil
/// bila pengguna mematikan animasi.
class HujanMagnet extends StatefulWidget {
  const HujanMagnet({super.key});

  @override
  State<HujanMagnet> createState() => _HujanMagnetState();
}

class _HujanMagnetState extends State<HujanMagnet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animasi = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );
  bool _dimulai = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_dimulai) {
      _dimulai = true;
      if (!MediaQuery.disableAnimationsOf(context)) _animasi.forward();
    }
  }

  @override
  void dispose() {
    _animasi.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: AnimatedBuilder(
        animation: _animasi,
        builder: (_, _) => _animasi.isAnimating
            ? CustomPaint(painter: _HujanPainter(_animasi.value))
            : const SizedBox.expand(),
      ),
    );
  }
}

class _HujanPainter extends CustomPainter {
  final double t;

  const _HujanPainter(this.t);

  static const _jumlah = 22;

  @override
  void paint(Canvas canvas, Size size) {
    final acak = Random(11);
    for (var i = 0; i < _jumlah; i++) {
      final x = acak.nextDouble();
      final tunda = acak.nextDouble() * 0.35;
      final laju = 0.9 + acak.nextDouble() * 0.5;
      final putar = (acak.nextDouble() - 0.5) * 8;
      final lebar = 14 + acak.nextDouble() * 12;
      final kategori = KategoriBahan.values[i % KategoriBahan.values.length];
      final maju = ((t - tunda) / (1 - tunda)).clamp(0.0, 1.0) * laju;
      if (maju <= 0) continue;
      final pudar = (1 - (maju - 0.75) * 4).clamp(0.0, 1.0);
      canvas
        ..save()
        ..translate(
          size.width * x + sin(maju * 6 + i) * 12,
          -20 + (size.height + 40) * Curves.easeIn.transform(maju.clamp(0, 1)),
        )
        ..rotate(putar * maju);
      final magnet = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: lebar, height: lebar * 0.6),
        Radius.circular(lebar * 0.3),
      );
      canvas
        ..drawRRect(
          magnet,
          Paint()..color = AppColors.magnet(kategori).withValues(alpha: pudar),
        )
        ..drawRRect(
          magnet,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.2
            ..color = AppColors.tinta.withValues(alpha: pudar * 0.8),
        )
        ..restore();
    }
  }

  @override
  bool shouldRepaint(_HujanPainter lama) => lama.t != t;
}
