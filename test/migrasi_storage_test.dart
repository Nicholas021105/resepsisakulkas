import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resepsisakulkas/app/controllers/tema_controller.dart';
import 'package:resepsisakulkas/app/data/services/storage_service.dart';
import 'package:resepsisakulkas/app/utils/info_aplikasi.dart';
import 'package:resepsisakulkas/app/utils/migrasi_storage.dart';

import 'helpers/katalog_contoh.dart';

/// Storage yang hanya mengganti dua primitif, sehingga semua pembantu
/// bertipe (bacaSet, bacaCache, …) diuji persis seperti di perangkat.
class StorageMentah extends StorageService {
  StorageMentah([Map<String, dynamic>? awal]) : isi = {...?awal};

  final Map<String, dynamic> isi;
  int jumlahTulis = 0;

  @override
  dynamic bacaMentah(String kunci) => isi[kunci];

  @override
  Future<void> tulisMentah(String kunci, dynamic nilai) async {
    jumlahTulis++;
    isi[kunci] = nilai;
  }
}

void main() {
  final sekarang = DateTime(2026, 11, 16, 9);

  /// Isi GetStorage persis seperti yang ditulis aplikasi versi 1.0.
  Map<String, dynamic> dataV1() => {
    'bahanDimiliki': ['telur', 'tempe', 'bayam'],
    'favorit': ['orek-tempe'],
    'bumbuDasarAda': false,
    'cacheKatalog': {
      'waktu': '2026-10-13T10:20:00.000',
      'data': katalogKecil().toJson(),
    },
  };

  group('migrasi skema 1 → 2', () {
    test('data lama utuh: kulkas, favorit, bumbu dasar, cache', () async {
      final s = StorageMentah(dataV1());
      await migrasiStorage(s, sekarang: sekarang);

      expect(s.bacaSet(StorageService.kunciKulkas), {
        'telur',
        'tempe',
        'bayam',
      });
      expect(s.bacaSet(StorageService.kunciFavorit), {'orek-tempe'});
      expect(s.bacaBool(StorageService.kunciBumbuDasar), isFalse);
      expect(s.bacaCache()?.waktu, DateTime(2026, 10, 13, 10, 20));
      expect(s.bacaCache()?.data['resep'], hasLength(4));
      expect(s.bacaAngka(StorageService.kunciSkema), versiSkemaSekarang);
    });

    test('bahan lama diberi tanggal tempel = saat migrasi', () async {
      final s = StorageMentah(dataV1());
      await migrasiStorage(s, sekarang: sekarang);
      expect(s.bacaPetaTeks(StorageService.kunciSejak), {
        'telur': sekarang.toIso8601String(),
        'tempe': sekarang.toIso8601String(),
        'bayam': sekarang.toIso8601String(),
      });
    });

    test('pengguna lama tidak melihat onboarding', () async {
      final s = StorageMentah(dataV1());
      await migrasiStorage(s, sekarang: sekarang);
      expect(s.bacaBool(StorageService.kunciOnboarding), isTrue);
    });

    test('pengguna lama yang hanya pernah mengubah opsi bumbu dasar', () async {
      final s = StorageMentah({'bumbuDasarAda': true});
      await migrasiStorage(s, sekarang: sekarang);
      expect(s.bacaBool(StorageService.kunciOnboarding), isTrue);
    });

    test('pemasangan baru: onboarding tetap tampil, skema dicatat', () async {
      final s = StorageMentah();
      await migrasiStorage(s, sekarang: sekarang);
      expect(s.bacaBool(StorageService.kunciOnboarding), isNull);
      expect(s.bacaAngka(StorageService.kunciSkema), versiSkemaSekarang);
      expect(s.bacaSet(StorageService.kunciKulkas), isEmpty);
    });

    test('dijalankan dua kali: hasil sama, tanggal tidak digeser', () async {
      final s = StorageMentah(dataV1());
      await migrasiStorage(s, sekarang: sekarang);
      final setelahPertama = {...s.isi};
      final tulis = s.jumlahTulis;
      await migrasiStorage(s, sekarang: sekarang.add(const Duration(days: 5)));
      expect(s.isi, setelahPertama);
      expect(s.jumlahTulis, tulis, reason: 'tidak ada penulisan ulang');
    });
  });

  group('perapian di skema 2', () {
    test(
      'tanda segera & tanggal untuk bahan yang sudah dilepas dibuang',
      () async {
        final s = StorageMentah({
          'versiSkema': 2,
          'bahanDimiliki': ['telur'],
          'kulkasSejak': {
            'telur': '2026-11-10T08:00:00.000',
            'bayam': '2026-11-01T08:00:00.000',
          },
          'segeraHabiskan': ['telur', 'bayam'],
        });
        await migrasiStorage(s, sekarang: sekarang);
        expect(s.bacaPetaTeks(StorageService.kunciSejak), {
          'telur': '2026-11-10T08:00:00.000',
        });
        expect(s.bacaSet(StorageService.kunciSegera), {'telur'});
      },
    );

    test('tanggal rusak diganti saat ini, tanggal sah dipertahankan', () async {
      final s = StorageMentah({
        'versiSkema': 2,
        'bahanDimiliki': ['telur', 'tahu'],
        'kulkasSejak': {'telur': 'bukan tanggal', 'tahu': '2026-11-14'},
      });
      await migrasiStorage(s, sekarang: sekarang);
      final sejak = s.bacaPetaTeks(StorageService.kunciSejak);
      expect(sejak['telur'], sekarang.toIso8601String());
      expect(sejak['tahu'], '2026-11-14');
    });
  });

  group('pembacaan defensif (data rusak tidak membuat crash)', () {
    final rusak = StorageMentah({
      'bahanDimiliki': 'telur',
      'favorit': [1, 'orek-tempe', null, true],
      'bumbuDasarAda': 'ya',
      'cacheKatalog': ['bukan', 'peta'],
      'kulkasSejak': {'telur': 12, 'tahu': '2026-11-14', 7: 'x'},
      'daftarBelanja': [
        'teks',
        {'bahanId': 'telur'},
        3,
      ],
      'versiSkema': '2',
      'modeTema': 42,
    });

    test('tipe salah → nilai kosong, elemen sah tetap terbaca', () {
      expect(rusak.bacaSet(StorageService.kunciKulkas), isEmpty);
      expect(rusak.bacaSet(StorageService.kunciFavorit), {'orek-tempe'});
      expect(rusak.bacaBool(StorageService.kunciBumbuDasar), isNull);
      expect(rusak.bacaCache(), isNull);
      expect(rusak.bacaPetaTeks(StorageService.kunciSejak), {
        'tahu': '2026-11-14',
      });
      expect(rusak.bacaDaftarPeta(StorageService.kunciBelanja), [
        {'bahanId': 'telur'},
      ]);
      expect(rusak.bacaAngka(StorageService.kunciSkema), isNull);
      expect(rusak.bacaTeks(StorageService.kunciTema), isNull);
      expect(TemaController.bacaMode(rusak), ThemeMode.system);
    });

    test('migrasi di atas data rusak tidak melempar', () async {
      await expectLater(migrasiStorage(rusak, sekarang: sekarang), completes);
      expect(rusak.bacaSet(StorageService.kunciFavorit), {'orek-tempe'});
    });

    test('cache dengan waktu/data rusak diabaikan', () {
      expect(
        StorageMentah({
          'cacheKatalog': {'waktu': 'kemarin', 'data': {}},
        }).bacaCache(),
        isNull,
      );
      expect(
        StorageMentah({
          'cacheKatalog': {'waktu': '2026-10-13T10:20:00.000', 'data': 5},
        }).bacaCache(),
        isNull,
      );
    });
  });

  group('tema tersimpan', () {
    test('terang / gelap / sistem / tidak dikenal', () {
      ThemeMode baca(dynamic nilai) =>
          TemaController.bacaMode(StorageMentah({'modeTema': nilai}));
      expect(baca('terang'), ThemeMode.light);
      expect(baca('gelap'), ThemeMode.dark);
      expect(baca('sistem'), ThemeMode.system);
      expect(baca('ungu'), ThemeMode.system);
      expect(baca(null), ThemeMode.system);
    });
  });

  group('versi aplikasi dari pubspec', () {
    test('mengambil versi tanpa nomor build', () {
      expect(versiDariPubspec('name: x\nversion: 2.0.0+2\n'), '2.0.0');
      expect(versiDariPubspec('version: 1.12.3'), '1.12.3');
      expect(versiDariPubspec('name: x\n# version: 9.9.9\n'), isNull);
      expect(versiDariPubspec(''), isNull);
    });

    test('pubspec.yaml dibundel dan versinya terbaca', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      final versi = await bacaVersiAplikasi();
      expect(versi, matches(RegExp(r'^\d+\.\d+\.\d+$')));
    });
  });
}
