import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:resepsisakulkas/app/data/models/katalog_model.dart';
import 'package:resepsisakulkas/app/data/providers/resep_provider.dart';
import 'package:resepsisakulkas/app/data/repositories/resep_repository.dart';

import 'helpers/katalog_contoh.dart';
import 'helpers/palsu.dart';

void main() {
  final sekarang = DateTime(2026, 10, 13, 10, 20);
  final katalogServer = katalogKecil();
  // Katalog "bawaan" dibedakan lewat versi.
  final katalogBawaan = Katalog(
    versi: 99,
    bahan: katalogServer.bahan,
    resep: katalogServer.resep,
  );

  late StorageMemori storage;

  setUp(() => storage = StorageMemori());

  ResepRepository repo(ProviderPalsu provider) => ResepRepository(
    provider: provider,
    storage: storage,
    bacaAsset: () async => jsonEncode(katalogBawaan.toJson()),
    jam: () => sekarang,
  );

  ProviderPalsu sukses() =>
      ProviderPalsu(() async => Response(statusCode: 200, body: katalogServer));

  ProviderPalsu status(int kode) =>
      ProviderPalsu(() async => Response(statusCode: kode));

  ProviderPalsu melempar() =>
      ProviderPalsu(() async => throw Exception('DNS gagal'));

  test('server sukses → dipakai & disimpan ke cache', () async {
    final hasil = await repo(sukses()).ambil();
    expect(hasil.sumber, SumberData.server);
    expect(hasil.waktu, sekarang);
    expect(storage.cache?.waktu, sekarang);
    expect(Katalog.fromJson(storage.cache!.data).resep.length, 4);
  });

  test('cache < 24 jam → server tidak dipanggil', () async {
    storage.cache = (
      data: katalogServer.toJson(),
      waktu: sekarang.subtract(const Duration(hours: 3)),
    );
    final provider = sukses();
    final hasil = await repo(provider).ambil();
    expect(hasil.sumber, SumberData.cache);
    expect(provider.dipanggil, 0);
  });

  test('cache < 24 jam tetapi paksaServer → server dipanggil', () async {
    storage.cache = (
      data: katalogServer.toJson(),
      waktu: sekarang.subtract(const Duration(hours: 3)),
    );
    final provider = sukses();
    final hasil = await repo(provider).ambil(paksaServer: true);
    expect(provider.dipanggil, 1);
    expect(hasil.sumber, SumberData.server);
  });

  test('cache ≥ 24 jam → server dipanggil lagi', () async {
    storage.cache = (
      data: katalogServer.toJson(),
      waktu: sekarang.subtract(const Duration(hours: 25)),
    );
    final provider = sukses();
    await repo(provider).ambil();
    expect(provider.dipanggil, 1);
  });

  test('server gagal (404) + ada cache lama → pakai cache', () async {
    final lama = sekarang.subtract(const Duration(days: 3));
    storage.cache = (data: katalogServer.toJson(), waktu: lama);
    final hasil = await repo(status(404)).ambil();
    expect(hasil.sumber, SumberData.cache);
    expect(hasil.waktu, lama);
  });

  test('server gagal (timeout/DNS) tanpa cache → data bawaan', () async {
    final hasil = await repo(melempar()).ambil();
    expect(hasil.sumber, SumberData.bawaan);
    expect(hasil.katalog.versi, 99);
    expect(hasil.waktu, isNull);
  });

  test('status 500 tanpa cache → data bawaan', () async {
    final hasil = await repo(status(500)).ambil();
    expect(hasil.sumber, SumberData.bawaan);
  });

  test('JSON rusak dari server → tidak crash, pakai fallback', () async {
    final rusak = ProviderPalsu(
      () async => throw const FormatException('Unexpected character'),
    );
    final hasil = await repo(rusak).ambil();
    expect(hasil.sumber, SumberData.bawaan);
  });

  test('dekodeKatalog: JSON rusak melempar; repository menangkapnya', () {
    expect(() => dekodeKatalog('{bukan json'), throwsFormatException);
    expect(() => dekodeKatalog({'versi': 1}), throwsA(isA<TypeError>()));
    expect(dekodeKatalog(jsonEncode(katalogServer.toJson())).resep.length, 4);
  });

  test('cache rusak diabaikan → server / bawaan', () async {
    storage.cache = (data: {'versi': 'rusak'}, waktu: sekarang);
    final hasil = await repo(melempar()).ambil();
    expect(hasil.sumber, SumberData.bawaan);
  });

  test('server 200 tetapi katalog kosong dianggap gagal', () async {
    final kosong = ProviderPalsu(
      () async => Response(
        statusCode: 200,
        body: const Katalog(versi: 1, bahan: [], resep: []),
      ),
    );
    final hasil = await repo(kosong).ambil();
    expect(hasil.sumber, SumberData.bawaan);
    expect(storage.cache, isNull);
  });
}
