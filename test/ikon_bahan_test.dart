import 'dart:convert';

import 'package:flutter/rendering.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resepsisakulkas/app/data/models/katalog_model.dart';
import 'package:resepsisakulkas/app/widgets/ikon_bahan.dart';

/// Emoji yang code point-nya baru ada di Unicode 13+ tampil sebagai kotak
/// kosong (tofu) di Android lama. Screenshot test tidak menangkapnya karena
/// memakai fallback Segoe UI Emoji, jadi dijaga di sini.
///
/// Rentang di bawah = code point emoji yang ditambahkan di Unicode 13–16.
/// Blok U+1FA70–1FAFF dibuat di Unicode 12; yang termasuk Unicode 12 hanya
/// yang dikecualikan di [_unicode12DiBlokFA].
const _rentangBaru = [
  (0x1F6D6, 0x1F6DF), // 🛖 🛗 (13), 🛝 🛞 🛟 (14), 🛜 (15)
  (0x1F6FB, 0x1F6FF), // 🛻 🛼 (13)
  (0x1F7EC, 0x1F7FF), // 🟰 (14)
  (0x1F90C, 0x1F90C), // 🤌 (13)
  (0x1F972, 0x1F972), // 🥲 (13)
  (0x1F977, 0x1F979), // 🥷 🥸 (13), 🥹 (14)
  (0x1F9A3, 0x1F9A4), // 🦣 🦤 (13)
  (0x1F9AB, 0x1F9AD), // 🦫 🦬 🦭 (13)
  (0x1F9CB, 0x1F9CC), // 🧋 (13), 🧌 (14)
  (0x1FA70, 0x1FAFF), // blok Symbols & Pictographs Ext-A (lihat pengecualian)
  (0x1FB00, 0x10FFFF), // Symbols for Legacy Computing (13) dan sesudahnya
];

const _unicode12DiBlokFA = [
  (0x1FA70, 0x1FA73), // 🩰 🩱 🩲 🩳
  (0x1FA78, 0x1FA7A), // 🩸 🩹 🩺
  (0x1FA80, 0x1FA82), // 🪀 🪁 🪂
  (0x1FA90, 0x1FA95), // 🪐 🪑 🪒 🪓 🪔 🪕
];

bool _dalam(int cp, List<(int, int)> rentang) =>
    rentang.any((r) => cp >= r.$1 && cp <= r.$2);

/// Code point sudah ada di Unicode ≤ 12 (aman di Android 11+, dan di
/// Android 10 untuk emoji 12).
bool unicodeMaks12(int cp) =>
    !_dalam(cp, _rentangBaru) || _dalam(cp, _unicode12DiBlokFA);

bool emojiAman(String emoji) => emoji.runes.every(unicodeMaks12);

/// Pengecualian eksplisit: id bahan yang boleh memakai emoji Unicode ≥ 13
/// tanpa pelukis. Sengaja kosong; isi hanya dengan alasan tertulis.
const pengecualian = <String>{};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('pemeriksa Unicode mengenali emoji baru dan lama', () {
    // Penyebab tofu di HP lama.
    expect(emojiAman('🫛'), isFalse, reason: 'U+1FADB Unicode 15');
    expect(emojiAman('🫗'), isFalse, reason: 'U+1FAD7 Unicode 14');
    expect(emojiAman('🫑'), isFalse, reason: 'U+1FAD1 Unicode 13');
    expect(emojiAman('🥲'), isFalse, reason: 'U+1F972 Unicode 13');
    // Aman (≤ 12), termasuk variation selector & blok FA versi 12.
    for (final e in ['🥚', '🧅', '🧄', '🦪', '🧈', '🥣', '🌶️', '🟫', '🪔']) {
      expect(emojiAman(e), isTrue, reason: e);
    }
  });

  test('setiap bahan di dataset punya pelukis atau emoji Unicode ≤ 12', () async {
    final katalog = Katalog.fromJson(
      jsonDecode(await rootBundle.loadString('assets/data/resep.json'))
          as Map<String, dynamic>,
    );
    final gagal = [
      for (final b in katalog.bahan)
        if (!IkonBahan.punyaPelukis(b.id) &&
            !pengecualian.contains(b.id) &&
            !emojiAman(IkonBahan.emojiTampil(b.id, b.emoji)))
          '${b.id} ${b.emoji} '
              '(${b.emoji.runes.map((r) => 'U+${r.toRadixString(16).toUpperCase()}').join(' ')})',
    ];
    expect(
      gagal,
      isEmpty,
      reason:
          'Emoji Unicode ≥ 13 tampil sebagai kotak di Android lama. Tambahkan '
          'CustomPainter di IkonBahan._pelukis atau pilih emoji lain.',
    );
    // Kasus yang memicu perbaikan ini tetap ditangani pelukis.
    expect(IkonBahan.punyaPelukis('buncis'), isTrue);
    expect(IkonBahan.punyaPelukis('minyak-goreng'), isTrue);
  });

  testWidgets('ikon pelukis terlihat jelas di 20, 28, dan 32 px', (
    tester,
  ) async {
    const idPelukis = [
      'tahu',
      'tempe',
      'kecap-manis',
      'buncis',
      'minyak-goreng',
      'bawang-merah',
      'bawang-putih',
      'margarin',
      'saus-tiram',
    ];
    for (final id in idPelukis) {
      expect(IkonBahan.punyaPelukis(id), isTrue, reason: id);
    }
    const kunci = Key('ikon');
    for (final ukuran in [20.0, 28.0, 32.0]) {
      for (final id in idPelukis) {
        await tester.pumpWidget(
          Center(
            child: RepaintBoundary(
              key: kunci,
              child: IkonBahan(id: id, emoji: '?', ukuran: ukuran),
            ),
          ),
        );
        expect(tester.getSize(find.byKey(kunci)), Size.square(ukuran));
        final piksel = await tester.runAsync(() async {
          final gambar = await tester
              .renderObject<RenderRepaintBoundary>(find.byKey(kunci))
              .toImage(pixelRatio: 3);
          final data = await gambar.toByteData();
          gambar.dispose();
          return data!;
        });
        var terisi = 0;
        final warna = <int>{};
        for (var i = 0; i < piksel!.lengthInBytes; i += 4) {
          if (piksel.getUint8(i + 3) > 200) {
            terisi++;
            warna.add(piksel.getUint32(i) >> 12); // warna dikelompokkan
          }
        }
        final rasio = terisi / (piksel.lengthInBytes / 4);
        final konteks = '$id @ ${ukuran.toInt()} px';
        // Cukup besar mengisi kotak dan punya detail (≥ 3 warna).
        expect(rasio, greaterThan(0.2), reason: '$konteks: isi $rasio');
        expect(warna.length, greaterThanOrEqualTo(3), reason: konteks);
      }
    }
    expect(tester.takeException(), isNull);
  });
}
