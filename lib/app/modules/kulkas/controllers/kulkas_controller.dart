import 'package:get/get.dart';

import '../../../data/models/bahan_model.dart';
import '../../../data/models/hasil_cocok.dart';
import '../../../data/services/katalog_service.dart';
import '../../../data/services/storage_service.dart';
import '../../../utils/notifikasi.dart';
import '../../../utils/pencocok_resep.dart';

/// Isi kulkas pengguna. Permanent: dipakai di semua halaman.
class KulkasController extends GetxController {
  static const jedaPencarian = Duration(milliseconds: 300);

  final StorageService _storage = Get.find<StorageService>();
  final KatalogService _katalog = Get.find<KatalogService>();

  final bahanDimiliki = <String>{}.obs;
  final keyword = ''.obs;

  /// Nama kategori yang disaring; '' berarti semua kategori.
  final kategoriAktif = ''.obs;
  final bumbuDasarAda = true.obs;

  /// Keyword setelah debounce; inilah yang dipakai menyaring.
  final _keywordAktif = ''.obs;

  @override
  void onInit() {
    super.onInit();
    bahanDimiliki.assignAll(_storage.bacaSet(StorageService.kunciKulkas));
    bumbuDasarAda.value =
        _storage.bacaBool(StorageService.kunciBumbuDasar) ?? true;
    ever(
      bahanDimiliki,
      (isi) => _storage.simpanSet(StorageService.kunciKulkas, isi),
    );
    ever(
      bumbuDasarAda,
      (nilai) => _storage.simpanBool(StorageService.kunciBumbuDasar, nilai),
    );
    debounce(
      keyword,
      (teks) => _keywordAktif.value = teks.trim().toLowerCase(),
      time: jedaPencarian,
    );
  }

  bool get katalogSiap => _katalog.katalog.value != null;

  bool get kulkasKosong => bahanDimiliki.isEmpty;

  /// Bahan yang lolos filter kategori & pencarian, dikelompokkan per kategori.
  Map<KategoriBahan, List<Bahan>> get bahanPerKategori {
    final kata = _keywordAktif.value;
    final kategori = kategoriAktif.value;
    final hasil = <KategoriBahan, List<Bahan>>{};
    for (final b in _katalog.katalog.value?.bahan ?? const <Bahan>[]) {
      if (kategori.isNotEmpty && b.kategori.name != kategori) continue;
      if (kata.isNotEmpty && !b.nama.toLowerCase().contains(kata)) continue;
      hasil.putIfAbsent(b.kategori, () => []).add(b);
    }
    return hasil;
  }

  /// Bahan di kulkas (urut nama) untuk ringkasan.
  List<Bahan> get bahanTerpilih {
    final byId = _katalog.katalog.value?.bahanById ?? const {};
    return [
      for (final id in bahanDimiliki)
        if (byId[id] != null) byId[id]!,
    ]..sort((a, b) => a.nama.compareTo(b.nama));
  }

  /// Resep yang siap dimasak atau kurang maksimal 2 bahan.
  int get jumlahResepCocok {
    final katalog = _katalog.katalog.value;
    if (katalog == null || kulkasKosong) return 0;
    return cocokkanSemua(
      katalog,
      bahanDimiliki,
      bumbuDasarAda: bumbuDasarAda.value,
    ).where((h) => h.kurang.length <= 2 && h.persen > 0).length;
  }

  void toggle(String id) {
    if (!bahanDimiliki.remove(id)) bahanDimiliki.add(id);
  }

  void kosongkan() => bahanDimiliki.clear();

  void konfirmasiKosongkan() {
    konfirmasi(
      judul: 'Kosongkan kulkas?',
      pesan:
          'Semua ${bahanDimiliki.length} bahan yang ditempel akan dilepas. '
          'Resep favorit tidak ikut terhapus.',
      teksYa: 'Kosongkan',
      onYa: () {
        kosongkan();
        tampilkanInfo('Kulkas dikosongkan');
      },
    );
  }

  void resetPencarian() {
    // Tulis hanya bila berubah: GetX tetap memancarkan event untuk nilai
    // yang sama dan memicu timer debounce yang tidak perlu.
    if (keyword.value.isNotEmpty) keyword.value = '';
    _keywordAktif.value = '';
    kategoriAktif.value = '';
  }

  void pilihKategori(String kategori) => kategoriAktif.value = kategori;

  /// Hasil cocok semua resep sesuai isi kulkas & opsi bumbu dasar.
  List<HasilCocok> get semuaHasil {
    final katalog = _katalog.katalog.value;
    if (katalog == null) return const [];
    return cocokkanSemua(
      katalog,
      bahanDimiliki,
      bumbuDasarAda: bumbuDasarAda.value,
    );
  }
}
