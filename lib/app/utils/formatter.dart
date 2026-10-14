import 'package:intl/intl.dart';

import '../data/models/katalog_model.dart';

/// Contoh: "13 Okt 10.20".
String formatWaktuDiperbarui(DateTime waktu) =>
    DateFormat('d MMM HH.mm', 'id_ID').format(waktu);

/// Contoh: "Server · diperbarui 13 Okt 10.20", "Data bawaan".
String labelSumber(SumberData sumber, DateTime? waktu) => waktu == null
    ? sumber.label
    : '${sumber.label} · diperbarui ${formatWaktuDiperbarui(waktu)}';
