import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../controllers/main_controller.dart';
import '../../../data/models/bahan_model.dart';
import '../../../data/models/belanja_model.dart';
import '../../../data/models/hasil_cocok.dart';
import '../../../data/services/katalog_service.dart';
import '../../../data/services/storage_service.dart';
import '../../../utils/daftar_belanja.dart';
import '../../../utils/notifikasi.dart';
import '../../kulkas/controllers/kulkas_controller.dart';

/// Daftar belanja. Permanent: dipakai kartu resep, detail, dan tab Belanja.
///
/// Mencentang "dibeli" langsung menempelkan bahan ke kulkas; membatalkan
/// centang melepasnya lagi (hanya bila centang itu yang memasukkannya).
class BelanjaController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();
  final KulkasController _kulkas = Get.find<KulkasController>();
  final KatalogService _katalog = Get.find<KatalogService>();

  final daftar = <ItemBelanja>[].obs;

  @override
  void onInit() {
    super.onInit();
    daftar.assignAll(
      bacaDaftarBelanja(_storage.bacaDaftarPeta(StorageService.kunciBelanja)),
    );
    ever(
      daftar,
      (isi) => _storage.simpanDaftarPeta(StorageService.kunciBelanja, [
        for (final e in isi) e.toJson(),
      ]),
    );
  }

  Map<String, Bahan> get bahanById =>
      _katalog.katalog.value?.bahanById ?? const {};

  List<ItemBelanja> get perluDibeli => daftar.where((e) => !e.dibeli).toList();

  List<ItemBelanja> get sudahDibeli => daftar.where((e) => e.dibeli).toList();

  int get jumlahPerlu => daftar.where((e) => !e.dibeli).length;

  /// Bahan ini sedang menunggu dibeli.
  bool menunggu(String bahanId) =>
      daftar.any((e) => e.bahanId == bahanId && !e.dibeli);

  /// Bahan dari [ids] yang belum menunggu di daftar.
  Set<String> belumAda(Iterable<String> ids) => belumDiDaftar(daftar, ids);

  /// Menambah bahan; mengembalikan jumlah yang benar-benar ditambahkan.
  int tambah(Iterable<String> ids, {String? resepId}) {
    final hasil = tambahKeDaftar(daftar, ids, resepId: resepId);
    if (hasil.ditambah > 0) daftar.assignAll(hasil.daftar);
    return hasil.ditambah;
  }

  /// Mencentang / membatalkan centang "dibeli".
  void setelDibeli(String bahanId, bool dibeli) {
    final i = daftar.indexWhere((e) => e.bahanId == bahanId);
    if (i < 0 || daftar[i].dibeli == dibeli) return;
    if (dibeli) {
      final baruMasuk = _kulkas.tempelBanyak([bahanId]).isNotEmpty;
      daftar[i] = daftar[i].salin(dibeli: true, masukKulkas: baruMasuk);
    } else {
      if (daftar[i].masukKulkas) _kulkas.lepas(bahanId);
      daftar[i] = daftar[i].salin(dibeli: false, masukKulkas: false);
    }
  }

  void toggleDibeli(String bahanId) {
    final i = daftar.indexWhere((e) => e.bahanId == bahanId);
    if (i >= 0) setelDibeli(bahanId, !daftar[i].dibeli);
  }

  /// Menghapus satu baris (kulkas tidak berubah). Mengembalikan posisi dan
  /// isinya untuk "Urungkan", atau null bila tidak ada.
  ({int posisi, ItemBelanja item})? hapus(String bahanId) {
    final i = daftar.indexWhere((e) => e.bahanId == bahanId);
    if (i < 0) return null;
    return (posisi: i, item: daftar.removeAt(i));
  }

  void kembalikan(int posisi, ItemBelanja item) {
    if (daftar.any((e) => e.bahanId == item.bahanId)) return;
    daftar.insert(posisi.clamp(0, daftar.length), item);
  }

  /// Membuang baris yang sudah dibeli (bahannya tetap di kulkas).
  int bersihkanDibeli() {
    final jumlah = sudahDibeli.length;
    if (jumlah > 0) daftar.removeWhere((e) => e.dibeli);
    return jumlah;
  }

  // ---- Aksi dari UI (dengan umpan balik) ----

  /// Menambah semua bahan kurang sebuah resep ke daftar belanja.
  void tambahDariResep(HasilCocok hasil) {
    HapticFeedback.lightImpact();
    final jumlah = tambah(hasil.kurang, resepId: hasil.resep.id);
    if (jumlah == 0) {
      tampilkanInfo('Bahan yang kurang sudah ada di daftar belanja');
      return;
    }
    tampilkanSukses(
      '$jumlah bahan ditambahkan ke daftar belanja',
      labelAksi: 'Lihat',
      onAksi: bukaTab,
    );
  }

  void hapusDenganUrungkan(String bahanId) {
    final terhapus = hapus(bahanId);
    if (terhapus == null) return;
    final nama = bahanById[bahanId]?.nama ?? bahanId;
    tampilkanInfo(
      '$nama dihapus dari daftar belanja',
      labelAksi: 'Urungkan',
      onAksi: () => kembalikan(terhapus.posisi, terhapus.item),
    );
  }

  Future<void> salin() async {
    await Clipboard.setData(
      ClipboardData(text: teksDaftarBelanja(daftar, bahanById)),
    );
    tampilkanSukses('Daftar belanja disalin, tinggal tempel di chat');
  }

  void bukaTab() =>
      Get.find<MainController>().pindahTab(MainController.tabBelanja);
}
