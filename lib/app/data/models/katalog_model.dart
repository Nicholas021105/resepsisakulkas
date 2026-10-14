import 'bahan_model.dart';
import 'resep_model.dart';

/// Seluruh isi resep.json: daftar bahan master dan resep.
class Katalog {
  final int versi;
  final List<Bahan> bahan;
  final List<Resep> resep;

  const Katalog({
    required this.versi,
    required this.bahan,
    required this.resep,
  });

  Map<String, Bahan> get bahanById => {for (final b in bahan) b.id: b};

  Resep? resepById(String id) {
    for (final r in resep) {
      if (r.id == id) return r;
    }
    return null;
  }

  factory Katalog.fromJson(Map<String, dynamic> json) {
    return Katalog(
      versi: json['versi'] as int,
      bahan: (json['bahan'] as List<dynamic>)
          .map((e) => Bahan.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      resep: (json['resep'] as List<dynamic>)
          .map((e) => Resep.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'versi': versi,
    'bahan': bahan.map((b) => b.toJson()).toList(),
    'resep': resep.map((r) => r.toJson()).toList(),
  };
}

enum SumberData {
  server('Server'),
  cache('Cache'),
  bawaan('Data bawaan');

  const SumberData(this.label);

  final String label;
}

/// Hasil pengambilan katalog oleh repository.
class HasilAmbil {
  final Katalog katalog;
  final SumberData sumber;

  /// Waktu data diambil dari server (null untuk data bawaan).
  final DateTime? waktu;

  const HasilAmbil({required this.katalog, required this.sumber, this.waktu});
}
