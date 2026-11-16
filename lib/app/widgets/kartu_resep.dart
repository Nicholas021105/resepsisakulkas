import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/models/bahan_model.dart';
import '../data/models/hasil_cocok.dart';
import '../data/models/resep_model.dart';
import '../data/services/katalog_service.dart';
import '../modules/belanja/controllers/belanja_controller.dart';
import '../routes/app_routes.dart';
import '../theme/app_palet.dart';
import '../theme/app_spacing.dart';
import '../utils/kesegaran.dart';
import 'ikon_bahan.dart';
import 'kulkas_widgets.dart';
import 'sampul_resep.dart';
import 'umum_widgets.dart';

/// Tag Hero sampul resep. [sumber] membedakan kartu yang sama di tempat
/// berbeda (tab Resep, Favorit, saran), karena semua tab hidup bersamaan.
String tagSampul(String sumber, String resepId) => 'sampul-$sumber-$resepId';

/// Membuka detail resep; sampul "terbang" dari kartu ke halaman detail.
void bukaDetailResep(Resep resep, String sumber) => Get.toNamed(
  Routes.keDetail(resep.id),
  arguments: tagSampul(sumber, resep.id),
);

/// Sampul resep + cincin persentase menumpang di sudut kanan bawah.
class SampulDenganCincin extends StatelessWidget {
  final HasilCocok hasil;
  final String sumber;
  final double ukuran;

  const SampulDenganCincin({
    super.key,
    required this.hasil,
    required this.sumber,
    this.ukuran = AppSpacing.sampul,
  });

  static const _cincin = 42.0;
  static const _keluar = AppSpacing.s;

  @override
  Widget build(BuildContext context) {
    final p = context.palet;
    return SizedBox(
      width: ukuran + _keluar,
      height: ukuran + _keluar,
      child: Stack(
        children: [
          Hero(
            tag: tagSampul(sumber, hasil.resep.id),
            child: SampulResep(resep: hasil.resep, ukuran: ukuran),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: p.permukaan,
                shape: BoxShape.circle,
              ),
              child: CincinPersen(persen: hasil.persen, ukuran: _cincin),
            ),
          ),
        ],
      ),
    );
  }
}

/// Kartu resep: strip status di kiri, sampul bergambar + cincin persentase,
/// nama, info singkat, pratinjau bahan, label "segera habis", dan chip
/// bahan yang kurang (dengan tombol tambah ke belanja).
class KartuResep extends StatelessWidget {
  final HasilCocok hasil;

  /// Tempat kartu ini tampil (untuk tag Hero).
  final String sumber;

  const KartuResep({super.key, required this.hasil, this.sumber = 'resep'});

  static const lebarStrip = 4.0;

