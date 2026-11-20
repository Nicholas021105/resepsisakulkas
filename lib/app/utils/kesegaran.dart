import '../data/models/bahan_model.dart';

/// Bahan otomatis dianggap "segera habiskan" saat sisa masa simpannya
/// tinggal sehari atau kurang.
const ambangSegeraHari = 1;

/// Umur bahan dalam hari kalender sejak ditempel (ditempel kemarin malam,
/// dilihat pagi ini = 1 hari). Tidak pernah negatif.
int umurHari(DateTime sejak, DateTime sekarang) {
  final awal = DateTime.utc(sejak.year, sejak.month, sejak.day);
  final kini = DateTime.utc(sekarang.year, sekarang.month, sekarang.day);
  final selisih = kini.difference(awal).inDays;
  return selisih < 0 ? 0 : selisih;
}

/// Sisa hari sebelum bahan melewati perkiraan masa simpannya. Negatif =
/// sudah lewat. Null bila bahan awet atau tanggal tempelnya tidak diketahui.
int? sisaHari(Bahan bahan, DateTime? sejak, DateTime sekarang) {
  final awet = bahan.awetHari;
  if (awet == null || sejak == null) return null;
  return awet - umurHari(sejak, sekarang);
}

/// Bahan di kulkas yang perlu segera dihabiskan: ditandai manual oleh
/// pengguna, atau otomatis karena mendekati/melewati masa simpan.
Set<String> hitungBahanSegera({
  required Set<String> kulkas,
  required Set<String> ditandai,
  required Map<String, DateTime> sejak,
  required Map<String, Bahan> bahanById,
  required DateTime sekarang,
}) {
  return {
    for (final id in kulkas)
      if (ditandai.contains(id) ||
          _segeraOtomatis(bahanById[id], sejak[id], sekarang))
        id,
  };
}

bool _segeraOtomatis(Bahan? bahan, DateTime? sejak, DateTime sekarang) {
  if (bahan == null) return false;
  final sisa = sisaHari(bahan, sejak, sekarang);
  return sisa != null && sisa <= ambangSegeraHari;
}

/// "hari ini", "kemarin", "3 hari lalu".
String sejakKapan(int umur) => switch (umur) {
  0 => 'hari ini',
  1 => 'kemarin',
  _ => '$umur hari lalu',
};

/// Kalimat kesegaran untuk lembar opsi bahan, mis.
/// "Ditempel 2 hari lalu · sebaiknya dipakai hari ini". Tanda manual
/// [ditandai] selalu disebut, juga di samping kalimat sisa hari.
String keteranganKesegaran(
  Bahan bahan,
  DateTime? sejak,
  DateTime sekarang, {
  required bool ditandai,
}) {
  final bagian = <String>[
    if (sejak != null) 'Ditempel ${sejakKapan(umurHari(sejak, sekarang))}',
  ];
  final sisa = sisaHari(bahan, sejak, sekarang);
  if (sisa != null) {
    bagian.add(switch (sisa) {
      < 0 => 'sudah lewat ${-sisa} hari dari perkiraan segar',
      0 => 'sebaiknya dipakai hari ini',
      1 => 'sebaiknya dipakai paling lambat besok',
      _ => 'kira-kira masih segar $sisa hari lagi',
    });
  }
  if (ditandai) {
    bagian.add('kamu tandai segera habiskan');
  } else if (sisa == null && bahan.awetHari == null) {
    bagian.add('bahan awet');
  }
  return bagian.join(' · ');
}

/// Label kartu/detail resep, mis. "Pakai bayam yang segera habis".
String labelPakaiSegera(List<String> namaBahan) => switch (namaBahan.length) {
  0 => '',
  1 => 'Pakai ${namaBahan[0].toLowerCase()} yang segera habis',
  2 =>
    'Pakai ${namaBahan[0].toLowerCase()} & ${namaBahan[1].toLowerCase()} '
        'yang segera habis',
  _ => 'Pakai ${namaBahan.length} bahan yang segera habis',
};
