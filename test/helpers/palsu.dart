import 'package:get/get.dart';
import 'package:resepsisakulkas/app/data/models/katalog_model.dart';
import 'package:resepsisakulkas/app/data/providers/resep_provider.dart';
import 'package:resepsisakulkas/app/data/repositories/resep_repository.dart';
import 'package:resepsisakulkas/app/data/services/storage_service.dart';

/// StorageService di memori (tanpa GetStorage/plugin).
class StorageMemori implements StorageService {
  final Map<String, Set<String>> set = {};
  final Map<String, bool> boolean = {};
  CacheKatalog? cache;

  @override
  Set<String> bacaSet(String kunci) => {...?set[kunci]};

  @override
  Future<void> simpanSet(String kunci, Set<String> isi) async =>
      set[kunci] = {...isi};

  @override
  bool? bacaBool(String kunci) => boolean[kunci];

  @override
  Future<void> simpanBool(String kunci, bool nilai) async =>
      boolean[kunci] = nilai;

  @override
  CacheKatalog? bacaCache() => cache;

  @override
  Future<void> simpanCache(Map<String, dynamic> data, DateTime waktu) async =>
      cache = (data: data, waktu: waktu);
}

/// Provider tiruan: tidak menyentuh jaringan, menghitung jumlah panggilan.
class ProviderPalsu extends ResepProvider {
  ProviderPalsu(this._jawab);

  final Future<Response<Katalog>> Function() _jawab;
  int dipanggil = 0;

  @override
  Future<Response<Katalog>> ambilKatalog() {
    dipanggil++;
    return _jawab();
  }
}

/// Repository dengan hasil tetap (atau Future yang dikendalikan test).
class RepoTetap implements ResepRepository {
  RepoTetap(this._ambil);

  final Future<HasilAmbil> Function() _ambil;
  int dipanggil = 0;

  @override
  Future<HasilAmbil> ambil({bool paksaServer = false}) {
    dipanggil++;
    return _ambil();
  }
}
