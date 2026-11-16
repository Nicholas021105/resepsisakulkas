import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:resepsisakulkas/app/data/models/bahan_model.dart';
import 'package:resepsisakulkas/app/data/models/katalog_model.dart';
import 'package:resepsisakulkas/app/data/services/storage_service.dart';
import 'package:resepsisakulkas/app/modules/kulkas/controllers/kulkas_controller.dart';
import 'package:resepsisakulkas/app/utils/kesegaran.dart';
import 'package:resepsisakulkas/app/utils/pencocok_resep.dart';

import 'helpers/aplikasi_uji.dart';
import 'helpers/katalog_contoh.dart';
import 'helpers/palsu.dart';

/// Kulkas pintar: umur bahan, "segera habiskan" (manual + otomatis), dan
/// peringkat resep penyelamat. Persentase kecocokan tidak boleh berubah.
void main() {
  final hari0 = DateTime(2026, 11, 16, 20, 30);
  DateTime hari(int n, [int jam = 8]) => DateTime(2026, 11, 16 + n, jam);

  const bayam = Bahan(
    id: 'bayam',
    nama: 'Bayam',
    kategori: KategoriBahan.sayur,
    emoji: '🍃',
    awetHari: 2,
  );
  const telur = Bahan(
    id: 'telur',
    nama: 'Telur',
    kategori: KategoriBahan.protein,
    emoji: '🥚',
    awetHari: 21,
  );
  const garam = Bahan(
    id: 'garam',
    nama: 'Garam',
    kategori: KategoriBahan.bumbu,
    emoji: '🧂',
    bumbuDasar: true,
  );
  final byId = {
    for (final b in [bayam, telur, garam]) b.id: b,
  };

  group('umur & sisa hari', () {
    test('umur dihitung per hari kalender, bukan per 24 jam', () {
      expect(umurHari(hari0, hari0), 0);
      // Ditempel 20.30, dilihat besok pagi 08.00 = 1 hari.
      expect(umurHari(hari0, hari(1)), 1);
      expect(umurHari(hari0, hari(3, 23)), 3);
    });

    test('jam mundur (tanggal tempel di masa depan) tidak negatif', () {
      expect(umurHari(hari(2), hari0), 0);
    });

    test('lintas bulan & tahun', () {
      expect(umurHari(DateTime(2026, 12, 30), DateTime(2027, 1, 2)), 3);
    });

    test('sisa hari = awetHari − umur; null bila awet/tanpa tanggal', () {
      expect(sisaHari(bayam, hari0, hari0), 2);
      expect(sisaHari(bayam, hari0, hari(1)), 1);
      expect(sisaHari(bayam, hari0, hari(5)), -3);
      expect(sisaHari(garam, hari0, hari(100)), isNull);
      expect(sisaHari(bayam, null, hari0), isNull);
    });
  });

  group('hitungBahanSegera', () {
    Set<String> segera(
      DateTime sekarang, {
      Set<String> kulkas = const {'bayam', 'telur', 'garam'},
      Set<String> ditandai = const {},
    }) => hitungBahanSegera(
      kulkas: kulkas,
      ditandai: ditandai,
      sejak: {for (final id in kulkas) id: hari0},
      bahanById: byId,
      sekarang: sekarang,
    );

    test('baru ditempel: belum ada yang segera', () {
      expect(segera(hari0), isEmpty);
    });

    test('otomatis saat sisa ≤ 1 hari, dan tetap setelah lewat', () {
      expect(segera(hari(1)), {'bayam'});
      expect(segera(hari(6)), {'bayam'});
      // Telur (21 hari) baru menyusul di hari ke-20.
      expect(segera(hari(19)), {'bayam'});
      expect(segera(hari(20)), {'bayam', 'telur'});
    });

    test('bahan awet tidak pernah otomatis, tetapi bisa ditandai manual', () {
      expect(segera(hari(365)), isNot(contains('garam')));
      expect(segera(hari0, ditandai: {'garam'}), {'garam'});
    });

    test('tanda untuk bahan yang tidak ada di kulkas diabaikan', () {
      expect(segera(hari0, kulkas: {'telur'}, ditandai: {'bayam'}), isEmpty);
    });

    test('bahan tak dikenal katalog & tanpa tanggal tidak membuat crash', () {
      expect(
        hitungBahanSegera(
          kulkas: {'bayam', 'hantu'},
          ditandai: {},
          sejak: {},
          bahanById: byId,
          sekarang: hari(9),
        ),
        isEmpty,
      );
    });
  });

  group('teks kesegaran', () {
    test('sejakKapan', () {
      expect(sejakKapan(0), 'hari ini');
      expect(sejakKapan(1), 'kemarin');
      expect(sejakKapan(4), '4 hari lalu');
    });

    test('keterangan mengikuti sisa hari', () {
      String ket(Bahan b, DateTime kini, {bool ditandai = false}) =>
          keteranganKesegaran(b, hari0, kini, ditandai: ditandai);
      expect(
        ket(bayam, hari0),
        'Ditempel hari ini · kira-kira masih segar 2 hari lagi',
      );
      expect(
        ket(bayam, hari(1)),
        'Ditempel kemarin · sebaiknya dipakai paling lambat besok',
      );
      expect(
        ket(bayam, hari(2)),
        'Ditempel 2 hari lalu · sebaiknya dipakai hari ini',
      );
      expect(
        ket(bayam, hari(5)),
        'Ditempel 5 hari lalu · sudah lewat 3 hari dari perkiraan segar',
      );
      expect(ket(garam, hari(5)), 'Ditempel 5 hari lalu · bahan awet');
      expect(
        ket(garam, hari0, ditandai: true),
        'Ditempel hari ini · kamu tandai segera habiskan',
      );
    });

    test('label "Pakai … yang segera habis"', () {
      expect(labelPakaiSegera([]), '');
      expect(labelPakaiSegera(['Bayam']), 'Pakai bayam yang segera habis');
      expect(
        labelPakaiSegera(['Bayam', 'Tahu']),
        'Pakai bayam & tahu yang segera habis',
      );
      expect(
        labelPakaiSegera(['Bayam', 'Tahu', 'Tauge']),
        'Pakai 3 bahan yang segera habis',
      );
    });
  });

  group('peringkat resep penyelamat', () {
    final katalog = katalogKecil();

    test('persentase & daftar kurang TIDAK berubah oleh bahan segera', () {
      for (final segera in [
        <String>{},
        {'telur'},
        {'telur', 'kecap', 'tomat'},
      ]) {
        final hasil = cocokkanSemua(
          katalog,
          {'telur', 'kecap', 'tomat'},
          bumbuDasarAda: true,
          segera: segera,
        );
        final peta = {
          for (final h in hasil)
            h.resep.id: '${h.persen}% kurang ${h.kurang.join(',')}',
        };
        expect(peta['dadar'], '100% kurang ');
        expect(peta['telur-kecap'], '100% kurang ');
        expect(peta['orek'], '67% kurang tempe');
        expect(peta['campur'], '75% kurang tempe');
      }
    });

    test('resep yang memakai bahan segera naik ke atas dan diberi daftar', () {
      // Tanpa segera: telur-kecap, dadar (100%), campur (75%), orek (67%).
      final biasa = cocokkanSemua(katalog, {
        'telur',
        'kecap',
        'tomat',
      }, bumbuDasarAda: true);
      expect(biasa.map((h) => h.resep.id), [
        'telur-kecap',
        'dadar',
        'campur',
        'orek',
      ]);
      expect(biasa.every((h) => h.segera.isEmpty), isTrue);

      // Tomat segera habis: dipakai 'campur' (wajib) dan 'dadar' (opsional).
      final hasil = cocokkanSemua(
        katalog,
        {'telur', 'kecap', 'tomat'},
        bumbuDasarAda: true,
        segera: {'tomat'},
      );
      expect(hasil.map((h) => h.resep.id), [
        'dadar', // 100%, pakai tomat
        'campur', // 75%, pakai tomat
        'telur-kecap', // 100%, tidak memakai tomat
        'orek',
      ]);
      expect(hasil[0].segera, ['tomat']);
      expect(hasil[0].pakaiSegera, isTrue);
      expect(hasil[2].segera, isEmpty);
    });

    test('kurang > 2 bahan tidak dinaikkan walau memakai bahan segera', () {
      final hasil = cocokkanSemua(
        katalog,
        {'tomat'},
        bumbuDasarAda: false,
        segera: {'tomat'},
      );
      final campur = hasil.firstWhere((h) => h.resep.id == 'campur');
      expect(campur.kurang.length, 3);
      expect(campur.segera, ['tomat']);
      expect(diprioritaskan(campur), isFalse);
      // 'dadar' (tomat opsional) juga kurang 3 → urutan murni persen.
      expect(hasil.first.resep.id, 'campur');
    });

    test('bahan segera yang tidak ada di kulkas tidak dihitung', () {
      final h = cocokkanResep(
        katalog.resepById('campur')!,
        {'telur'},
        katalog.bahanById,
        bumbuDasarAda: false,
        segera: {'tomat', 'telur'},
      );
      expect(h.segera, ['telur']);
    });

    test('memakai lebih banyak bahan segera menang saat persen sama', () {
      final hasil = cocokkanSemua(
        katalog,
        {'telur', 'kecap', 'tomat'},
        bumbuDasarAda: true,
        segera: {'telur', 'kecap', 'tomat'},
      );
      // dadar: telur+tomat (2), telur-kecap: telur+kecap (2) → waktu;
      // keduanya 100% di atas campur (75%, 3 bahan segera).
      expect(hasil.map((h) => h.resep.id).take(2), ['telur-kecap', 'dadar']);
      expect(hasil[2].resep.id, 'campur');
    });
  });

  group('KulkasController', () {
    late StorageMemori storage;
    late DateTime kini;

    Future<KulkasController> siapkan({
      Set<String> kulkas = const {},
      Map<String, String> sejak = const {},
      Set<String> segera = const {},
    }) async {
      siapkanDependensi(
        ambil: () async => HasilAmbil(
          katalog: Katalog(
            versi: 2,
            bahan: [bayam, telur, garam],
            resep: [
              resep('telur-bayam', [pakai('telur'), pakai('bayam')]),
              resep('telur-asin', [pakai('telur'), pakai('garam')]),
            ],
          ),
          sumber: SumberData.bawaan,
        ),
        kulkas: kulkas,
        sejak: sejak,
        segera: segera,
        jam: () => kini,
      );
      storage = Get.find<StorageService>() as StorageMemori;
      await Future<void>.delayed(Duration.zero);
      return Get.find<KulkasController>();
    }

    setUp(() => kini = hari0);
    tearDown(Get.reset);

    test(
      'menempel mencatat tanggal; melepas membuang tanggal & tanda',
      () async {
        final c = await siapkan();
        c.toggle('bayam');
        expect(c.bahanDimiliki, {'bayam'});
        expect(c.sejak['bayam'], hari0);
        c.toggleSegera('bayam');
        expect(c.ditandaiSegera, {'bayam'});

        c.toggle('bayam');
        expect(c.bahanDimiliki, isEmpty);
        expect(c.sejak, isEmpty);
        expect(c.ditandaiSegera, isEmpty);
        await Future<void>.delayed(Duration.zero);
        expect(storage.set[StorageService.kunciKulkas], isEmpty);
        expect(storage.set[StorageService.kunciSegera], isEmpty);
        expect(storage.bacaPetaTeks(StorageService.kunciSejak), isEmpty);
      },
    );

    test('tersimpan dan dimuat kembali', () async {
      final c = await siapkan(
        kulkas: {'bayam', 'telur'},
        sejak: {'bayam': hari(-1).toIso8601String(), 'telur': 'rusak'},
        segera: {'telur', 'sudah-dilepas'},
      );
      expect(c.sejak['bayam'], hari(-1));
      expect(c.sejak['telur'], hari0, reason: 'tanggal rusak → sekarang');
      expect(c.ditandaiSegera, {'telur'});
      // bayam: ditempel kemarin, awet 2 → sisa 1 → otomatis segera.
      expect(c.bahanSegera, {'bayam', 'telur'});
      expect(c.daftarSegera.map((b) => b.nama), ['Bayam', 'Telur']);
    });

    test('bahan menjadi segera seiring hari berjalan', () async {
      final c = await siapkan();
      c.tempel('bayam');
      expect(c.bahanSegera, isEmpty);
      kini = hari(1);
      expect(c.bahanSegera, {'bayam'});
      expect(c.semuaHasil.first.resep.id, 'telur-bayam');
      expect(c.semuaHasil.first.segera, ['bayam']);
    });

    test('"masih segar" menghitung ulang dari hari ini', () async {
      final c = await siapkan(
        kulkas: {'bayam'},
        sejak: {'bayam': hari(-3).toIso8601String()},
        segera: {'bayam'},
      );
      expect(c.bahanSegera, {'bayam'});
      c.tandaiSegar('bayam');
      expect(c.ditandaiSegera, isEmpty);
      expect(c.sejak['bayam'], hari0);
      expect(c.bahanSegera, isEmpty);
    });

    test('tanda segera hanya untuk bahan yang ada di kulkas', () async {
      final c = await siapkan();
      c.toggleSegera('bayam');
      c.tandaiSegar('bayam');
      expect(c.ditandaiSegera, isEmpty);
      expect(c.sejak, isEmpty);
    });

    test('tempelBanyak tidak menggeser tanggal bahan yang sudah ada', () async {
      final c = await siapkan(
        kulkas: {'telur'},
        sejak: {'telur': hari(-4).toIso8601String()},
      );
      final baru = c.tempelBanyak(['telur', 'bayam', 'bayam']);
      expect(baru, {'bayam'});
      expect(c.sejak['telur'], hari(-4));
      expect(c.sejak['bayam'], hari0);
    });

    test('lepasBanyak (pengurangan stok) hanya melepas yang ada', () async {
      final c = await siapkan(kulkas: {'telur', 'bayam'}, segera: {'bayam'});
      final lepas = c.lepasBanyak(['bayam', 'garam']);
      expect(lepas, {'bayam'});
      expect(c.bahanDimiliki, {'telur'});
      expect(c.sejak.keys, ['telur']);
      expect(c.ditandaiSegera, isEmpty);
      expect(c.lepasBanyak(['tidak-ada']), isEmpty);
    });

    test('kosongkan membersihkan kulkas, tanggal, dan tanda', () async {
      final c = await siapkan(kulkas: {'telur', 'bayam'}, segera: {'bayam'});
      c.kosongkan();
      expect(c.bahanDimiliki, isEmpty);
      expect(c.sejak, isEmpty);
      expect(c.ditandaiSegera, isEmpty);
      expect(c.jumlahResepCocok, 0);
    });
  });
}
