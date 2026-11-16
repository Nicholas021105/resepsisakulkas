import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../data/models/bahan_model.dart';
import '../../../data/models/belanja_model.dart';
import '../../../data/services/katalog_service.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_palet.dart';
import '../../../theme/app_spacing.dart';
import '../../../utils/notifikasi.dart';
import '../../../widgets/bottom_nav.dart';
import '../../../widgets/ikon_bahan.dart';
import '../../../widgets/kulkas_widgets.dart';
import '../../../widgets/magnet_bahan.dart';
import '../../../widgets/umum_widgets.dart';
import '../../kulkas/controllers/kulkas_controller.dart';
import '../controllers/belanja_controller.dart';

class BelanjaView extends GetView<BelanjaController> {
  const BelanjaView({super.key});

  void _bukaTambah() => bukaLembar<void>(const LembarTambahBelanja());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Belanja'),
        actions: [
          Obx(
            () => controller.daftar.isEmpty
                ? const SizedBox.shrink()
                : IconButton(
                    key: const Key('salin-belanja'),
                    tooltip: 'Salin daftar belanja',
                    onPressed: controller.salin,
                    icon: const Icon(Icons.copy_all_outlined),
                  ),
          ),
          const TombolPengaturan(),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.daftar.isEmpty) {
            return Center(
              child: SingleChildScrollView(
                child: KeadaanKosong(
                  key: const Key('belanja-kosong'),
                  ilustrasi: const IlustrasiKeranjang(),
                  judul: 'Daftar belanja masih kosong',
                  pesan:
                      'Tambahkan bahan yang kurang dari kartu atau halaman '
                      'resep, atau pilih sendiri bahannya.',
                  labelAksi: 'Tambah bahan',
                  onAksi: _bukaTambah,
                  kunciAksi: const Key('tambah-belanja-manual'),
                ),
              ),
            );
          }
          final perlu = controller.perluDibeli;
          final sudah = controller.sudahDibeli;
          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.l,
              AppSpacing.s,
              AppSpacing.l,
              AppSpacing.xxl,
            ),
            children: [
              JudulBagian('PERLU DIBELI (${perlu.length})'),
              if (perlu.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.m),
                  child: Text(
                    'Semua sudah dibeli. Selamat memasak!',
                    key: const Key('belanja-beres'),
                    style: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(color: context.palet.tintaLembut),
                  ),
                ),
              for (final item in perlu) _BarisBelanja(item: item),
              const SizedBox(height: AppSpacing.xs),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  key: const Key('tambah-belanja-manual'),
                  onPressed: _bukaTambah,
                  icon: const Icon(Icons.add),
                  label: const Text('Tambah bahan'),
                ),
              ),
              if (sudah.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.l),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: JudulBagian('SUDAH DIBELI (${sudah.length})'),
                    ),
                    TextButton(
                      key: const Key('bersihkan-dibeli'),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        controller.bersihkanDibeli();
                      },
                      child: const Text('Bersihkan'),
                    ),
                  ],
                ),
                for (final item in sudah) _BarisBelanja(item: item),
              ],
            ],
          );
        }),
      ),
    );
  }
}

/// Satu bahan belanja: ketuk baris untuk mencentang (langsung masuk
/// kulkas), geser atau tombol hapus untuk membuang dari daftar.
class _BarisBelanja extends GetView<BelanjaController> {
  final ItemBelanja item;

  const _BarisBelanja({required this.item});

