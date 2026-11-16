import '../data/models/bahan_model.dart';
import '../data/models/belanja_model.dart';

/// Membaca daftar belanja tersimpan: baris rusak dan bahan ganda dibuang.
List<ItemBelanja> bacaDaftarBelanja(List<Map<String, dynamic>> mentah) {
  final terlihat = <String>{};
  return [
    for (final json in mentah)
      if (ItemBelanja.cobaDariJson(json) case final item?
          when terlihat.add(item.bahanId))
        item,
  ];
}

/// Menambah bahan ke daftar. Bahan yang sudah menunggu dibeli dilewati;
/// bahan yang sudah dicentang "dibeli" dikembalikan menjadi perlu dibeli
/// (pengguna ingin membelinya lagi). Mengembalikan daftar baru dan jumlah
/// bahan yang benar-benar ditambahkan.
({List<ItemBelanja> daftar, int ditambah}) tambahKeDaftar(
  List<ItemBelanja> daftar,
  Iterable<String> ids, {
  String? resepId,
}) {
  final hasil = [...daftar];
  var ditambah = 0;
  for (final id in ids.toSet()) {
    final i = hasil.indexWhere((e) => e.bahanId == id);
    if (i < 0) {
      hasil.add(ItemBelanja(bahanId: id, resepId: resepId));
      ditambah++;
    } else if (hasil[i].dibeli) {
      hasil[i] = ItemBelanja(bahanId: id, resepId: resepId);
      ditambah++;
    }
  }
  return (daftar: hasil, ditambah: ditambah);
}

/// Bahan dalam [ids] yang belum menunggu di daftar belanja.
Set<String> belumDiDaftar(List<ItemBelanja> daftar, Iterable<String> ids) {
  final menunggu = {
    for (final e in daftar)
      if (!e.dibeli) e.bahanId,
  };
  return ids.toSet().difference(menunggu);
}

/// Teks daftar belanja untuk disalin/dibagikan ke aplikasi lain.
String teksDaftarBelanja(
  List<ItemBelanja> daftar,
  Map<String, Bahan> bahanById,
) {
  String nama(ItemBelanja e) => bahanById[e.bahanId]?.nama ?? e.bahanId;
  final perlu = daftar.where((e) => !e.dibeli);
  final sudah = daftar.where((e) => e.dibeli);
  return [
    'Daftar belanja (ResepSisaKulkas)',
    for (final e in perlu) '☐ ${nama(e)}',
    if (sudah.isNotEmpty) ...[
      '',
      'Sudah dibeli:',
      for (final e in sudah) '☑ ${nama(e)}',
    ],
  ].join('\n');
}
