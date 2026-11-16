import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:resepsisakulkas/app/data/models/hasil_cocok.dart';
import 'package:resepsisakulkas/app/data/models/katalog_model.dart';
import 'package:resepsisakulkas/app/data/models/resep_model.dart';
import 'package:resepsisakulkas/app/modules/belanja/controllers/belanja_controller.dart';
import 'package:resepsisakulkas/app/modules/favorit/controllers/favorit_controller.dart';
import 'package:resepsisakulkas/app/modules/favorit/controllers/riwayat_controller.dart';
import 'package:resepsisakulkas/app/modules/kulkas/controllers/kulkas_controller.dart';
import 'package:resepsisakulkas/app/modules/kulkas/views/kulkas_view.dart';
import 'package:resepsisakulkas/app/modules/masak/controllers/masak_controller.dart';
import 'package:resepsisakulkas/app/modules/onboarding/controllers/onboarding_controller.dart';
import 'package:resepsisakulkas/app/modules/resep/controllers/resep_controller.dart';
import 'package:resepsisakulkas/app/routes/app_routes.dart';
import 'package:resepsisakulkas/app/theme/app_spacing.dart';
import 'package:resepsisakulkas/app/theme/app_theme.dart';
import 'package:resepsisakulkas/app/utils/notifikasi.dart';
import 'package:resepsisakulkas/app/widgets/ikon_bahan.dart';
import 'package:resepsisakulkas/app/widgets/sampul_resep.dart';

import '../test/helpers/aplikasi_uji.dart';
import 'helper_foto.dart';

/// Render setiap halaman ResepSisaKulkas ke screenshots/resepsisakulkas/.
/// Jalankan: flutter test screenshot_test/
const app = 'resepsisakulkas';

/// Isi kulkas contoh: 7 bahan umum → ada resep 100% dan sebagian.
const kulkasContoh = {
  'telur',
  'tempe',
  'tahu',
  'bawang-merah',
  'bawang-putih',
  'cabai',
  'kecap-manis',
};

/// Jam tetap agar umur bahan dan riwayat di screenshot stabil.
final kini = DateTime(2026, 11, 16, 18, 30);

/// Bayam ditempel 3 hari lalu (lewat masa segar), tahu 2 hari lalu.
final sejakContoh = {
  'bayam': kini.subtract(const Duration(days: 3)).toIso8601String(),
  'tahu': kini.subtract(const Duration(days: 2)).toIso8601String(),
};

const kulkasSegera = {...kulkasContoh, 'bayam'};

