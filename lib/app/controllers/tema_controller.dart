import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/services/storage_service.dart';

/// Pilihan tema: ikuti sistem, terang, atau gelap. Disimpan di storage.
class TemaController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();

  final mode = ThemeMode.system.obs;

  static const _nama = {
    ThemeMode.system: 'sistem',
    ThemeMode.light: 'terang',
    ThemeMode.dark: 'gelap',
  };

  /// Mode tersimpan; nilai tak dikenal dianggap "ikuti sistem".
  static ThemeMode bacaMode(StorageService storage) {
    final teks = storage.bacaTeks(StorageService.kunciTema);
    for (final e in _nama.entries) {
      if (e.value == teks) return e.key;
    }
    return ThemeMode.system;
  }

  @override
  void onInit() {
    super.onInit();
    mode.value = bacaMode(_storage);
  }

  void ubah(ThemeMode baru) {
    if (baru == mode.value) return;
    mode.value = baru;
    _storage.simpanTeks(StorageService.kunciTema, _nama[baru]!);
    Get.changeThemeMode(baru);
  }
}
