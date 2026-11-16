import 'package:get/get.dart';

import '../../../data/models/bahan_model.dart';
import '../../../data/models/hasil_cocok.dart';
import '../../../data/services/katalog_service.dart';
import '../../../data/services/storage_service.dart';
import '../../../utils/kesegaran.dart';
import '../../../utils/notifikasi.dart';
import '../../../utils/pencocok_resep.dart';

/// Isi kulkas pengguna. Permanent: dipakai di semua halaman.
///
/// Selain "ada / tidak ada", kulkas mencatat kapan tiap bahan ditempel dan
/// bahan mana yang ditandai "segera habiskan", sehingga resep yang
/// menyelamatkan bahan hampir basi bisa dinaikkan.
class KulkasController extends GetxController {
  KulkasController({DateTime Function()? jam}) : _jam = jam ?? DateTime.now;

  static const jedaPencarian = Duration(milliseconds: 300);

  final StorageService _storage = Get.find<StorageService>();
  final KatalogService _katalog = Get.find<KatalogService>();
  final DateTime Function() _jam;

  final bahanDimiliki = <String>{}.obs;

  /// Bahan yang ditandai manual "segera habiskan".
  final ditandaiSegera = <String>{}.obs;

  /// Kapan tiap bahan ditempel.
  final sejak = <String, DateTime>{}.obs;

  final keyword = ''.obs;

  /// Nama kategori yang disaring; '' berarti semua kategori.
  final kategoriAktif = ''.obs;
  final bumbuDasarAda = true.obs;

  /// Keyword setelah debounce; inilah yang dipakai menyaring.
  final _keywordAktif = ''.obs;

