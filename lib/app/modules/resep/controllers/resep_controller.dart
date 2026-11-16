import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../data/models/bahan_model.dart';
import '../../../data/models/hasil_cocok.dart';
import '../../../data/models/resep_model.dart';
import '../../../data/services/katalog_service.dart';
import '../../../utils/pencocok_resep.dart';
import '../../kulkas/controllers/kulkas_controller.dart';

/// Daftar resep cocok dengan empat status StateMixin:
/// loading (katalog belum ada), error (gagal muat), empty, success.
///
/// Urutan pengolahan: semua hasil cocok → jelajah (kata kunci + kategori)
/// → filter kecocokan → urutan.
class ResepController extends GetxController with StateMixin<List<HasilCocok>> {
  final KulkasController _kulkas = Get.find<KulkasController>();
  final KatalogService _katalog = Get.find<KatalogService>();

  static const jedaPencarian = Duration(milliseconds: 300);

  final filter = FilterHasil.siap.obs;
  final urutan = UrutanResep.cocok.obs;

  /// Kategori hidangan yang dipilih; null = semua.
  final kategori = Rxn<KategoriResep>();

  /// Teks pencarian apa adanya; [_kataAktif] versi setelah debounce.
  final kataKunci = ''.obs;
  final _kataAktif = ''.obs;
  final teksCari = TextEditingController();

  /// Berapa kali pengguna meminta "saran lain" hari ini.
  final geserSaran = 0.obs;

  @override
  void onInit() {
    super.onInit();
    everAll([
      _kulkas.bahanDimiliki,
      _kulkas.bumbuDasarAda,
      _kulkas.ditandaiSegera,
      _kulkas.sejak,
      filter,
      urutan,
      kategori,
      _kataAktif,
      _katalog.katalog,
      _katalog.galat,
    ], (_) => hitungUlang());
    debounce(
      kataKunci,
      (teks) => _kataAktif.value = teks.trim(),
      time: jedaPencarian,
    );
    hitungUlang();
  }

  @override
  void onClose() {
    teksCari.dispose();
    super.onClose();
  }

  Map<String, Bahan> get _bahanById =>
      _katalog.katalog.value?.bahanById ?? const {};

  bool get sedangMencari => _kataAktif.value.isNotEmpty;

  /// Ada kata kunci atau kategori yang aktif.
  bool get sedangMenjelajah => sedangMencari || kategori.value != null;

  /// Saat mencari dengan kata kunci, resep 0% tetap ditemukan di "Semua".
  bool get _tampilkanNol => _kulkas.kulkasKosong || sedangMencari;

  List<HasilCocok> get _terjelajah => jelajahResep(
    _kulkas.semuaHasil,
    kataKunci: _kataAktif.value,
    kategori: kategori.value,
    bahanById: _bahanById,
  );

  /// Jumlah resep per filter (untuk label chip), mengikuti pencarian dan
  /// kategori yang aktif.
  Map<FilterHasil, int> get jumlahPerFilter {
    final dasar = _terjelajah;
    return {
      for (final f in FilterHasil.values)
        f: saringHasil(dasar, f, kulkasKosong: _tampilkanNol).length,
    };
  }

  /// Kategori hidangan yang ada di katalog (urut enum); "Lainnya" hanya
  /// bila memang ada resep tanpa kategori.
  List<KategoriResep> get kategoriTersedia {
    final ada = {
      for (final r in _katalog.katalog.value?.resep ?? const <Resep>[])
        r.kategori,
    };
    return KategoriResep.values.where(ada.contains).toList();
  }

  /// Saran "Masak apa hari ini?"; sama sepanjang hari kecuali digeser.
  HasilCocok? get saran {
    final hari = _kulkas.sekarang;
    final hariKe =
        DateTime.utc(hari.year, hari.month, hari.day).millisecondsSinceEpoch ~/
        Duration.millisecondsPerDay;
    return saranHariIni(_kulkas.semuaHasil, benih: hariKe + geserSaran.value);
  }

  void saranLain() => geserSaran.value++;

  void pilihFilter(FilterHasil f) => filter.value = f;

  void pilihUrutan(UrutanResep u) => urutan.value = u;

  /// Memilih kategori; memilih yang sedang aktif = kembali ke semua.
  void pilihKategori(KategoriResep? k) =>
      kategori.value = kategori.value == k ? null : k;

  void cari(String teks) => kataKunci.value = teks;

  void hapusPencarian() {
    teksCari.clear();
    if (kataKunci.value.isNotEmpty) kataKunci.value = '';
    _kataAktif.value = '';
  }

  /// Menampilkan resep penyelamat bahan yang segera habis: semua resep,
  /// urutan "paling cocok" (yang memakai bahan itu ada di atas).
  void tampilkanPenyelamat() {
    hapusPencarian();
    kategori.value = null;
    urutan.value = UrutanResep.cocok;
    filter.value = FilterHasil.semua;
  }

  /// Katalog gagal dimuat (status error). Dibaca dari Rx agar bisa dipakai
  /// di Obx (status StateMixin bukan observable Obx).
  bool get gagalMuat =>
      _katalog.katalog.value == null && _katalog.galat.value != null;

  bool get katalogSiap => _katalog.katalog.value != null;

  void hitungUlang() {
    final galat = _katalog.galat.value;
    if (_katalog.katalog.value == null) {
      change(
        null,
        status: galat != null ? RxStatus.error(galat) : RxStatus.loading(),
      );
      return;
    }
    final hasil = urutkanHasil(
      saringHasil(_terjelajah, filter.value, kulkasKosong: _tampilkanNol),
      urutan.value,
    );
    change(
      hasil,
      status: hasil.isEmpty ? RxStatus.empty() : RxStatus.success(),
    );
  }

  /// Dipanggil tombol "Coba lagi" pada status error.
  Future<void> cobaLagi() async {
    change(null, status: RxStatus.loading());
    await _katalog.muat();
    hitungUlang();
  }
}
