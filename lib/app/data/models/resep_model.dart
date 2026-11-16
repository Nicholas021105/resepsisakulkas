import 'bahan_model.dart';

enum TingkatResep {
  mudah('Mudah'),
  sedang('Sedang'),
  sulit('Sulit');

  const TingkatResep(this.label);

  final String label;
}

/// Kategori hidangan untuk jelajah resep. Opsional sejak katalog versi 2;
/// resep tanpa kategori masuk [lainnya].
enum KategoriResep {
  sarapan('Sarapan'),
  lauk('Lauk'),
  sayur('Sayur'),
  nasiMie('Nasi & mie'),
  camilan('Camilan'),
  pelengkap('Sambal & pelengkap'),
  lainnya('Lainnya');

  const KategoriResep(this.label);

  final String label;
}

/// Bentuk sajian, menentukan ilustrasi sampul resep (`SampulResep`).
/// Opsional sejak katalog versi 2; tanpa nilai memakai [piring].
enum JenisSajian {
  piring,
  goreng,
  tumis,
  kuah,
  nasi,
  mie,
  telur,
  sambal,
  manis,
  roti,
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
  final KategoriResep kategori;
  final JenisSajian sajian;
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
    this.kategori = KategoriResep.lainnya,
    this.sajian = JenisSajian.piring,
  });

  Iterable<BahanResep> get bahanWajib => bahan.where((b) => !b.opsional);

  /// Kompatibilitas skema:
  /// - `tingkat` selalu `mudah`/`sedang` agar aplikasi versi 1.0 (yang
  ///   hanya mengenal dua tingkat) tetap bisa membaca katalog; resep sulit
  ///   ditulis `"tingkat": "sedang", "tingkatV2": "sulit"`.
  /// - `kategori` dan `sajian` opsional; nilai tak dikenal memakai default.
  factory Resep.fromJson(Map<String, dynamic> json) {
    return Resep(
      id: json['id'] as String,
      nama: json['nama'] as String,
      deskripsi: json['deskripsi'] as String,
      waktuMenit: json['waktuMenit'] as int,
      porsi: json['porsi'] as int,
      tingkat: enumAtau(
        TingkatResep.values,
        json['tingkatV2'] ?? json['tingkat'],
        enumAtau(TingkatResep.values, json['tingkat'], TingkatResep.sedang),
      ),
      kategori: enumAtau(
        KategoriResep.values,
        json['kategori'],
        KategoriResep.lainnya,
      ),
      sajian: enumAtau(JenisSajian.values, json['sajian'], JenisSajian.piring),
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
    'tingkat': tingkat == TingkatResep.sulit
        ? TingkatResep.sedang.name
        : tingkat.name,
    if (tingkat == TingkatResep.sulit) 'tingkatV2': tingkat.name,
    if (kategori != KategoriResep.lainnya) 'kategori': kategori.name,
    if (sajian != JenisSajian.piring) 'sajian': sajian.name,
    'bahan': bahan.map((b) => b.toJson()).toList(),
    'langkah': langkah,
  };
}
