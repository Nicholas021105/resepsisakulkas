enum KategoriBahan {
  protein('Protein'),
  sayur('Sayur'),
  karbohidrat('Karbohidrat'),
  bumbu('Bumbu');

  const KategoriBahan(this.label);

  final String label;
}

class Bahan {
  final String id;
  final String nama;
  final KategoriBahan kategori;
  final String emoji;

  /// Garam, gula, minyak goreng, air: boleh dianggap selalu ada.
  final bool bumbuDasar;

  const Bahan({
    required this.id,
    required this.nama,
    required this.kategori,
    required this.emoji,
    this.bumbuDasar = false,
  });

  factory Bahan.fromJson(Map<String, dynamic> json) {
    return Bahan(
      id: json['id'] as String,
      nama: json['nama'] as String,
      kategori: KategoriBahan.values.byName(json['kategori'] as String),
      emoji: json['emoji'] as String,
      bumbuDasar: json['bumbuDasar'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nama': nama,
    'kategori': kategori.name,
    'emoji': emoji,
    'bumbuDasar': bumbuDasar,
  };
}