void main() {
  late Katalog katalog;

  setUpAll(() async {
    await initializeDateFormatting('id_ID');
    await muatFont({
      'BricolageGrotesque': ['assets/fonts/BricolageGrotesque-Variable.ttf'],
      'DMSans': ['assets/fonts/DMSans-Variable.ttf'],
    });
    katalog = Katalog.fromJson(
      jsonDecode(await rootBundle.loadString('assets/data/resep.json'))
          as Map<String, dynamic>,
    );
  });

  Future<void> render(
    WidgetTester tester,
    String nama, {
    String rute = Routes.kulkas,
    Set<String> kulkas = kulkasContoh,
    Set<String> favorit = const {},
    bool gagal = false,
    double skala = 1,
    void Function()? lanjutan,
    String? gulirKe,
    bool gelap = false,
    Map<String, String> sejak = const {},
    Set<String> segera = const {},
  }) async {
    aturLayar(tester, skala: skala);
    siapkanDependensi(
      ambil: () async {
        if (gagal) throw Exception('gagal');
        return HasilAmbil(katalog: katalog, sumber: SumberData.bawaan);
      },
      kulkas: kulkas,
      favorit: favorit,
      sejak: sejak,
      segera: segera,
      jam: () => kini,
    );
    await tester.pumpWidget(
      RepaintBoundary(
        key: kunciLayar,
        child: aplikasiUji(
          rute: rute,
          tema: denganEmoji(AppTheme.terang),
          temaGelap: denganEmoji(AppTheme.gelap),
          mode: gelap ? ThemeMode.dark : ThemeMode.light,
        ),
      ),
    );
    await tester.pumpAndSettle();
    if (lanjutan != null) {
      lanjutan();
      await tester.pumpAndSettle();
    }
    if (gulirKe != null) {
      // Gulir pintu kulkas sampai magnet ini berada dekat atas layar.
      await Scrollable.ensureVisible(
        tester.element(find.byKey(Key(gulirKe))),
        alignment: 0.12,
      );
      await tester.pumpAndSettle();
    }
    await foto(tester, app, nama);

    // Habiskan snackbar/timer yang mungkin masih berjalan.
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(seconds: 1));
    }
    await tester.pumpWidget(const SizedBox());
    Get.reset();
  }

  void filter(FilterHasil f) => Get.find<ResepController>().pilihFilter(f);

  testWidgets(
    '01 kulkas kosong',
    (t) => render(t, '01_kulkas_kosong', kulkas: const {}),
  );

  testWidgets('02 kulkas terisi', (t) => render(t, '02_kulkas_terisi'));

  testWidgets(
    '03 kulkas font130',
    (t) => render(t, '03_kulkas_font130', skala: 1.3),
  );

  testWidgets(
    '04 dialog kosongkan',
    (t) => render(
      t,
      '04_dialog_kosongkan',
      lanjutan: () => Get.find<KulkasController>().konfirmasiKosongkan(),
    ),
  );

  testWidgets(
    '05 resep siap dimasak',
    (t) => render(t, '05_resep_siap', rute: Routes.resep),
  );

  testWidgets(
    '06 resep kurang 1-2',
    (t) => render(
      t,
      '06_resep_kurang_1_2',
      rute: Routes.resep,
      lanjutan: () => filter(FilterHasil.kurangSedikit),
    ),
  );

  testWidgets(
    '07 resep semua',
    (t) => render(
      t,
      '07_resep_semua',
      rute: Routes.resep,
      lanjutan: () => filter(FilterHasil.semua),
    ),
  );

  testWidgets(
    '08 detail resep (siap)',
    (t) => render(
      t,
      '08_detail_resep',
      rute: Routes.keDetail('orek-tempe'),
      favorit: const {'orek-tempe'},
    ),
  );

  testWidgets(
    '09 detail resep (kurang)',
    (t) => render(
      t,
      '09_detail_resep_kurang',
      rute: Routes.keDetail('nasi-goreng'),
    ),
  );

  testWidgets(
    '10 favorit',
    (t) => render(
      t,
      '10_favorit',
      rute: Routes.favorit,
      favorit: const {'orek-tempe', 'nasi-goreng', 'tahu-kecap'},
    ),
  );

  testWidgets(
    '11 favorit kosong',
    (t) => render(t, '11_favorit_kosong', rute: Routes.favorit),
  );

  testWidgets(
    '12 pengaturan',
    (t) => render(t, '12_pengaturan', rute: Routes.pengaturan),
  );

  testWidgets(
    '13 status error',
    (t) => render(t, '13_status_error', rute: Routes.resep, gagal: true),
  );

  testWidgets(
    '14 resep tidak ditemukan',
    (t) => render(
      t,
      '14_resep_tidak_ditemukan',
      rute: Routes.keDetail('rendang-sapi'),
    ),
  );

  testWidgets(
    '15 kulkas digulir ke Sayur',
    (t) => render(t, '15_kulkas_sayur', gulirKe: 'magnet-kangkung'),
  );

  testWidgets(
    '16 kulkas digulir ke Bumbu',
    (t) => render(t, '16_kulkas_bumbu', gulirKe: 'magnet-garam'),
  );

  testWidgets(
    '17 kulkas digulir ke akhir Bumbu',
    (t) => render(t, '17_kulkas_bumbu_bawah', gulirKe: 'magnet-saus-tomat'),
  );

  // --- Fitur versi 2 ---

  void isiBelanja() {
    Get.find<BelanjaController>()
      ..tambah(['nasi', 'kangkung'], resepId: 'nasi-goreng')
      ..tambah(['santan', 'jeruk-nipis'])
      ..setelDibeli('kangkung', true);
  }

  void isiRiwayat() {
    final riwayat = Get.find<RiwayatController>();
    for (final id in ['sop-ayam', 'orek-tempe', 'pisang-goreng', 'mie-rebus']) {
      riwayat.catat(katalog.resepById(id)!);
    }
    Get.find<FavoritController>().lihatRiwayat.value = true;
  }

  void keLangkah(int index) =>
      Get.find<MasakController>().pageController.jumpToPage(index);

  void keSelesai() {
    final c = Get.find<MasakController>();
    c.pageController.jumpToPage(c.jumlahLangkah);
  }

  for (final gelap in [false, true]) {
    final akhiran = gelap ? '_gelap' : '';
    final ket = gelap ? ' (gelap)' : '';

    testWidgets(
      '19 kulkas dengan bahan segera habis$ket',
      (t) => render(
        t,
        '19_kulkas_segera$akhiran',
        kulkas: kulkasSegera,
        sejak: sejakContoh,
        gelap: gelap,
      ),
    );

    testWidgets(
      '20 lembar opsi bahan$ket',
      (t) => render(
        t,
        '20_lembar_opsi_bahan$akhiran',
        kulkas: kulkasSegera,
        sejak: sejakContoh,
        gelap: gelap,
        lanjutan: () => bukaLembar<void>(
          LembarOpsiBahan(bahan: katalog.bahanById['bayam']!),
        ),
      ),
    );

    testWidgets(
      '21 resep: saran + penyelamat bahan$ket',
      (t) => render(
        t,
        '21_resep_jelajah$akhiran',
        rute: Routes.resep,
        kulkas: kulkasSegera,
        sejak: sejakContoh,
        gelap: gelap,
        lanjutan: () => filter(FilterHasil.semua),
      ),
    );

    testWidgets(
      '22 detail resep$ket',
      (t) => render(
        t,
        '22_detail$akhiran',
        rute: Routes.keDetail('sayur-bening-bayam'),
        kulkas: kulkasSegera,
        sejak: sejakContoh,
        favorit: const {'sayur-bening-bayam'},
        gelap: gelap,
      ),
    );

    testWidgets(
      '23 belanja$ket',
      (t) => render(
        t,
        '23_belanja$akhiran',
        rute: Routes.belanja,
        gelap: gelap,
        lanjutan: isiBelanja,
      ),
    );

    testWidgets(
      '24 mode masak: langkah bertimer$ket',
      (t) => render(
        t,
        '24_masak_langkah$akhiran',
        rute: Routes.keMasak('sop-ayam'),
        gelap: gelap,
        lanjutan: () => Get.find<MasakController>()
          ..mulaiAtauJeda(0)
          ..sisaDetik.value = 754,
      ),
    );

    testWidgets(
      '25 mode masak: selesai$ket',
      (t) => render(
        t,
        '25_masak_selesai$akhiran',
        rute: Routes.keMasak('orek-tempe'),
        gelap: gelap,
        lanjutan: keSelesai,
      ),
    );

    testWidgets(
      '26 riwayat masak$ket',
      (t) => render(
        t,
        '26_riwayat$akhiran',
        rute: Routes.favorit,
        gelap: gelap,
        lanjutan: isiRiwayat,
      ),
    );

    testWidgets(
      '27 pengaturan$ket',
      (t) => render(
        t,
        '27_pengaturan$akhiran',
        rute: Routes.pengaturan,
        gelap: gelap,
      ),
    );

    for (var i = 0; i < OnboardingController.jumlahHalaman; i++) {
      testWidgets(
        '28 onboarding layar ${i + 1}$ket',
        (t) => render(
          t,
          '28_onboarding_${i + 1}$akhiran',
          rute: Routes.onboarding,
          gelap: gelap,
          lanjutan: () =>
              Get.find<OnboardingController>().pageController.jumpToPage(i),
        ),
      );
    }
  }

  testWidgets(
    '29 belanja kosong',
    (t) => render(t, '29_belanja_kosong', rute: Routes.belanja),
  );

  testWidgets(
    '30 mode masak: langkah tanpa timer, font 130%',
    (t) => render(
      t,
      '30_masak_font130',
      rute: Routes.keMasak('sop-ayam'),
      skala: 1.3,
      lanjutan: () => keLangkah(1),
    ),
  );

  testWidgets(
    '31 resep: pencarian',
    (t) => render(
      t,
      '31_resep_cari',
      rute: Routes.resep,
      lanjutan: () {
        final c = Get.find<ResepController>();
        c.teksCari.text = 'tempe';
        c
          ..cari('tempe')
          ..pilihFilter(FilterHasil.semua)
          ..pilihUrutan(UrutanResep.tercepat);
      },
    ),
  );

  // Lembar periksa: sampul semua jenis sajian × beberapa resep.
  testWidgets('32 sampul resep', (tester) async {
    aturLayar(tester);
    siapkanDependensi(
      ambil: () async =>
          HasilAmbil(katalog: katalog, sumber: SumberData.bawaan),
    );
    final tema = denganEmoji(AppTheme.terang);
    await tester.pumpWidget(
      RepaintBoundary(
        key: kunciLayar,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: tema,
          home: Scaffold(
            appBar: AppBar(title: const Text('Sampul resep')),
            body: GridView.count(
              crossAxisCount: 4,
              padding: const EdgeInsets.all(AppSpacing.m),
              mainAxisSpacing: AppSpacing.s,
              crossAxisSpacing: AppSpacing.s,
              children: [
                for (final sajian in JenisSajian.values)
                  for (final r
                      in katalog.resep.where((r) => r.sajian == sajian).take(4))
                    SampulResep(resep: r, ukuran: 76),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await foto(tester, app, '32_sampul_resep');
    await tester.pumpWidget(const SizedBox());
    Get.reset();
  });

  // Lembar periksa: semua ikon pelukis pada 20, 28, dan 32 px.
  testWidgets('18 ikon bahan pelukis', (tester) async {
    aturLayar(tester);
    const id = [
      ('tahu', 'Tahu'),
      ('tempe', 'Tempe'),
      ('kecap-manis', 'Kecap manis'),
      ('buncis', 'Buncis'),
      ('minyak-goreng', 'Minyak goreng'),
      ('bawang-merah', 'Bawang merah'),
      ('bawang-putih', 'Bawang putih'),
      ('margarin', 'Margarin'),
      ('saus-tiram', 'Saus tiram'),
    ];
    final tema = denganEmoji(AppTheme.terang);
    await tester.pumpWidget(
      RepaintBoundary(
        key: kunciLayar,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: tema,
          home: Scaffold(
            appBar: AppBar(title: const Text('Ikon bahan (20 · 28 · 32 px)')),
            body: ListView(
              padding: const EdgeInsets.all(AppSpacing.l),
              children: [
                for (final (kode, nama) in id)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.m),
                    child: Row(
                      children: [
                        for (final u in [20.0, 28.0, 32.0]) ...[
                          SizedBox(
                            width: 48,
                            child: Center(
                              child: IkonBahan(id: kode, emoji: '?', ukuran: u),
                            ),
                          ),
                        ],
                        const SizedBox(width: AppSpacing.m),
                        Expanded(
                          child: Text(nama, style: tema.textTheme.titleMedium),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await foto(tester, app, '18_ikon_bahan');
    await tester.pumpWidget(const SizedBox());
  });
}