  @override
  Widget build(BuildContext context) {
    final p = context.palet;
    final teks = Theme.of(context).textTheme;
    final bahan = controller.bahanById[item.bahanId];
    final nama = bahan?.nama ?? item.bahanId;
    final resep = item.resepId == null
        ? null
        : Get.find<KatalogService>().katalog.value?.resepById(item.resepId!);
    final keterangan = item.dibeli
        ? 'Sudah masuk kulkas'
        : (resep == null ? null : 'untuk ${resep.nama}');
    final radius = BorderRadius.circular(AppSpacing.radiusM);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s),
      child: Dismissible(
        key: ValueKey('geser-${item.bahanId}'),
        direction: DismissDirection.endToStart,
        onDismissed: (_) => controller.hapusDenganUrungkan(item.bahanId),
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
          decoration: BoxDecoration(
            color: p.bahayaLembut,
            borderRadius: radius,
          ),
          child: Icon(Icons.delete_outline, color: p.bahaya),
        ),
        child: Semantics(
          checked: item.dibeli,
          label: keterangan == null ? nama : '$nama, $keterangan',
          hint: item.dibeli
              ? 'Ketuk untuk membatalkan dan melepas dari kulkas'
              : 'Ketuk bila sudah dibeli; bahan langsung masuk kulkas',
          excludeSemantics: true,
          child: Material(
            color: p.permukaan,
            shape: RoundedRectangleBorder(
              borderRadius: radius,
              side: BorderSide(color: p.garis),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              key: Key('belanja-${item.bahanId}'),
              onTap: () {
                if (item.dibeli) {
                  HapticFeedback.selectionClick();
                } else {
                  HapticFeedback.mediumImpact();
                }
                controller.toggleDibeli(item.bahanId);
              },
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: AppSpacing.tombol),
                child: Padding(
                  padding: const EdgeInsets.only(left: AppSpacing.m),
                  child: Row(
                    children: [
                      _Centang(aktif: item.dibeli),
                      const SizedBox(width: AppSpacing.m),
                      bahan == null
                          ? const SizedBox.square(dimension: 28)
                          : IkonBahan.dari(bahan),
                      const SizedBox(width: AppSpacing.m),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.s,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                nama,
                                style: teks.titleMedium?.copyWith(
                                  color: item.dibeli ? p.tintaLembut : p.tinta,
                                  decoration: item.dibeli
                                      ? TextDecoration.lineThrough
                                      : null,
                                  decorationColor: p.tintaLembut,
                                ),
                              ),
                              if (keterangan != null)
                                Text(
                                  keterangan,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: teks.bodySmall?.copyWith(
                                    color: item.dibeli
                                        ? p.aksenTua
                                        : p.tintaLembut,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      IconButton(
                        key: Key('hapus-belanja-${item.bahanId}'),
                        tooltip: 'Hapus $nama dari daftar',
                        onPressed: () =>
                            controller.hapusDenganUrungkan(item.bahanId),
                        icon: Icon(Icons.close, color: p.tintaLembut),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Kotak centang bulat bergaya aplikasi.
class _Centang extends StatelessWidget {
  final bool aktif;

  const _Centang({required this.aktif});

  @override
  Widget build(BuildContext context) {
    final p = context.palet;
    return AnimatedContainer(
      duration: AppGerak.cepat,
      width: AppSpacing.xl,
      height: AppSpacing.xl,
      decoration: BoxDecoration(
        color: aktif ? p.aksenTua : AppColors.transparan,
        shape: BoxShape.circle,
        border: Border.all(
          color: aktif ? p.aksenTua : p.tintaLembut,
          width: 1.6,
        ),
      ),
      child: aktif ? Icon(Icons.check, size: 16, color: p.diAksen) : null,
    );
  }
}

/// Lembar "Tambah bahan": semua bahan yang belum ada di kulkas sebagai
/// magnet; ketuk untuk menambah/menghapus dari daftar belanja.
class LembarTambahBelanja extends StatefulWidget {
  const LembarTambahBelanja({super.key});

  @override
  State<LembarTambahBelanja> createState() => _LembarTambahBelanjaState();
}

class _LembarTambahBelanjaState extends State<LembarTambahBelanja> {
  String _kata = '';

  @override
  Widget build(BuildContext context) {
    final belanja = Get.find<BelanjaController>();
    final kulkas = Get.find<KulkasController>();
    final teks = Theme.of(context).textTheme;
    return Column(
      key: const Key('lembar-tambah-belanja'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Tambah ke daftar belanja', style: teks.titleLarge),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Bahan yang sudah ada di kulkas tidak ditampilkan.',
          style: teks.bodySmall,
        ),
        const SizedBox(height: AppSpacing.m),
        TextField(
          key: const Key('cari-belanja'),
          onChanged: (t) => setState(() => _kata = t.trim().toLowerCase()),
          textInputAction: TextInputAction.search,
          decoration: const InputDecoration(
            hintText: 'Cari bahan',
            prefixIcon: Icon(Icons.search),
          ),
        ),
        const SizedBox(height: AppSpacing.l),
        Obx(() {
          final pilihan = <Bahan>[
            for (final b in belanja.bahanById.values)
              if (!kulkas.bahanDimiliki.contains(b.id) &&
                  !b.bumbuDasar &&
                  (_kata.isEmpty || b.nama.toLowerCase().contains(_kata)))
                b,
          ];
          if (pilihan.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.l),
              child: Text(
                'Tidak ada bahan yang cocok.',
                textAlign: TextAlign.center,
                style: teks.bodyMedium?.copyWith(
                  color: context.palet.tintaLembut,
                ),
              ),
            );
          }
          return Wrap(
            spacing: AppSpacing.m,
            runSpacing: AppSpacing.m,
            children: [
              for (final b in pilihan)
                MagnetBahan(
                  key: Key('pilih-belanja-${b.id}'),
                  bahan: b,
                  dipilih: belanja.menunggu(b.id),
                  onTap: () => belanja.menunggu(b.id)
                      ? belanja.hapus(b.id)
                      : belanja.tambah([b.id]),
                ),
            ],
          );
        }),
        const SizedBox(height: AppSpacing.l),
        FilledButton(
          key: const Key('selesai-tambah-belanja'),
          onPressed: tutupOverlay,
          child: const Text('Selesai'),
        ),
      ],
    );
  }
}
