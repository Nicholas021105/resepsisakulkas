import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text.dart';

void _snackbar(String judul, String pesan, IconData ikon, Color warnaIkon) {
  _gantiSnackbar();
  Get.snackbar(
    judul,
    pesan,
    snackPosition: SnackPosition.BOTTOM,
    icon: Icon(ikon, color: warnaIkon),
    backgroundColor: AppColors.tinta,
    colorText: AppColors.putih,
    borderRadius: AppSpacing.radiusM,
    margin: const EdgeInsets.fromLTRB(
      AppSpacing.m,
      0,
      AppSpacing.m,
      AppSpacing.xxxl + AppSpacing.xxl,
    ),
  );
}

void tampilkanSukses(String pesan) =>
    _snackbar('Berhasil', pesan, Icons.check_circle, AppColors.aksenLembut);

void tampilkanInfo(String pesan) =>
    _snackbar('Info', pesan, Icons.info_outline, AppColors.wortelLembut);

/// Menutup dialog/bottom sheet teratas. `Get.back()` di GetX 4 menutup
/// snackbar lebih dulu bila ada yang tampil, jadi navigator dipakai langsung.
void tutupOverlay() => Get.key.currentState?.pop();

/// Dialog konfirmasi untuk aksi berisiko.
void konfirmasi({
  required String judul,
  required String pesan,
  required String teksYa,
  required VoidCallback onYa,
}) {
  Get.defaultDialog(
    title: judul,
    titleStyle: AppText.textTheme.headlineSmall,
    // Isi dibatasi tingginya dan bisa digulir agar pesan panjang tidak
    // meluap di layar kecil atau dengan huruf besar.
    content: ConstrainedBox(
      constraints: BoxConstraints(maxHeight: Get.height * 0.2),
      child: SingleChildScrollView(
        child: Text(
          pesan,
          textAlign: TextAlign.center,
          style: AppText.textTheme.bodyMedium,
        ),
      ),
    ),
    backgroundColor: AppColors.permukaan,
    radius: AppSpacing.radiusL,
    titlePadding: const EdgeInsets.fromLTRB(
      AppSpacing.xl,
      AppSpacing.xl,
      AppSpacing.xl,
      0,
    ),
    contentPadding: const EdgeInsets.all(AppSpacing.xl),
    cancel: const TextButton(onPressed: tutupOverlay, child: Text('Batal')),
    confirm: FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.wortelTeks,
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
