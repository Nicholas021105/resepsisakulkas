import 'package:flutter_test/flutter_test.dart';
import 'package:resepsisakulkas/app/data/models/bahan_model.dart';
import 'package:resepsisakulkas/app/data/models/katalog_model.dart';
import 'package:resepsisakulkas/app/data/models/resep_model.dart';

import 'helpers/katalog_contoh.dart';

void main() {
  test('Bahan fromJson/toJson bolak-balik', () {
    const asli = Bahan(
      id: 'garam',
      nama: 'Garam',
      kategori: KategoriBahan.bumbu,
      emoji: '🧂',
      bumbuDasar: true,
    );
    final hasil = Bahan.fromJson(asli.toJson());
    expect(hasil.toJson(), asli.toJson());
    expect(hasil.kategori, KategoriBahan.bumbu);
    expect(hasil.bumbuDasar, isTrue);
  });

  test('Bahan tanpa field bumbuDasar dianggap bukan bumbu dasar', () {
    final b = Bahan.fromJson({
      'id': 'tahu',
      'nama': 'Tahu',
      'kategori': 'protein',
      'emoji': '⬜',
    });
    expect(b.bumbuDasar, isFalse);
  });

  test('BahanResep & Resep fromJson/toJson bolak-balik', () {
    const asli = Resep(
      id: 'telur-dadar',
      nama: 'Telur Dadar',
      deskripsi: 'Cepat.',
      waktuMenit: 10,
      porsi: 1,
      tingkat: TingkatResep.sedang,
      bahan: [
        BahanResep(bahanId: 'telur', takaran: '2 butir'),
        BahanResep(bahanId: 'daun-bawang', takaran: '1 batang', opsional: true),
      ],
      langkah: ['Kocok.', 'Goreng.', 'Angkat.'],
    );
    final hasil = Resep.fromJson(asli.toJson());
    expect(hasil.toJson(), asli.toJson());
    expect(hasil.tingkat, TingkatResep.sedang);
    expect(hasil.bahanWajib.map((b) => b.bahanId), ['telur']);
  });

  test('Katalog fromJson/toJson bolak-balik + pencarian id', () {
    final asli = katalogKecil();
    final hasil = Katalog.fromJson(asli.toJson());
    expect(hasil.toJson(), asli.toJson());
    expect(hasil.resepById('orek')?.nama, 'orek');
    expect(hasil.resepById('tidak-ada'), isNull);
    expect(hasil.bahanById['garam']?.bumbuDasar, isTrue);
  });
}
