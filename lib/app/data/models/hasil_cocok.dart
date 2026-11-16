import 'resep_model.dart';

/// Hasil pencocokan satu resep dengan isi kulkas. Selalu dihitung, tidak
/// pernah disimpan.
class HasilCocok {
  final Resep resep;
  final int persen;

  /// Id bahan wajib yang sudah dimiliki.
  final List<String> dimiliki;

  /// Id bahan wajib yang belum dimiliki.
  final List<String> kurang;

  /// Id bahan di kulkas yang "segera habiskan" dan dipakai resep ini (wajib
  /// maupun opsional). Tidak memengaruhi [persen]; hanya menaikkan
  /// peringkat dan memunculkan label.
  final List<String> segera;

  const HasilCocok({
    required this.resep,
    required this.persen,
    required this.dimiliki,
    required this.kurang,
    this.segera = const [],
  });

  bool get siapDimasak => kurang.isEmpty;

  bool get pakaiSegera => segera.isNotEmpty;
}

enum FilterHasil {
  siap('Siap dimasak'),
  kurangSedikit('Kurang 1–2 bahan'),
  semua('Semua');

  const FilterHasil(this.label);

  final String label;
}

/// Urutan daftar resep di tab Resep.
enum UrutanResep {
  cocok('Paling cocok', 'Persentase kecocokan tertinggi dulu'),
  tercepat('Tercepat', 'Waktu masak paling singkat dulu'),
  termudah('Termudah', 'Tingkat mudah dulu, lalu yang tercepat');

  const UrutanResep(this.label, this.keterangan);

  final String label;
  final String keterangan;
}
