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

  const HasilCocok({
    required this.resep,
    required this.persen,
    required this.dimiliki,
    required this.kurang,
  });

  bool get siapDimasak => kurang.isEmpty;
}

enum FilterHasil {
  siap('Siap dimasak'),
  kurangSedikit('Kurang 1–2 bahan'),
  semua('Semua');

  const FilterHasil(this.label);

  final String label;
}
