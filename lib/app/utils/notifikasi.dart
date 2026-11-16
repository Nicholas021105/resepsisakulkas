import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../theme/app_palet.dart';
import '../theme/app_spacing.dart';

/// Palet tema aktif untuk overlay yang dibuat tanpa BuildContext halaman
/// (snackbar & dialog GetX).
Palet get _palet => Get.theme.extension<Palet>() ?? Palet.terang;

void _snackbar(
  String judul,
  String pesan,
  IconData ikon,
  Color warnaIkon, {
  String? labelAksi,
  VoidCallback? onAksi,
}) {
  final p = _palet;
  _gantiSnackbar();
  Get.snackbar(
    judul,
    pesan,
    snackPosition: SnackPosition.BOTTOM,
    icon: Icon(ikon, color: warnaIkon),
    backgroundColor: p.balik,
    colorText: p.diBalik,
    borderRadius: AppSpacing.radiusM,
    duration: Duration(seconds: labelAksi == null ? 3 : 5),
    margin: const EdgeInsets.fromLTRB(
      AppSpacing.m,
      0,
      AppSpacing.m,
      AppSpacing.xxxl + AppSpacing.xxl,
    ),
    mainButton: labelAksi == null || onAksi == null
        ? null
        : TextButton(
            style: TextButton.styleFrom(foregroundColor: p.diBalik),
            onPressed: () {
              _gantiSnackbar();
              onAksi();
            },
            child: Text(labelAksi),
          ),
  );
}

/// Umpan balik berhasil; [labelAksi] + [onAksi] menambah tombol (mis.
/// "Urungkan").
void tampilkanSukses(String pesan, {String? labelAksi, VoidCallback? onAksi}) =>
    _snackbar(
      'Berhasil',
      pesan,
      Icons.check_circle,
      _palet.modeGelap ? _palet.aksenTua : _palet.aksenLembut,
      labelAksi: labelAksi,
      onAksi: onAksi,
    );

void tampilkanInfo(String pesan, {String? labelAksi, VoidCallback? onAksi}) =>
    _snackbar(
      'Info',
      pesan,
      Icons.info_outline,
      _palet.modeGelap ? _palet.wortelTeks : _palet.wortelLembut,
      labelAksi: labelAksi,
      onAksi: onAksi,
    );

/// Menutup dialog/bottom sheet teratas. `Get.back()` di GetX 4 menutup
/// snackbar lebih dulu bila ada yang tampil, jadi navigator dipakai langsung.
void tutupOverlay() => Get.key.currentState?.pop();

/// Dialog konfirmasi untuk aksi berisiko.
void konfirmasi({
  required String judul,
  required String pesan,
  required String teksYa,
  required VoidCallback onYa,
  String teksBatal = 'Batal',
}) {
  final p = _palet;
  final teks = Get.textTheme;
  Get.defaultDialog(
    title: judul,
    titleStyle: teks.headlineSmall,
    // Isi dibatasi tingginya dan bisa digulir agar pesan panjang tidak
    // meluap di layar kecil atau dengan huruf besar.
    content: ConstrainedBox(
      constraints: BoxConstraints(maxHeight: Get.height * 0.2),
      child: SingleChildScrollView(
        child: Text(pesan, textAlign: TextAlign.center, style: teks.bodyMedium),
      ),
    ),
    backgroundColor: p.permukaanTinggi,
    radius: AppSpacing.radiusL,
    titlePadding: const EdgeInsets.fromLTRB(
      AppSpacing.xl,
      AppSpacing.xl,
      AppSpacing.xl,
      0,
    ),
    contentPadding: const EdgeInsets.all(AppSpacing.xl),
    cancel: TextButton(onPressed: tutupOverlay, child: Text(teksBatal)),
    confirm: FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: p.wortelTeks,
        foregroundColor: p.diBalik,
        minimumSize: const Size(AppSpacing.sentuh, AppSpacing.sentuh),
      ),
      onPressed: () {
        tutupOverlay();
        onYa();
      },
      child: Text(teksYa),
    ),
  );
}

/// GetX mengantre snackbar; snackbar yang sedang tampil ditutup agar umpan
/// balik terbaru langsung terlihat.
void _gantiSnackbar() => Get.closeCurrentSnackbar();

/// Lembar bawah bergaya aplikasi: pegangan di atas, isi bisa digulir (aman
/// untuk layar kecil dan huruf besar), mengikuti tema aktif.
Future<T?> bukaLembar<T>(Widget isi) {
  final p = _palet;
  return Get.bottomSheet<T>(
    // Naik bersama keyboard (lembar berisi kolom pencarian).
    Builder(
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: _isiLembar(p, isi),
      ),
    ),
    backgroundColor: p.permukaanTinggi,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppSpacing.radiusL),
      ),
    ),
  );
}

Widget _isiLembar(Palet p, Widget isi) {
  return (SafeArea(
    child: ConstrainedBox(
      constraints: BoxConstraints(maxHeight: Get.height * 0.85),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: AppSpacing.xxl,
            height: AppSpacing.xs,
            margin: const EdgeInsets.symmetric(vertical: AppSpacing.m),
            decoration: BoxDecoration(
              color: p.garis,
              borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.l,
                0,
                AppSpacing.l,
                AppSpacing.l,
              ),
              child: isi,
            ),
          ),
        ],
      ),
    ),
  ));
}
