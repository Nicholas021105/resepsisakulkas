import 'package:get_storage/get_storage.dart';

/// Cache katalog: isi JSON + waktu diambil dari server.
typedef CacheKatalog = ({Map<String, dynamic> data, DateTime waktu});

/// Pembungkus GetStorage untuk kulkas, favorit, opsi, dan cache katalog.
class StorageService {
  static const kunciKulkas = 'bahanDimiliki';
  static const kunciFavorit = 'favorit';
  static const kunciBumbuDasar = 'bumbuDasarAda';
  static const _kunciCache = 'cacheKatalog';

  GetStorage get _box => GetStorage();

  Set<String> bacaSet(String kunci) =>
      (_box.read<List<dynamic>>(kunci) ?? const []).cast<String>().toSet();

  Future<void> simpanSet(String kunci, Set<String> isi) =>
      _box.write(kunci, isi.toList());

  bool? bacaBool(String kunci) => _box.read<bool>(kunci);

  Future<void> simpanBool(String kunci, bool nilai) => _box.write(kunci, nilai);

  CacheKatalog? bacaCache() {
    final isi = _box.read<Map<String, dynamic>>(_kunciCache);
    final waktu = DateTime.tryParse(isi?['waktu'] as String? ?? '');
    final data = isi?['data'];
    if (waktu == null || data is! Map) return null;
    return (data: Map<String, dynamic>.from(data), waktu: waktu);
  }

  Future<void> simpanCache(Map<String, dynamic> data, DateTime waktu) =>
      _box.write(_kunciCache, {'waktu': waktu.toIso8601String(), 'data': data});
}
