enum KategoriBahan {
  protein('Protein'),
  sayur('Sayur'),
  karbohidrat('Karbohidrat'),
  bumbu('Bumbu');

  const KategoriBahan(this.label);

  final String label;
}

/// Nilai enum bernama [nama]; nama yang tidak dikenal (mis. dari katalog
/// server yang lebih baru) jatuh ke [cadangan], bukan melempar.
T enumAtau<T extends Enum>(List<T> nilai, Object? nama, T cadangan) {
  for (final n in nilai) {
    if (n.name == nama) return n;
  }
  return cadangan;
}

class Bahan {
  final String id;
  final String nama;
  final KategoriBahan kategori;
  final String emoji;

  /// Garam, gula, minyak goreng, air: boleh dianggap selalu ada.
  final bool bumbuDasar;

  /// Perkiraan berapa hari bahan tetap enak di kulkas sejak ditempel.
  /// Null = awet (bumbu kering, mie instan, …): tidak pernah otomatis
  /// ditandai "segera habiskan". Field opsional sejak katalog versi 2.
  final int? awetHari;

  const Bahan({
    required this.id,
    required this.nama,
    required this.kategori,
    required this.emoji,
    this.bumbuDasar = false,
    this.awetHari,
  });

  factory Bahan.fromJson(Map<String, dynamic> json) {
    final awet = json['awetHari'];
    return Bahan(
      id: json['id'] as String,
      nama: json['nama'] as String,
      kategori: enumAtau(
        KategoriBahan.values,
        json['kategori'],
        KategoriBahan.bumbu,
      ),
      emoji: json['emoji'] as String,
      bumbuDasar: json['bumbuDasar'] as bool? ?? false,
      awetHari: awet is num && awet > 0 ? awet.toInt() : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nama': nama,
    'kategori': kategori.name,
    'emoji': emoji,
    'bumbuDasar': bumbuDasar,
    'awetHari': ?awetHari,
  };
}
