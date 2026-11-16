import '../data/models/bahan_model.dart';
import '../data/models/hasil_cocok.dart';
import '../data/models/katalog_model.dart';
import '../data/models/resep_model.dart';

/// Resep yang memakai bahan "segera habiskan" hanya dinaikkan peringkatnya
/// bila memang hampir bisa dimasak: kurang paling banyak sekian bahan.
const batasKurangPrioritas = 2;

/// Mencocokkan satu resep dengan isi kulkas (rencana bagian 6).
///
/// - Bahan opsional tidak dihitung.
/// - Jika [bumbuDasarAda], bahan berlabel bumbu dasar dianggap dimiliki.
/// - persen = dimiliki / bahanWajib × 100 (dibulatkan).
/// - [segera] (bahan yang perlu segera dihabiskan) TIDAK mengubah persen;
///   hanya dicatat di [HasilCocok.segera] untuk peringkat dan label.
HasilCocok cocokkanResep(
  Resep resep,
  Set<String> bahanDiKulkas,
  Map<String, Bahan> bahanById, {
  required bool bumbuDasarAda,
  Set<String> segera = const {},
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
    segera: [
      for (final b in resep.bahan)
        if (segera.contains(b.bahanId) && bahanDiKulkas.contains(b.bahanId))
          b.bahanId,
    ],
  );
}

/// Resep ini dinaikkan ke kelompok teratas: memakai bahan yang segera habis
/// dan kurang paling banyak [batasKurangPrioritas] bahan.
bool diprioritaskan(HasilCocok h) =>
    h.pakaiSegera && h.kurang.length <= batasKurangPrioritas;

int _bandingCocok(HasilCocok a, HasilCocok b) {
  final prioritas = (diprioritaskan(b) ? 1 : 0) - (diprioritaskan(a) ? 1 : 0);
  if (prioritas != 0) return prioritas;
  final persen = b.persen.compareTo(a.persen);
  if (persen != 0) return persen;
  final segera = b.segera.length.compareTo(a.segera.length);
  if (segera != 0) return segera;
  final kurang = a.kurang.length.compareTo(b.kurang.length);
  if (kurang != 0) return kurang;
  return a.resep.waktuMenit.compareTo(b.resep.waktuMenit);
}

/// Semua resep diurutkan: persen ↓, jumlah bahan kurang ↑, waktu masak ↑.
///
/// Bila ada bahan [segera], resep yang memakainya dan hampir bisa dimasak
/// (lihat [diprioritaskan]) naik ke kelompok teratas; di dalam kelompok,
/// urutan di atas tetap berlaku (lalu yang memakai lebih banyak bahan
/// segera). Tanpa bahan segera, urutan persis seperti sebelumnya.
List<HasilCocok> cocokkanSemua(
  Katalog katalog,
  Set<String> bahanDiKulkas, {
  required bool bumbuDasarAda,
  Set<String> segera = const {},
}) {
  final bahanById = katalog.bahanById;
  final hasil = [
    for (final r in katalog.resep)
      cocokkanResep(
        r,
        bahanDiKulkas,
        bahanById,
        bumbuDasarAda: bumbuDasarAda,
        segera: segera,
      ),
  ];
  hasil.sort(_bandingCocok);
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

/// Jelajah: saring menurut kategori hidangan dan kata kunci. Kata kunci
/// dicocokkan (tanpa membedakan huruf besar) dengan nama resep ATAU nama
/// salah satu bahannya, jadi "tempe" menemukan Orek Tempe maupun Sayur
/// Lodeh. Beberapa kata harus cocok semua. Urutan [hasil] dipertahankan.
List<HasilCocok> jelajahResep(
  List<HasilCocok> hasil, {
  String kataKunci = '',
  KategoriResep? kategori,
  Map<String, Bahan> bahanById = const {},
}) {
  final kata = kataKunci
      .toLowerCase()
      .split(RegExp(r'\s+'))
      .where((k) => k.isNotEmpty)
      .toList();
  if (kata.isEmpty && kategori == null) return hasil;
  return hasil.where((h) {
    if (kategori != null && h.resep.kategori != kategori) return false;
    if (kata.isEmpty) return true;
    final teks = [
      h.resep.nama,
      for (final b in h.resep.bahan) bahanById[b.bahanId]?.nama ?? b.bahanId,
    ].join(' ').toLowerCase();
    return kata.every(teks.contains);
  }).toList();
}

/// Mengurutkan ulang hasil (yang sudah berurutan "paling cocok"). Pengurutan
/// stabil: resep yang setara tetap dalam urutan kecocokannya.
List<HasilCocok> urutkanHasil(List<HasilCocok> hasil, UrutanResep urutan) {
  if (urutan == UrutanResep.cocok) return hasil;
  final berindeks = [for (var i = 0; i < hasil.length; i++) (i, hasil[i])];
  berindeks.sort((a, b) {
    final ra = a.$2.resep, rb = b.$2.resep;
    var banding = 0;
    if (urutan == UrutanResep.termudah) {
      banding = ra.tingkat.index.compareTo(rb.tingkat.index);
    }
    if (banding == 0) banding = ra.waktuMenit.compareTo(rb.waktuMenit);
    return banding != 0 ? banding : a.$1.compareTo(b.$1);
  });
  return [for (final e in berindeks) e.$2];
}

/// "Masak apa hari ini?": satu saran dari beberapa kandidat terbaik.
///
/// Kandidat = [maksKandidat] resep teratas (menurut urutan kecocokan, jadi
/// yang memakai bahan segera habis lebih dulu) yang kurang paling banyak
/// [batasKurangPrioritas] bahan; bila kulkas kosong/tidak ada yang hampir
/// cocok, SEMUA resep jadi kandidat (inspirasi). [benih] memilih di antara
/// kandidat: sama sepanjang hari, bergeser saat pengguna minta saran lain.
HasilCocok? saranHariIni(
  List<HasilCocok> hasil, {
  required int benih,
  int maksKandidat = 5,
}) {
  if (hasil.isEmpty) return null;
  final hampir = hasil
      .where((h) => h.persen > 0 && h.kurang.length <= batasKurangPrioritas)
      .toList();
  // Tanpa kandidat yang hampir cocok, seluruh katalog jadi inspirasi.
  final kandidat = hampir.isEmpty ? hasil : hampir.take(maksKandidat).toList();
  return kandidat[benih.abs() % kandidat.length];
}
