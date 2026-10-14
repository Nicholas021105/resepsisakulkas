import 'package:resepsisakulkas/app/data/models/bahan_model.dart';
import 'package:resepsisakulkas/app/data/models/katalog_model.dart';
import 'package:resepsisakulkas/app/data/models/resep_model.dart';

Bahan bahan(String id, KategoriBahan k, {bool dasar = false}) =>
    Bahan(id: id, nama: id, kategori: k, emoji: '•', bumbuDasar: dasar);

BahanResep pakai(String id, {bool opsional = false}) =>
    BahanResep(bahanId: id, takaran: '1', opsional: opsional);

Resep resep(String id, List<BahanResep> b, {int waktu = 10}) => Resep(
  id: id,
  nama: id,
  deskripsi: '-',
  waktuMenit: waktu,
  porsi: 1,
  tingkat: TingkatResep.mudah,
  bahan: b,
  langkah: const ['a', 'b', 'c'],
);

/// Katalog kecil untuk unit test.
Katalog katalogKecil() => Katalog(
  versi: 1,
  bahan: [
    bahan('telur', KategoriBahan.protein),
    bahan('tempe', KategoriBahan.protein),
    bahan('kecap', KategoriBahan.bumbu),
    bahan('tomat', KategoriBahan.sayur),
    bahan('garam', KategoriBahan.bumbu, dasar: true),
    bahan('minyak', KategoriBahan.bumbu, dasar: true),
  ],
  resep: [
    // telur + garam + minyak (+ tomat opsional)
    resep('dadar', [
      pakai('telur'),
      pakai('garam'),
      pakai('minyak'),
      pakai('tomat', opsional: true),
    ], waktu: 10),
    // tempe + kecap + minyak
    resep('orek', [pakai('tempe'), pakai('kecap'), pakai('minyak')], waktu: 25),
    // telur + tempe + tomat + kecap
    resep('campur', [
      pakai('telur'),
      pakai('tempe'),
      pakai('tomat'),
      pakai('kecap'),
    ], waktu: 20),
    // telur + kecap, lebih cepat dari 'campur'
    resep('telur-kecap', [pakai('telur'), pakai('kecap')], waktu: 5),
  ],
);
