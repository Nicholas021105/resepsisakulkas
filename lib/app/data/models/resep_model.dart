enum TingkatResep {
  mudah('Mudah'),
  sedang('Sedang');

  const TingkatResep(this.label);

  final String label;
}

class BahanResep {
  final String bahanId;
  final String takaran;

  /// Bahan opsional tidak memengaruhi persentase kecocokan.
  final bool opsional;

  const BahanResep({
    required this.bahanId,
    required this.takaran,
    this.opsional = false,
  });

  factory BahanResep.fromJson(Map<String, dynamic> json) {
    return BahanResep(
      bahanId: json['bahanId'] as String,
      takaran: json['takaran'] as String,
      opsional: json['opsional'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'bahanId': bahanId,
    'takaran': takaran,
    'opsional': opsional,
  };
}

class Resep {
  final String id;
  final String nama;
  final String deskripsi;
  final int waktuMenit;
  final int porsi;
  final TingkatResep tingkat;
  final List<BahanResep> bahan;
  final List<String> langkah;

  const Resep({
    required this.id,
    required this.nama,
    required this.deskripsi,
    required this.waktuMenit,
    required this.porsi,
    required this.tingkat,
    required this.bahan,
    required this.langkah,
  });

  Iterable<BahanResep> get bahanWajib => bahan.where((b) => !b.opsional);

  factory Resep.fromJson(Map<String, dynamic> json) {
    return Resep(
      id: json['id'] as String,
      nama: json['nama'] as String,
      deskripsi: json['deskripsi'] as String,
      waktuMenit: json['waktuMenit'] as int,
      porsi: json['porsi'] as int,
      tingkat: TingkatResep.values.byName(json['tingkat'] as String),
      bahan: (json['bahan'] as List<dynamic>)
          .map((e) => BahanResep.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      langkah: (json['langkah'] as List<dynamic>).cast<String>().toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nama': nama,
    'deskripsi': deskripsi,
    'waktuMenit': waktuMenit,
    'porsi': porsi,
    'tingkat': tingkat.name,
    'bahan': bahan.map((b) => b.toJson()).toList(),
    'langkah': langkah,
  };
}
