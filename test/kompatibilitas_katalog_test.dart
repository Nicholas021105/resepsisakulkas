import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resepsisakulkas/app/data/models/bahan_model.dart';
import 'package:resepsisakulkas/app/data/models/katalog_model.dart';
import 'package:resepsisakulkas/app/data/models/resep_model.dart';

/// Kompatibilitas skema katalog dua arah:
/// 1. katalog versi 2 harus tetap terbaca aplikasi versi 1.0 (yang masih
///    terpasang di HP pengguna dan mengambil `server_data/resep.json`);
/// 2. aplikasi sekarang harus tetap membaca katalog versi 1 (cache lama).
///
/// Pembaca v1 di bawah meniru `fromJson` aplikasi 1.0 apa adanya: enum
/// dibaca dengan `values.byName` yang MELEMPAR untuk nilai tak dikenal.
enum _KategoriV1 { protein, sayur, karbohidrat, bumbu }

enum _TingkatV1 { mudah, sedang }

int _bacaSepertiV1(Map<String, dynamic> json) {
  json['versi'] as int;
  for (final e in json['bahan'] as List<dynamic>) {
    final b = Map<String, dynamic>.from(e as Map);
    b['id'] as String;
    b['nama'] as String;
    _KategoriV1.values.byName(b['kategori'] as String);
    b['emoji'] as String;
    b['bumbuDasar'] as bool? ?? false;
  }
  var jumlah = 0;
  for (final e in json['resep'] as List<dynamic>) {
    final r = Map<String, dynamic>.from(e as Map);
    r['id'] as String;
    r['nama'] as String;
    r['deskripsi'] as String;
    r['waktuMenit'] as int;
    r['porsi'] as int;
    _TingkatV1.values.byName(r['tingkat'] as String);
    for (final x in r['bahan'] as List<dynamic>) {
      final bahan = Map<String, dynamic>.from(x as Map);
      bahan['bahanId'] as String;
      bahan['takaran'] as String;
      bahan['opsional'] as bool? ?? false;
    }
    (r['langkah'] as List<dynamic>).cast<String>().toList();
    jumlah++;
  }
  return jumlah;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late String teksAsset;
  late Map<String, dynamic> json;

  setUpAll(() async {
    teksAsset = await rootBundle.loadString('assets/data/resep.json');
    json = jsonDecode(teksAsset) as Map<String, dynamic>;
  });

  test('assets/data dan server_data berisi berkas yang identik', () {
    final server = File('server_data/resep.json').readAsStringSync();
    expect(
      server.replaceAll('\r\n', '\n'),
      teksAsset.replaceAll('\r\n', '\n'),
      reason: 'Salin assets/data/resep.json ke server_data/resep.json',
    );
  });

  test('katalog versi 2 tetap terbaca pembaca versi 1.0', () {
    expect(_bacaSepertiV1(json), Katalog.fromJson(json).resep.length);
  });

  test('pembaca v1 memang menolak tingkat "sulit" (alasan tingkatV2)', () {
    final salinan = jsonDecode(teksAsset) as Map<String, dynamic>;
    ((salinan['resep'] as List).first as Map)['tingkat'] = 'sulit';
    expect(() => _bacaSepertiV1(salinan), throwsArgumentError);
  });

  test('tingkat sulit ditulis sebagai sedang + tingkatV2', () {
    final sulit = [
      for (final r in json['resep'] as List)
        if ((r as Map)['tingkatV2'] != null) r,
    ];
    expect(sulit, isNotEmpty);
    for (final r in sulit) {
      expect(r['tingkat'], 'sedang', reason: '${r['id']}');
      expect(r['tingkatV2'], 'sulit', reason: '${r['id']}');
      expect(
        Resep.fromJson(Map<String, dynamic>.from(r)).tingkat,
        TingkatResep.sulit,
      );
    }
  });

  group('aplikasi sekarang membaca katalog versi 1 (cache lama)', () {
    final v1 = {
      'versi': 1,
      'bahan': [
        {
          'id': 'telur',
          'nama': 'Telur',
          'kategori': 'protein',
          'emoji': '🥚',
          'bumbuDasar': false,
        },
        {'id': 'garam', 'nama': 'Garam', 'kategori': 'bumbu', 'emoji': '🧂'},
      ],
      'resep': [
        {
          'id': 'telur-rebus',
          'nama': 'Telur Rebus',
          'deskripsi': 'Sederhana.',
          'waktuMenit': 12,
          'porsi': 1,
          'tingkat': 'mudah',
          'bahan': [
            {'bahanId': 'telur', 'takaran': '2 butir', 'opsional': false},
            {'bahanId': 'garam', 'takaran': 'sejumput'},
          ],
          'langkah': ['Rebus.', 'Kupas.', 'Sajikan.'],
        },
      ],
    };

    test('field baru memakai nilai default', () {
      final k = Katalog.fromJson(v1);
      expect(k.bahan.first.awetHari, isNull);
      final r = k.resep.single;
      expect(r.tingkat, TingkatResep.mudah);
      expect(r.kategori, KategoriResep.lainnya);
      expect(r.sajian, JenisSajian.piring);
    });

    test('toJson katalog v1 tidak menambah field baru', () {
      final r = Katalog.fromJson(v1).toJson()['resep'] as List;
      expect(
        (r.single as Map).keys,
        isNot(anyOf(contains('kategori'), contains('tingkatV2'))),
      );
    });
  });

  group(
    'nilai tak dikenal dari katalog yang lebih baru tidak membuat crash',
    () {
      test('kategori bahan, tingkat, kategori resep, sajian', () {
        final b = Bahan.fromJson({
          'id': 'x',
          'nama': 'X',
          'kategori': 'buah',
          'emoji': '🍎',
          'awetHari': 'lama',
        });
        expect(b.kategori, KategoriBahan.bumbu);
        expect(b.awetHari, isNull);

        final r = Resep.fromJson({
          'id': 'x',
          'nama': 'X',
          'deskripsi': '-',
          'waktuMenit': 1,
          'porsi': 1,
          'tingkat': 'sedang',
          'tingkatV2': 'mustahil',
          'kategori': 'minuman',
          'sajian': 'gelas',
          'bahan': <dynamic>[],
          'langkah': <dynamic>[],
        });
        expect(r.tingkat, TingkatResep.sedang);
        expect(r.kategori, KategoriResep.lainnya);
        expect(r.sajian, JenisSajian.piring);
      });

      test('awetHari nol/negatif dianggap awet', () {
        Bahan buat(Object? awet) => Bahan.fromJson({
          'id': 'x',
          'nama': 'X',
          'kategori': 'sayur',
          'emoji': '🥬',
          'awetHari': awet,
        });
        expect(buat(0).awetHari, isNull);
        expect(buat(-3).awetHari, isNull);
        expect(buat(4).awetHari, 4);
        expect(buat(2.0).awetHari, 2);
      });
    },
  );

  test('Resep sulit: toJson → fromJson bolak-balik', () {
    const asli = Resep(
      id: 'opor',
      nama: 'Opor',
      deskripsi: '-',
      waktuMenit: 50,
      porsi: 4,
      tingkat: TingkatResep.sulit,
      kategori: KategoriResep.lauk,
      sajian: JenisSajian.kuah,
      bahan: [BahanResep(bahanId: 'ayam', takaran: '500 gram')],
      langkah: ['a', 'b', 'c'],
    );
    final json = asli.toJson();
    expect(json['tingkat'], 'sedang');
    expect(json['tingkatV2'], 'sulit');
    final hasil = Resep.fromJson(json);
    expect(hasil.tingkat, TingkatResep.sulit);
    expect(hasil.kategori, KategoriResep.lauk);
    expect(hasil.sajian, JenisSajian.kuah);
    expect(hasil.toJson(), json);
  });
}
