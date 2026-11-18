import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

/// Memasang [KomparatorToleran] untuk file golden test [namaBerkasTes]
/// (nama file di folder `test/`). Panggil di `setUpAll`; komparator asal
/// dikembalikan setelah semua tes di file itu selesai.
void pasangKomparatorToleran(String namaBerkasTes, {int perbesar = 2}) {
  final asal = goldenFileComparator;
  if (asal is! LocalFileComparator) return;
  goldenFileComparator = KomparatorToleran(
    asal.basedir.resolve(namaBerkasTes),
    perbesar: perbesar,
  );
  addTearDown(() => goldenFileComparator = asal);
}

/// Komparator golden dua tingkat yang membedakan antialiasing dari
/// perubahan gambar:
/// 1. piksel dianggap BERBEDA hanya bila selisih terbesar di salah satu
///    kanal RGBA > [ambangKanal];
/// 2. tes lulus bila jumlah piksel BERBEDA ≤ [batasPiksel] dari total.
///
/// Saat gagal, pesan menyebut jumlah & persentase piksel berbeda dan kotak
/// pembatas area yang berubah (px lembar dan dp), lalu menulis gambar
/// selisih ke `test/failures/` seperti komparator bawaan.
///
/// Dipakai bersama oleh golden ikon bahan dan golden sampul resep.
class KomparatorToleran extends LocalFileComparator {
  KomparatorToleran(super.testFile, {this.perbesar = 2});

  /// Selisih kanal (0–255) yang masih dianggap antialiasing: tepi garis
  /// antarmesin Windows berbeda beberapa belas tingkat, sedangkan
  /// pergantian warna isi (mis. tomat → cabai) berbeda puluhan tingkat.
  static const ambangKanal = 24;

  /// Bagian piksel BERBEDA (0–1) yang boleh ada: 0,02% ≈ 180 piksel di
  /// lembar ikon 48 dp, jauh di bawah luas isi satu ikon (± 3.000 piksel),
  /// tetapi cukup untuk segelintir piksel tepi yang lolos ambang kanal.
  static const batasPiksel = 0.0002;

  /// Pembesaran lembar golden, untuk mengubah koordinat piksel ke dp di
  /// pesan galat.
  final int perbesar;

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final bitaGolden = Uint8List.fromList(await getGoldenBytes(golden));
    final (lebar, tinggi, uji) = await _rgba(imageBytes);
    final (lebarG, tinggiG, acuan) = await _rgba(bitaGolden);
    if (lebar != lebarG || tinggi != tinggiG) {
      throw FlutterError(
        'Golden $golden: ukuran berbeda, ${lebar}x$tinggi px vs '
        'acuan ${lebarG}x$tinggiG px.',
      );
    }
    var beda = 0;
    var x0 = lebar, y0 = tinggi, x1 = -1, y1 = -1;
    for (var i = 0; i < uji.length; i += 4) {
      var maks = 0;
      for (var k = 0; k < 4; k++) {
        final d = (uji[i + k] - acuan[i + k]).abs();
        if (d > maks) maks = d;
      }
      if (maks <= ambangKanal) continue;
      beda++;
      final p = i ~/ 4, x = p % lebar, y = p ~/ lebar;
      if (x < x0) x0 = x;
      if (x > x1) x1 = x;
      if (y < y0) y0 = y;
      if (y > y1) y1 = y;
    }
    final total = lebar * tinggi;
    if (beda <= total * batasPiksel) return true;

    final persen = (beda / total * 100).toStringAsFixed(3);
    final hasil = await GoldenFileComparator.compareLists(
      imageBytes,
      bitaGolden,
    );
    final keluaran = await generateFailureOutput(hasil, golden, basedir);
    hasil.dispose();
    throw FlutterError(
      'Golden $golden: $beda piksel berbeda ($persen% dari $total; batas '
      '${batasPiksel * 100}%, selisih kanal > $ambangKanal).\n'
      'Kotak pembatas area berbeda: x $x0–$x1, y $y0–$y1 px '
      '(= x ${x0 ~/ perbesar}–${x1 ~/ perbesar}, '
      'y ${y0 ~/ perbesar}–${y1 ~/ perbesar} dp di lembar).\n$keluaran',
    );
  }

  static Future<(int, int, Uint8List)> _rgba(Uint8List png) async {
    final codec = await ui.instantiateImageCodec(png);
    final bingkai = await codec.getNextFrame();
    final citra = bingkai.image;
    final data = await citra.toByteData();
    final hasil = (citra.width, citra.height, data!.buffer.asUint8List());
    citra.dispose();
    codec.dispose();
    return hasil;
  }
}