  @override
  Widget build(BuildContext context) {
    final teks = Theme.of(context).textTheme;
    final p = context.palet;
    final r = hasil.resep;
    final byId = Get.find<KatalogService>().katalog.value?.bahanById ?? {};
    final namaKurang = [for (final id in hasil.kurang) byId[id]?.nama ?? id];
    final radius = BorderRadius.circular(AppSpacing.radiusM);
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.m),
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: p.bayanganKartu,
      ),
      child: Material(
        color: p.permukaan,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(color: p.garis, width: 0.6),
        ),
        child: InkWell(
          key: Key('resep-${r.id}'),
          onTap: () => bukaDetailResep(r, sumber),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.m + lebarStrip,
                  AppSpacing.m,
                  AppSpacing.m,
                  AppSpacing.m,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SampulDenganCincin(hasil: hasil, sumber: sumber),
                    const SizedBox(width: AppSpacing.m),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r.nama,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: teks.titleLarge,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${r.waktuMenit} menit · ${r.porsi} porsi · '
                            '${r.tingkat.label}',
                            style: teks.bodySmall,
                          ),
                          const SizedBox(height: AppSpacing.s),
                          _PratinjauBahan(hasil: hasil, byId: byId),
                          const SizedBox(height: AppSpacing.s),
                          if (hasil.pakaiSegera) ...[
                            LabelSegera(hasil: hasil, byId: byId),
                            const SizedBox(height: AppSpacing.xs),
                          ],
                          hasil.siapDimasak
                              ? const ChipStatus(
                                  teks: '✓ Semua bahan ada',
                                  kurang: false,
                                )
                              : Row(
                                  children: [
                                    Flexible(
                                      child: ChipStatus(
                                        teks:
                                            'kurang: ${namaKurang.join(', ')}',
                                        kurang: true,
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.xs),
                                    TombolBelanja(hasil: hasil),
                                  ],
                                ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Strip status: hijau 100%, kuning 50–99%, abu < 50%.
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: lebarStrip,
                child: ColoredBox(color: p.cincin(hasil.persen)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tombol kecil di kartu: tambah bahan yang kurang ke daftar belanja. Bila
/// semuanya sudah di daftar, berubah menjadi pintasan ke tab Belanja.
class TombolBelanja extends StatelessWidget {
  final HasilCocok hasil;

  const TombolBelanja({super.key, required this.hasil});

  @override
  Widget build(BuildContext context) {
    final belanja = Get.find<BelanjaController>();
    final p = context.palet;
    return Obx(() {
      final sudah = belanja.belumAda(hasil.kurang).isEmpty;
      return IconButton(
        key: Key('belanja-${hasil.resep.id}'),
        tooltip: sudah
            ? 'Sudah di daftar belanja, buka daftar'
            : 'Tambah bahan kurang ke daftar belanja',
        onPressed: sudah
            ? belanja.bukaTab
            : () => belanja.tambahDariResep(hasil),
        icon: Icon(
          sudah ? Icons.shopping_basket : Icons.add_shopping_cart,
          color: sudah ? p.aksenTua : p.wortelTeks,
        ),
      );
    });
  }
}

/// Label kuning "Pakai … yang segera habis" untuk resep penyelamat bahan.
class LabelSegera extends StatelessWidget {
  final HasilCocok hasil;
  final Map<String, Bahan> byId;

  const LabelSegera({super.key, required this.hasil, required this.byId});

  @override
  Widget build(BuildContext context) {
    final p = context.palet;
    return LabelPil(
      key: Key('segera-${hasil.resep.id}'),
      ikon: Icons.hourglass_bottom,
      teks: labelPakaiSegera([
        for (final id in hasil.segera) byId[id]?.nama ?? id,
      ]),
      latar: p.pisangLembut,
      warna: p.pisangTeks,
    );
  }
}

/// Chip kecil status bahan: mint ("Semua bahan ada") atau wortel ("kurang").
class ChipStatus extends StatelessWidget {
  final String teks;
  final bool kurang;

  const ChipStatus({super.key, required this.teks, required this.kurang});

  @override
  Widget build(BuildContext context) {
    final p = context.palet;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s + 2,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: kurang ? p.wortelLembut : p.aksenLembut,
        borderRadius: BorderRadius.circular(AppSpacing.radiusS),
      ),
      child: Text(
        teks,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelMedium
            ?.copyWith(color: kurang ? p.wortelTeks : p.aksenTua),
      ),
    );
  }
}

/// Maksimal 5 ikon bahan wajib (bumbu dasar di belakang). Bahan yang kurang
/// diberi lingkaran wortel tipis; sisanya ditampilkan sebagai "+n".
class _PratinjauBahan extends StatelessWidget {
  final HasilCocok hasil;
  final Map<String, Bahan> byId;

  const _PratinjauBahan({required this.hasil, required this.byId});

  static const maks = 5;
  static const ukuranIkon = 20.0;
  static const ukuranSlot = 26.0;

  @override
  Widget build(BuildContext context) {
    final p = context.palet;
    final wajib = [
      for (final b in hasil.resep.bahan)
        if (!b.opsional && byId[b.bahanId] != null) byId[b.bahanId]!,
    ];
    // Bahan utama dulu, bumbu dasar (garam, minyak, …) paling belakang.
    final urut = [
      ...wajib.where((b) => !b.bumbuDasar),
      ...wajib.where((b) => b.bumbuDasar),
    ];
    final tampil = urut.take(maks).toList();
    final sisa = urut.length - tampil.length;
    final kurang = hasil.kurang.toSet();
    return Wrap(
      key: Key('pratinjau-${hasil.resep.id}'),
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final b in tampil)
          Container(
            key: Key('pratinjau-${hasil.resep.id}-${b.id}'),
            width: ukuranSlot,
            height: ukuranSlot,
            alignment: Alignment.center,
            decoration: kurang.contains(b.id)
                ? BoxDecoration(
                    color: p.wortelLembut,
                    shape: BoxShape.circle,
                    border: Border.all(color: p.wortel, width: 1.2),
                  )
                : null,
            child: IkonBahan.dari(b, ukuran: ukuranIkon),
          ),
        if (sisa > 0)
          Text(
            '+$sisa',
            style: Theme.of(context).textTheme.labelMedium
                ?.copyWith(color: p.tintaLembut),
          ),
      ],
    );
  }
}
