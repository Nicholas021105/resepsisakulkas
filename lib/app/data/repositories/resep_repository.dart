import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/katalog_model.dart';
import '../providers/api_config.dart';
import '../providers/resep_provider.dart';
import '../services/storage_service.dart';

/// Mengambil katalog dengan urutan fallback: server → cache → data bawaan.
class ResepRepository {
  ResepRepository({
    required this._provider,
    required this._storage,
    Future<String> Function()? bacaAsset,
    DateTime Function()? jam,
  }) : _bacaAsset =
           bacaAsset ?? (() => rootBundle.loadString('assets/data/resep.json')),
       _jam = jam ?? DateTime.now;

  final ResepProvider _provider;
  final StorageService _storage;
  final Future<String> Function() _bacaAsset;
  final DateTime Function() _jam;

  /// Cache < 24 jam dipakai langsung tanpa menghubungi server, kecuali
  /// [paksaServer] (tombol "Perbarui data").
  Future<HasilAmbil> ambil({bool paksaServer = false}) async {
    final cache = _bacaCache();
    final sekarang = _jam();
    if (!paksaServer &&
        cache != null &&
        sekarang.difference(cache.waktu!) < ApiConfig.umurCache) {
      return cache;
    }

    final dariServer = await _ambilServer();
    if (dariServer != null) {
      await _storage.simpanCache(dariServer.toJson(), sekarang);
      return HasilAmbil(
        katalog: dariServer,
        sumber: SumberData.server,
        waktu: sekarang,
      );
    }
    if (cache != null) return cache;

    final teks = await _bacaAsset();
    return HasilAmbil(
      katalog: Katalog.fromJson(jsonDecode(teks) as Map<String, dynamic>),
      sumber: SumberData.bawaan,
    );
  }

  /// Status non-200, timeout, DNS gagal, atau JSON rusak dianggap gagal.
  Future<Katalog?> _ambilServer() async {
    try {
      final respons = await _provider.ambilKatalog();
      final katalog = respons.body;
      if (respons.statusCode == 200 &&
          katalog != null &&
          katalog.resep.isNotEmpty) {
        return katalog;
      }
    } catch (_) {
      // Jatuh ke cache / data bawaan.
    }
    return null;
  }

  /// Cache yang rusak diabaikan, bukan membuat aplikasi crash.
  HasilAmbil? _bacaCache() {
    try {
      final cache = _storage.bacaCache();
      if (cache == null) return null;
      return HasilAmbil(
        katalog: Katalog.fromJson(cache.data),
        sumber: SumberData.cache,
        waktu: cache.waktu,
      );
    } catch (_) {
      return null;
    }
  }
}
