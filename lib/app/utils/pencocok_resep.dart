import '../data/models/bahan_model.dart';
import '../data/models/hasil_cocok.dart';
import '../data/models/katalog_model.dart';
import '../data/models/resep_model.dart';

/// Mencocokkan satu resep dengan isi kulkas (rencana bagian 6).
///
/// - Bahan opsional tidak dihitung.
/// - Jika [bumbuDasarAda], bahan berlabel bumbu dasar dianggap dimiliki.
/// - persen = dimiliki / bahanWajib × 100 (dibulatkan).
HasilCocok cocokkanResep(
  Resep resep,
  Set<String> bahanDiKulkas,
  Map<String, Bahan> bahanById, {
  required bool bumbuDasarAda,
}) {
  final wajib = resep.bahanWajib.map((b) => b.bahanId).toList();
  bool dimilikiBahan(String id) =>
      bahanDiKulkas.contains(id) ||
      (bumbuDasarAda && (bahanById[id]?.bumbuDasar ?? false));
  final dimiliki = wajib.where(dimilikiBahan).toList();
  final kurang = wajib.where((id) => !dimilikiBahan(id)).toList();
  final persen = wajib.isEmpty
      ? 100
      : (dimiliki.length / wajib.length * 100).round();
  return HasilCocok(
    resep: resep,
    persen: persen,
    dimiliki: dimiliki,
    kurang: kurang,
  );
}

/// Semua resep diurutkan: persen ↓, jumlah bahan kurang ↑, waktu masak ↑.
List<HasilCocok> cocokkanSemua(
  Katalog katalog,
  Set<String> bahanDiKulkas, {
  required bool bumbuDasarAda,
}) {
  final bahanById = katalog.bahanById;
  final hasil = [
    for (final r in katalog.resep)
      cocokkanResep(r, bahanDiKulkas, bahanById, bumbuDasarAda: bumbuDasarAda),
  ];
  hasil.sort((a, b) {
    final persen = b.persen.compareTo(a.persen);
    if (persen != 0) return persen;
    final kurang = a.kurang.length.compareTo(b.kurang.length);
    if (kurang != 0) return kurang;
    return a.resep.waktuMenit.compareTo(b.resep.waktuMenit);
  });
  return hasil;
}

/// Menyaring hasil sesuai filter. Resep 0% tidak tampil di "Semua",
/// kecuali kulkas masih kosong.
List<HasilCocok> saringHasil(
  List<HasilCocok> hasil,
  FilterHasil filter, {
  required bool kulkasKosong,
}) {
  return switch (filter) {
    FilterHasil.siap => hasil.where((h) => h.siapDimasak).toList(),
    FilterHasil.kurangSedikit =>
      hasil.where((h) => h.kurang.isNotEmpty && h.kurang.length <= 2).toList(),
    FilterHasil.semua =>
      kulkasKosong ? hasil : hasil.where((h) => h.persen > 0).toList(),
  };
}
