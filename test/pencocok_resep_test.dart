import 'package:flutter_test/flutter_test.dart';
import 'package:resepsisakulkas/app/data/models/hasil_cocok.dart';
import 'package:resepsisakulkas/app/data/models/katalog_model.dart';
import 'package:resepsisakulkas/app/utils/pencocok_resep.dart';

import 'helpers/katalog_contoh.dart';

void main() {
  final katalog = katalogKecil();
  final byId = katalog.bahanById;

  test('bahan opsional tidak memengaruhi persentase', () {
    final dadar = katalog.resepById('dadar')!;
    final h = cocokkanResep(
      dadar,
      {'telur', 'garam', 'minyak'},
      byId,
      bumbuDasarAda: false,
    );
    expect(h.persen, 100);
    expect(h.kurang, isEmpty);
  });

  test('tanpa opsi bumbu dasar: garam & minyak dihitung kurang', () {
    final h = cocokkanResep(
      katalog.resepById('dadar')!,
      {'telur'},
      byId,
      bumbuDasarAda: false,
    );
    expect(h.persen, 33);
    expect(h.kurang, ['garam', 'minyak']);
  });

  test('dengan opsi bumbu dasar: garam & minyak dianggap ada', () {
    final h = cocokkanResep(
      katalog.resepById('dadar')!,
      {'telur'},
      byId,
      bumbuDasarAda: true,
    );
    expect(h.persen, 100);
    expect(h.dimiliki, ['telur', 'garam', 'minyak']);
  });

  test('persen dibulatkan: 2 dari 3 = 67', () {
    final h = cocokkanResep(
      katalog.resepById('orek')!,
      {'tempe', 'kecap'},
      byId,
      bumbuDasarAda: false,
    );
    expect(h.persen, 67);
  });

  test('urutan: persen ↓, jumlah kurang ↑, waktu ↑', () {
    final hasil = cocokkanSemua(katalog, {
      'telur',
      'kecap',
    }, bumbuDasarAda: true);
    // dadar 100% (10 mnt) & telur-kecap 100% (5 mnt) → telur-kecap dulu.
    expect(hasil.map((h) => h.resep.id).toList(), [
      'telur-kecap',
      'dadar',
      'orek', // 2/3 = 67%, kurang 1
      'campur', // 2/4 = 50%, kurang 2
    ]);
  });

  test('persen & jumlah kurang sama → waktu masak tercepat dulu', () {
    final seri = Katalog(
      versi: 1,
      bahan: katalog.bahan,
      resep: [
        resep('lambat', [pakai('telur'), pakai('tomat')], waktu: 30),
        resep('cepat', [pakai('telur'), pakai('tempe')], waktu: 8),
      ],
    );
    final hasil = cocokkanSemua(seri, {'telur'}, bumbuDasarAda: false);
    expect(hasil.map((h) => (h.resep.id, h.persen, h.kurang.length)), [
      ('cepat', 50, 1),
      ('lambat', 50, 1),
    ]);
  });

  group('filter', () {
    final hasil = cocokkanSemua(katalog, {
      'telur',
      'kecap',
    }, bumbuDasarAda: true);

    test('siap dimasak = 100%', () {
      expect(
        saringHasil(
          hasil,
          FilterHasil.siap,
          kulkasKosong: false,
        ).map((h) => h.resep.id),
        ['telur-kecap', 'dadar'],
      );
    });

    test('kurang 1–2 bahan', () {
      expect(
        saringHasil(
          hasil,
          FilterHasil.kurangSedikit,
          kulkasKosong: false,
        ).map((h) => h.resep.id),
        ['orek', 'campur'],
      );
    });

    test('semua tidak menampilkan resep 0%', () {
      final cuma = cocokkanSemua(katalog, {'tomat'}, bumbuDasarAda: false);
      final semua = saringHasil(cuma, FilterHasil.semua, kulkasKosong: false);
      expect(semua.every((h) => h.persen > 0), isTrue);
      expect(semua.map((h) => h.resep.id), ['campur']);
    });
  });

  test('kulkas kosong: semua resep 0% tetap tampil di "Semua"', () {
    final hasil = cocokkanSemua(katalog, {}, bumbuDasarAda: false);
    expect(hasil.every((h) => h.persen == 0), isTrue);
    expect(
      saringHasil(hasil, FilterHasil.semua, kulkasKosong: true).length,
      katalog.resep.length,
    );
    expect(saringHasil(hasil, FilterHasil.siap, kulkasKosong: true), isEmpty);
  });
}
