/// Durasi yang disebut di teks langkah memasak, untuk timer mode masak.
///
/// Mengenali "selama 10 menit", "sekitar 3 menit tiap sisi", "30 detik",
/// "1 jam". Rentang ("5–7 menit") memakai angka terkecil: timer berbunyi
/// saat masakan mulai perlu dicek, dan bisa ditambah semenit. Angka dengan
/// satuan lain ("400 ml", "2 sdm") diabaikan. Bila ada beberapa durasi,
/// yang pertama dipakai. Null bila langkah tidak menyebut durasi.
Duration? durasiLangkah(String teks) {
  final cocok = RegExp(
    r'(\d+)(?:\s*[–-]\s*\d+)?\s*(jam|menit|detik)\b',
    caseSensitive: false,
  ).firstMatch(teks);
  if (cocok == null) return null;
  final angka = int.parse(cocok.group(1)!);
  if (angka <= 0) return null;
  return switch (cocok.group(2)!.toLowerCase()) {
    'jam' => Duration(hours: angka),
    'menit' => Duration(minutes: angka),
    _ => Duration(seconds: angka),
  };
}

/// "05:00", "1:05:00".
String formatTimer(int detik) {
  final aman = detik < 0 ? 0 : detik;
  final j = aman ~/ 3600, m = aman % 3600 ~/ 60, d = aman % 60;
  String dua(int n) => n.toString().padLeft(2, '0');
  return j > 0 ? '$j:${dua(m)}:${dua(d)}' : '${dua(m)}:${dua(d)}';
}

/// Untuk pembaca layar: "5 menit 30 detik".
String ucapTimer(int detik) {
  final aman = detik < 0 ? 0 : detik;
  final j = aman ~/ 3600, m = aman % 3600 ~/ 60, d = aman % 60;
  final bagian = [
    if (j > 0) '$j jam',
    if (m > 0) '$m menit',
    if (d > 0 || (j == 0 && m == 0)) '$d detik',
  ];
  return bagian.join(' ');
}
