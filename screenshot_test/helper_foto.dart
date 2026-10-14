import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Kunci RepaintBoundary di sekeliling aplikasi (termasuk dialog & sheet).
const kunciLayar = Key('layar');

/// Keluarga font fallback emoji khusus render screenshot.
const fontEmoji = 'SegoeEmoji';

Future<void> _muat(String keluarga, Future<ByteData> data) async {
  final loader = FontLoader(keluarga)..addFont(data);
  await loader.load();
}

/// Memuat font asli aplikasi + MaterialIcons (dari asset bundle) + emoji
/// Windows sebagai fallback, supaya teks tidak tampil sebagai kotak.
Future<void> muatFont(Map<String, List<String>> fontAplikasi) async {
  for (final f in fontAplikasi.entries) {
    final loader = FontLoader(f.key);
    for (final aset in f.value) {
      loader.addFont(rootBundle.load(aset));
    }
    await loader.load();
  }
  await _muat(
    'MaterialIcons',
    rootBundle.load('fonts/MaterialIcons-Regular.otf'),
  );
  final emoji = File('C:/Windows/Fonts/seguiemj.ttf');
  if (emoji.existsSync()) {
    await _muat(
      fontEmoji,
      Future.value(ByteData.sublistView(emoji.readAsBytesSync())),
    );
  }
}

/// Tema + fallback emoji (hanya untuk render di test; di HP sistem yang
/// menyediakan fallback emoji).
ThemeData denganEmoji(ThemeData tema) {
  TextStyle? f(TextStyle? s) =>
      s?.copyWith(fontFamilyFallback: const [fontEmoji]);
  return tema.copyWith(
    textTheme: tema.textTheme.apply(fontFamilyFallback: const [fontEmoji]),
    dialogTheme: tema.dialogTheme.copyWith(
      titleTextStyle: f(tema.dialogTheme.titleTextStyle),
      contentTextStyle: f(tema.dialogTheme.contentTextStyle),
    ),
  );
}

/// Layar 360×800 dp, devicePixelRatio 3, textScaler opsional.
void aturLayar(WidgetTester tester, {double skala = 1}) {
  tester.view.devicePixelRatio = 3;
  tester.view.physicalSize = const Size(360 * 3, 800 * 3);
  tester.platformDispatcher.textScaleFactorTestValue = skala;
  // Bayangan asli (bukan versi uji) agar screenshot sesuai tampilan HP.
  debugDisableShadows = false;
  addTearDown(() {
    tester.view.reset();
    tester.platformDispatcher.clearTextScaleFactorTestValue();
  });
}

/// Simpan screenshot ke `Tugas_flutter/screenshots/<app>/<nama>.png` pada
/// pixelRatio 3 (1080×2400), lalu kembalikan flag bayangan (wajib sebelum
/// test berakhir). `matchesGoldenFile` tidak dipakai karena merender pada
/// piksel logis (360×800).
Future<void> foto(WidgetTester tester, String app, String nama) async {
  final batas = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(kunciLayar),
  );
  await tester.runAsync(() async {
    final gambar = await batas.toImage(pixelRatio: 3);
    final png = await gambar.toByteData(format: ui.ImageByteFormat.png);
    gambar.dispose();
    // Direktori kerja `flutter test` adalah folder app.
    final berkas = File('../screenshots/$app/$nama.png');
    berkas.parent.createSync(recursive: true);
    berkas.writeAsBytesSync(png!.buffer.asUint8List());
  });
  debugDisableShadows = true;
}
