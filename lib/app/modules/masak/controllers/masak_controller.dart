import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../controllers/main_controller.dart';
import '../../../data/models/bahan_model.dart';
import '../../../data/models/resep_model.dart';
import '../../../data/services/katalog_service.dart';
import '../../../theme/app_spacing.dart';
import '../../../utils/durasi_langkah.dart';
import '../../../utils/notifikasi.dart';
import '../../favorit/controllers/riwayat_controller.dart';
import '../../kulkas/controllers/kulkas_controller.dart';

/// Mode masak `/resep/:id/masak`: satu langkah per layar, timer untuk
/// langkah berdurasi, lalu layar selesai yang menawarkan melepas bahan yang
/// habis dari kulkas dan mencatat riwayat.
class MasakController extends GetxController {
  final KatalogService _katalog = Get.find<KatalogService>();
  final KulkasController _kulkas = Get.find<KulkasController>();
  final RiwayatController _riwayat = Get.find<RiwayatController>();

  late final String id;
  final pageController = PageController();

  /// Halaman aktif: 0 … jumlahLangkah−1 = langkah, jumlahLangkah = selesai.
  final halaman = 0.obs;

  /// Langkah yang timernya sedang dipakai (null = belum ada timer).
  final langkahTimer = RxnInt();
  final sisaDetik = 0.obs;
  final timerJalan = false.obs;
  Timer? _timer;

  /// Bahan yang dicentang "habis" di layar selesai.
  final habis = <String>{}.obs;
  bool _habisDisiapkan = false;

  @override
  void onInit() {
    super.onInit();
    id = Get.parameters['id'] ?? '';
  }

  @override
  void onClose() {
    _timer?.cancel();
    pageController.dispose();
    super.onClose();
  }

  bool get katalogSiap => _katalog.katalog.value != null;

  Resep? get resep => _katalog.katalog.value?.resepById(id);

  Map<String, Bahan> get bahanById =>
      _katalog.katalog.value?.bahanById ?? const {};

  int get jumlahLangkah => resep?.langkah.length ?? 0;

  bool get diLayarSelesai => halaman.value >= jumlahLangkah;

  Duration? durasi(int langkah) {
    final daftar = resep?.langkah ?? const <String>[];
    return langkah < daftar.length ? durasiLangkah(daftar[langkah]) : null;
  }

  /// Bahan resep ini yang ada di kulkas dan bisa habis (bukan bumbu dasar).
  List<Bahan> get bahanTerpakai {
    final byId = bahanById;
    return [
      for (final b in resep?.bahan ?? const <BahanResep>[])
        if (byId[b.bahanId] case final bahan?
            when !bahan.bumbuDasar && _kulkas.bahanDimiliki.contains(bahan.id))
          bahan,
    ];
  }

  // ---- Navigasi langkah ----

  void halamanBerubah(int index) {
    halaman.value = index;
    HapticFeedback.selectionClick();
    if (index >= jumlahLangkah && !_habisDisiapkan) {
      // Usulan awal: bahan yang memang sudah "segera habiskan".
      _habisDisiapkan = true;
      final segera = _kulkas.bahanSegera;
      habis.assignAll([
        for (final b in bahanTerpakai)
          if (segera.contains(b.id)) b.id,
      ]);
      HapticFeedback.heavyImpact();
    }
  }

  void _ke(int index) {
    if (!pageController.hasClients) return;
    if (MediaQuery.disableAnimationsOf(Get.context!)) {
      pageController.jumpToPage(index);
    } else {
      pageController.animateToPage(
        index,
        duration: AppGerak.sedang,
        curve: Curves.easeOutCubic,
      );
    }
  }

  void berikut() => _ke(halaman.value + 1);

  void sebelum() => _ke(halaman.value - 1);

  // ---- Timer ----

  /// Sisa waktu untuk ditampilkan di [langkah]: timer aktifnya, atau durasi
  /// penuh bila timer belum dimulai untuk langkah itu.
  int sisaUntuk(int langkah) => langkahTimer.value == langkah
      ? sisaDetik.value
      : (durasi(langkah)?.inSeconds ?? 0);

  bool berjalanDi(int langkah) =>
      langkahTimer.value == langkah && timerJalan.value;

  bool habisDi(int langkah) =>
      langkahTimer.value == langkah &&
      sisaDetik.value == 0 &&
      !timerJalan.value;

  void mulaiAtauJeda(int langkah) {
    HapticFeedback.lightImpact();
    if (berjalanDi(langkah)) {
      _hentikan();
      return;
    }
    if (langkahTimer.value != langkah || sisaDetik.value == 0) {
      langkahTimer.value = langkah;
      sisaDetik.value = durasi(langkah)?.inSeconds ?? 0;
    }
    if (sisaDetik.value == 0) return;
    _timer?.cancel();
    timerJalan.value = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => detak());
  }

  /// Satu detik berlalu (dipanggil timer; publik agar bisa diuji).
  void detak() {
    if (!timerJalan.value) return;
    if (sisaDetik.value > 1) {
      sisaDetik.value--;
      return;
    }
    sisaDetik.value = 0;
    _hentikan();
    HapticFeedback.vibrate();
    SystemSound.play(SystemSoundType.alert);
    final nomor = (langkahTimer.value ?? 0) + 1;
    tampilkanSukses('Waktu langkah $nomor habis. Cek masakanmu!');
  }

  void tambahSemenit(int langkah) {
    HapticFeedback.selectionClick();
    if (langkahTimer.value != langkah) {
      langkahTimer.value = langkah;
      sisaDetik.value = durasi(langkah)?.inSeconds ?? 0;
    }
    sisaDetik.value += 60;
  }

  void ulangTimer(int langkah) {
    HapticFeedback.selectionClick();
    _hentikan();
    langkahTimer.value = langkah;
    sisaDetik.value = durasi(langkah)?.inSeconds ?? 0;
  }

  void _hentikan() {
    _timer?.cancel();
    _timer = null;
    timerJalan.value = false;
  }

  // ---- Selesai ----

  void toggleHabis(String bahanId) {
    HapticFeedback.selectionClick();
    if (!habis.remove(bahanId)) habis.add(bahanId);
  }

  /// Melepas bahan yang habis dari kulkas, mencatat riwayat, lalu kembali.
  void simpanSelesai() {
    final r = resep;
    if (r == null) return;
    final dilepas = _kulkas.lepasBanyak(habis);
    _riwayat.catat(r);
    _hentikan();
    HapticFeedback.mediumImpact();
    Get.find<MainController>().kembali();
    tampilkanSukses(
      dilepas.isEmpty
          ? '${r.nama} tercatat di riwayat masak'
          : '${r.nama} tercatat · ${dilepas.length} bahan habis dilepas '
                'dari kulkas',
    );
  }

  /// Keluar dari mode masak; bila sudah berjalan, minta konfirmasi dulu.
  void keluar() {
    final sudahJalan = halaman.value > 0 || langkahTimer.value != null;
    if (!sudahJalan || diLayarSelesai) {
      _tutup();
      return;
    }
    konfirmasi(
      judul: 'Berhenti memasak?',
      pesan: 'Kemajuan langkah dan timer tidak disimpan.',
      teksYa: 'Berhenti',
      teksBatal: 'Lanjut masak',
      onYa: _tutup,
    );
  }

  void _tutup() {
    _hentikan();
    Get.find<MainController>().kembali();
  }
}
