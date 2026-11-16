import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resepsisakulkas/app/data/models/bahan_model.dart';
import 'package:resepsisakulkas/app/data/models/katalog_model.dart';
import 'package:resepsisakulkas/app/data/models/resep_model.dart';
import 'package:resepsisakulkas/app/utils/pencocok_resep.dart';

/// Integritas assets/data/resep.json (data bawaan aplikasi).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Map<String, dynamic> json;
  late Katalog katalog;

  setUpAll(() async {
    json = jsonDecode(
      await rootBundle.loadString('assets/data/resep.json'),
    ) as Map<String, dynamic>;
    katalog = Katalog.fromJson(json);
  });

  test('JSON bisa di-parse oleh Katalog.fromJson', () {
    // Katalog versi 2: ± 60 resep (sebelumnya 32 resep, 42 bahan).
    expect(katalog.versi, greaterThanOrEqualTo(2));
    expect(katalog.bahan.length, inInclusiveRange(45, 60));
    expect(katalog.resep.length, inInclusiveRange(58, 70));
  });

  test('tidak ada id bahan maupun id resep ganda', () {
    final idBahan = katalog.bahan.map((b) => b.id).toList();
    final idResep = katalog.resep.map((r) => r.id).toList();
    expect(idBahan.toSet().length, idBahan.length);
    expect(idResep.toSet().length, idResep.length);
  });

  test('id memakai kebab-case', () {
    final pola = RegExp(r'^[a-z0-9]+(-[a-z0-9]+)*$');
    for (final id in [
      ...katalog.bahan.map((b) => b.id),
      ...katalog.resep.map((r) => r.id),
    ]) {
      expect(pola.hasMatch(id), isTrue, reason: id);
    }
  });

  test('kategori valid (protein | sayur | karbohidrat | bumbu)', () {
    const valid = {'protein', 'sayur', 'karbohidrat', 'bumbu'};
    for (final b in json['bahan'] as List) {
      expect(valid, contains((b as Map)['kategori']), reason: '${b['id']}');
    }
    expect(
      katalog.bahan.map((b) => b.kategori).toSet(),
      KategoriBahan.values.toSet(),
    );
  });

  test('bumbu dasar hanya garam, gula, minyak goreng, air', () {
    expect(katalog.bahan.where((b) => b.bumbuDasar).map((b) => b.id).toSet(), {
      'garam',
      'gula',
      'minyak-goreng',
      'air',
    });
  });

  test('semua bahanId di resep ada di daftar bahan', () {
    final ada = katalog.bahanById.keys.toSet();
    for (final r in katalog.resep) {
      for (final b in r.bahan) {
        expect(ada, contains(b.bahanId), reason: '${r.id} → ${b.bahanId}');
      }
    }
  });

  test('setiap resep: ≥ 2 bahan wajib, 2–10 bahan, 3–7 langkah', () {
    for (final r in katalog.resep) {
      expect(r.bahanWajib.length, greaterThanOrEqualTo(2), reason: r.id);
      expect(r.bahan.length, inInclusiveRange(2, 10), reason: r.id);
      expect(r.langkah.length, inInclusiveRange(3, 7), reason: r.id);
      expect(r.deskripsi.trim(), isNotEmpty, reason: r.id);
      expect(r.waktuMenit, greaterThan(0), reason: r.id);
    }
  });

  test('tidak ada bahan ganda dalam satu resep', () {
    for (final r in katalog.resep) {
      final id = r.bahan.map((b) => b.bahanId).toList();
      expect(id.toSet().length, id.length, reason: r.id);
    }
  });

  test('setiap bahan dipakai minimal satu resep', () {
    final terpakai = {
      for (final r in katalog.resep) ...r.bahan.map((b) => b.bahanId),
    };
    expect(
      katalog.bahan.map((b) => b.id).where((id) => !terpakai.contains(id)),
      isEmpty,
    );
  });

  test('setiap resep punya kategori & sajian yang dikenal', () {
    final kategori = KategoriResep.values.map((k) => k.name).toSet()
      ..remove(KategoriResep.lainnya.name);
    final sajian = JenisSajian.values.map((s) => s.name).toSet();
    for (final r in json['resep'] as List) {
      expect(kategori, contains((r as Map)['kategori']), reason: '${r['id']}');
      expect(sajian, contains(r['sajian']), reason: '${r['id']}');
    }
    // Semua kategori (selain "lainnya") terisi, jadi chip jelajah tidak
    // pernah kosong.
    expect(katalog.resep.map((r) => r.kategori.name).toSet(), kategori);
  });

  test('tiga tingkat kesulitan terwakili; waktu masuk akal', () {
    expect(
      katalog.resep.map((r) => r.tingkat).toSet(),
      TingkatResep.values.toSet(),
    );
    for (final r in katalog.resep) {
      expect(r.waktuMenit, inInclusiveRange(5, 90), reason: r.id);
      expect(r.porsi, inInclusiveRange(1, 6), reason: r.id);
      if (r.tingkat == TingkatResep.sulit) {
        expect(r.waktuMenit, greaterThanOrEqualTo(30), reason: r.id);
      }
    }
  });

  test('masa simpan: bahan segar punya awetHari, bumbu dasar tidak', () {
    final byId = katalog.bahanById;
    for (final id in ['bayam', 'kangkung', 'tauge', 'tahu', 'tempe', 'ayam']) {
      expect(byId[id]?.awetHari, inInclusiveRange(1, 3), reason: id);
    }
    expect(byId['telur']?.awetHari, greaterThan(7));
    for (final b in katalog.bahan.where((b) => b.bumbuDasar)) {
      expect(b.awetHari, isNull, reason: b.id);
    }
    for (final b in katalog.bahan) {
      if (b.awetHari != null) {
        expect(b.awetHari, inInclusiveRange(1, 30), reason: b.id);
      }
    }
  });

  test('langkah berakhir titik dan takaran tidak kosong', () {
    for (final r in katalog.resep) {
      for (final l in r.langkah) {
        expect(l.trim().endsWith('.'), isTrue, reason: '${r.id}: $l');
      }
      for (final b in r.bahan) {
        expect(b.takaran.trim(), isNotEmpty, reason: '${r.id}: ${b.bahanId}');
      }
    }
  });

  test('demo: 7 bahan umum + bumbu dasar → beberapa resep 100%', () {
    const kulkas = {
      'telur',
      'tempe',
      'tahu',
      'bawang-merah',
      'bawang-putih',
      'cabai',
      'kecap-manis',
    };
    final hasil = cocokkanSemua(katalog, kulkas, bumbuDasarAda: true);
    final siap = hasil.where((h) => h.persen == 100).length;
    final sebagian = hasil.where((h) => h.persen > 0 && h.persen < 100).length;
    expect(siap, greaterThanOrEqualTo(5));
    expect(sebagian, greaterThanOrEqualTo(10));
  });
}
