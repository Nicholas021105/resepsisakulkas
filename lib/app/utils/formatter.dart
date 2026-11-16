import 'package:intl/intl.dart';

import '../data/models/katalog_model.dart';

/// Contoh: "13 Okt 10.20".
String formatWaktuDiperbarui(DateTime waktu) =>
    DateFormat('d MMM HH.mm', 'id_ID').format(waktu);

/// Waktu memasak relatif terhadap [kini]: "Hari ini, 18.30",
/// "Kemarin, 07.05", atau "13 Okt, 10.20".
String formatWaktuMasak(DateTime waktu, DateTime kini) {
  final jam = DateFormat('HH.mm', 'id_ID').format(waktu);
  final selisih = DateTime.utc(
    kini.year,
    kini.month,
    kini.day,
  ).difference(DateTime.utc(waktu.year, waktu.month, waktu.day)).inDays;
  return switch (selisih) {
    0 => 'Hari ini, $jam',
    1 => 'Kemarin, $jam',
    _ => '${DateFormat('d MMM', 'id_ID').format(waktu)}, $jam',
  };
}

/// Contoh: "Server · diperbarui 13 Okt 10.20", "Data bawaan".
String labelSumber(SumberData sumber, DateTime? waktu) => waktu == null
    ? sumber.label
    : '${sumber.label} · diperbarui ${formatWaktuDiperbarui(waktu)}';