  @override
  void onInit() {
    super.onInit();
    final kulkas = _storage.bacaSet(StorageService.kunciKulkas);
    final sekarang = _jam();
    final tersimpan = _storage.bacaPetaTeks(StorageService.kunciSejak);
    bahanDimiliki.assignAll(kulkas);
    // Tanggal yang hilang/rusak dianggap "baru ditempel" (lihat migrasi).
    sejak.assignAll({
      for (final id in kulkas)
        id: DateTime.tryParse(tersimpan[id] ?? '') ?? sekarang,
    });
    ditandaiSegera.assignAll(
      _storage.bacaSet(StorageService.kunciSegera).intersection(kulkas),
    );
    bumbuDasarAda.value =
        _storage.bacaBool(StorageService.kunciBumbuDasar) ?? true;

    ever(
      bahanDimiliki,
      (isi) => _storage.simpanSet(StorageService.kunciKulkas, isi),
    );
    ever(
      ditandaiSegera,
      (isi) => _storage.simpanSet(StorageService.kunciSegera, isi),
    );
    ever(
      sejak,
      (isi) => _storage.simpanPetaTeks(StorageService.kunciSejak, {
        for (final e in isi.entries) e.key: e.value.toIso8601String(),
      }),
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

  DateTime get sekarang => _jam();

  bool get katalogSiap => _katalog.katalog.value != null;

  bool get kulkasKosong => bahanDimiliki.isEmpty;

  Map<String, Bahan> get _bahanById =>
      _katalog.katalog.value?.bahanById ?? const {};

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
    final byId = _bahanById;
    return [
      for (final id in bahanDimiliki)
        if (byId[id] != null) byId[id]!,
    ]..sort((a, b) => a.nama.compareTo(b.nama));
  }

  /// Id bahan yang perlu segera dihabiskan (tanda manual + otomatis dari
  /// masa simpan).
  Set<String> get bahanSegera => hitungBahanSegera(
    kulkas: bahanDimiliki,
    ditandai: ditandaiSegera,
    sejak: sejak,
    bahanById: _bahanById,
    sekarang: _jam(),
  );

  /// Bahan segera habis (urut nama) untuk banner di halaman Kulkas.
  List<Bahan> get daftarSegera {
    final byId = _bahanById;
    return [
      for (final id in bahanSegera)
        if (byId[id] != null) byId[id]!,
    ]..sort((a, b) => a.nama.compareTo(b.nama));
  }

  /// Resep yang siap dimasak atau kurang maksimal 2 bahan.
  int get jumlahResepCocok {
    if (kulkasKosong) return 0;
    return semuaHasil.where((h) => h.kurang.length <= 2 && h.persen > 0).length;
  }

  /// Kalimat kesegaran satu bahan untuk lembar opsi.
  String keterangan(Bahan bahan) => keteranganKesegaran(
    bahan,
    sejak[bahan.id],
    _jam(),
    ditandai: ditandaiSegera.contains(bahan.id),
  );

  void toggle(String id) => bahanDimiliki.contains(id) ? lepas(id) : tempel(id);

  /// Menempel bahan; tanggal tempel dicatat sekarang.
  void tempel(String id) => tempelBanyak([id]);

  void lepas(String id) => lepasBanyak([id]);

  /// Menempel beberapa bahan sekaligus (mis. dari daftar belanja). Bahan
  /// yang sudah ada tidak digeser tanggalnya. Mengembalikan id yang baru
  /// ditempel.
  Set<String> tempelBanyak(Iterable<String> ids) {
    final baru = ids.toSet().difference(bahanDimiliki);
    if (baru.isEmpty) return baru;
    final waktu = _jam();
    sejak.addAll({for (final id in baru) id: waktu});
    bahanDimiliki.addAll(baru);
    return baru;
  }

  /// Melepas beberapa bahan (mis. yang habis setelah memasak) beserta
  /// tanggal dan tanda segeranya. Mengembalikan id yang benar-benar dilepas.
  Set<String> lepasBanyak(Iterable<String> ids) {
    final lepas = ids.toSet().intersection(bahanDimiliki);
    if (lepas.isEmpty) return lepas;
    bahanDimiliki.removeAll(lepas);
    sejak.removeWhere((id, _) => lepas.contains(id));
    ditandaiSegera.removeAll(lepas);
    return lepas;
  }

  /// Menandai/menghapus tanda manual "segera habiskan" (hanya untuk bahan
  /// yang ada di kulkas).
  void toggleSegera(String id) {
    if (!bahanDimiliki.contains(id)) return;
    if (!ditandaiSegera.remove(id)) ditandaiSegera.add(id);
  }

  /// "Masih segar": hapus tanda manual dan hitung ulang umur dari hari ini.
  void tandaiSegar(String id) {
    if (!bahanDimiliki.contains(id)) return;
    ditandaiSegera.remove(id);
    sejak[id] = _jam();
  }

  void kosongkan() {
    bahanDimiliki.clear();
    sejak.clear();
    ditandaiSegera.clear();
  }

  void konfirmasiKosongkan() {
    konfirmasi(
      judul: 'Kosongkan kulkas?',
      pesan:
          'Semua ${bahanDimiliki.length} bahan yang ditempel akan dilepas. '
          'Resep favorit tidak ikut terhapus.',
      teksYa: 'Kosongkan',
      onYa: () {
        final cadangan = (
          kulkas: {...bahanDimiliki},
          sejak: {...sejak},
          segera: {...ditandaiSegera},
        );
        kosongkan();
        tampilkanInfo(
          'Kulkas dikosongkan',
          labelAksi: 'Urungkan',
          onAksi: () {
            sejak.assignAll(cadangan.sejak);
            bahanDimiliki.assignAll(cadangan.kulkas);
            ditandaiSegera.assignAll(cadangan.segera);
          },
        );
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

  /// Hasil cocok semua resep sesuai isi kulkas, opsi bumbu dasar, dan bahan
  /// yang segera habis.
  List<HasilCocok> get semuaHasil {
    final katalog = _katalog.katalog.value;
    if (katalog == null) return const [];
    return cocokkanSemua(
      katalog,
      bahanDimiliki,
      bumbuDasarAda: bumbuDasarAda.value,
      segera: bahanSegera,
    );
  }
}
