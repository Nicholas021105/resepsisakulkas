/// Satu baris daftar belanja.
class ItemBelanja {
  final String bahanId;
  final bool dibeli;

  /// Resep yang membuat bahan ini masuk daftar (null = ditambah manual).
  final String? resepId;

  /// Mencentang "dibeli" yang menempelkan bahan ini ke kulkas; dipakai
  /// agar membatalkan centang hanya melepas bahan yang memang baru masuk.
  final bool masukKulkas;

  const ItemBelanja({
    required this.bahanId,
    this.dibeli = false,
    this.resepId,
    this.masukKulkas = false,
  });

  ItemBelanja salin({bool? dibeli, bool? masukKulkas}) => ItemBelanja(
    bahanId: bahanId,
    dibeli: dibeli ?? this.dibeli,
    resepId: resepId,
    masukKulkas: masukKulkas ?? this.masukKulkas,
  );

  /// Null bila data tersimpan rusak (tanpa `bahanId`), bukan melempar.
  static ItemBelanja? cobaDariJson(Map<String, dynamic> json) {
    final id = json['bahanId'];
    if (id is! String || id.isEmpty) return null;
    final resep = json['resepId'];
    return ItemBelanja(
      bahanId: id,
      dibeli: json['dibeli'] == true,
      resepId: resep is String ? resep : null,
      masukKulkas: json['masukKulkas'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
    'bahanId': bahanId,
    'dibeli': dibeli,
    'resepId': ?resepId,
    'masukKulkas': masukKulkas,
  };
}

/// Satu catatan riwayat masak.
class CatatanMasak {
  final String resepId;

  /// Nama saat dimasak, supaya riwayat tetap terbaca walau resepnya kelak
  /// hilang dari katalog.
  final String nama;
  final DateTime waktu;

  const CatatanMasak({
    required this.resepId,
    required this.nama,
    required this.waktu,
  });

  static CatatanMasak? cobaDariJson(Map<String, dynamic> json) {
    final id = json['resepId'];
    final nama = json['nama'];
    final teksWaktu = json['waktu'];
    final waktu = DateTime.tryParse(teksWaktu is String ? teksWaktu : '');
    if (id is! String || id.isEmpty || waktu == null) return null;
    return CatatanMasak(
      resepId: id,
      nama: nama is String && nama.isNotEmpty ? nama : id,
      waktu: waktu,
    );
  }

  Map<String, dynamic> toJson() => {
    'resepId': resepId,
    'nama': nama,
    'waktu': waktu.toIso8601String(),
  };
}
