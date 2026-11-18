import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/models/bahan_model.dart';
import '../data/models/resep_model.dart';
import '../data/services/katalog_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_warna_makanan.dart';
import 'pena_makanan.dart';
import 'sampul_khusus.dart';

export 'pena_makanan.dart' show BentukMakanan, Komponen, PeranMakanan;
export 'sampul_khusus.dart'
    show GayaSampul, TataUtama, WadahSampul, petaSampulResep;

typedef _W = WarnaMakanan;

/// Nada warna sampul, ditentukan dari bahan resep.
enum NadaSampul { hijau, merah, cokelat, kuning, krem, emas }

/// Nada sampul sebuah resep: kecap → cokelat, santan → krem, cabai+tomat
/// atau saus tomat → merah, sayur daun → hijau, jagung/pisang/telur utama →
/// kuning, selain itu emas (gorengan/tumisan).
NadaSampul nadaSampul(Resep resep) {
  final wajib = {for (final b in resep.bahanWajib) b.bahanId};
  bool ada(Iterable<String> ids) => ids.any(wajib.contains);
  if (ada(const ['santan'])) return NadaSampul.krem;
  if (ada(const ['saus-tomat']) ||
      (ada(const ['cabai']) && ada(const ['tomat']))) {
    return NadaSampul.merah;
  }
  if (ada(const ['kecap-manis', 'gula-merah', 'meses'])) {
    return NadaSampul.cokelat;
  }
  if (ada(const [
    'bayam',
    'kangkung',
    'sawi-hijau',
    'brokoli',
    'buncis',
    'labu-siam',
    'timun',
  ])) {
    return NadaSampul.hijau;
  }
  if (ada(const ['jagung', 'pisang', 'telur', 'keju'])) {
    return NadaSampul.kuning;
  }
  return NadaSampul.emas;
}

// ---------------------------------------------------------------------------
// Komponen makanan
// ---------------------------------------------------------------------------

// Telur digambar menurut cara masaknya (lihat [_varianTelur]).
const _telurCeplok = Komponen(
  'telur-ceplok',
  BentukMakanan.telurCeplok,
  _W.telurPutih,
  _W.telurKuning,
  jumlah: 2,
  skala: 1.05,
);
const _telurDadar = Komponen(
  'telur-dadar',
  BentukMakanan.telurDadar,
  _W.dadar,
  _W.dadarTua,
  tunggal: true,
);
const _telurRebus = Komponen(
  'telur-rebus',
  BentukMakanan.telurRebus,
  _W.telurPutih,
  _W.telurKuning,
  jumlah: 4,
  skala: 0.95,
);
const _telurOrakArik = Komponen(
  'telur-orak-arik',
  BentukMakanan.orakArik,
  _W.dadar,
  _W.dadarTua,
  jumlah: 3,
);

/// SATU tempat pemetaan bahanId → komponen sampul. Bahan yang tidak ada di
/// sini memakai bentuk generik berwarna kategorinya ([komponenUntuk]).
const petaKomponen = <String, Komponen>{
  // Protein
  'telur': _telurCeplok,
  'tempe': Komponen('tempe', BentukMakanan.tempe, _W.tempe, _W.tempeTua),
  'tahu': Komponen(
    'tahu',
    BentukMakanan.kubus,
    _W.tahu,
    _W.tahuTua,
    jumlah: 5,
    skala: 0.9,
  ),
  'ayam': Komponen(
    'ayam',
    BentukMakanan.ayam,
    _W.ayam,
    _W.ayamTua,
    jumlah: 3,
    skala: 1.1,
  ),
  'ikan-teri': Komponen(
    'teri',
    BentukMakanan.kapsul,
    _W.teri,
    _W.teriTua,
    jumlah: 6,
    skala: 0.6,
    rasio: 0.3,
  ),
  'sosis': Komponen('sosis', BentukMakanan.sosis, _W.sosis, _W.sosisTua),
  'kornet': Komponen(
    'kornet',
    BentukMakanan.remah,
    _W.kornet,
    _W.kornetTua,
    jumlah: 4,
    skala: 0.9,
  ),
  'udang': Komponen('udang', BentukMakanan.udang, _W.udang, _W.udangTua),
  'keju': Komponen(
    'keju',
    BentukMakanan.remah,
    _W.keju,
    _W.kejuTua,
    jumlah: 4,
    skala: 0.8,
  ),
  'kacang-tanah': Komponen(
    'kacang',
    BentukMakanan.kapsul,
    _W.kacang,
    _W.kacangTua,
    jumlah: 6,
    skala: 0.5,
    rasio: 0.65,
  ),

  // Sayur
  'kangkung': Komponen(
    'kangkung',
    BentukMakanan.daun,
    _W.daunTua,
    _W.daunGelap,
    jumlah: 5,
    skala: 1.15,
    rasio: 0.42,
  ),
  'bayam': Komponen(
    'bayam',
    BentukMakanan.daun,
    _W.daun,
    _W.daunTua,
    jumlah: 5,
    rasio: 0.7,
  ),
  'sawi-hijau': Komponen(
    'sawi',
    BentukMakanan.daun,
    _W.daunMuda,
    _W.daunTua,
    jumlah: 4,
    skala: 1.1,
    rasio: 0.55,
  ),
  'wortel': Komponen(
    'wortel',
    BentukMakanan.irisan,
    _W.wortelDalam,
    _W.wortel,
    jumlah: 5,
    skala: 0.8,
  ),
  'kentang': Komponen(
    'kentang',
    BentukMakanan.kubus,
    _W.kentang,
    _W.kentangTua,
    jumlah: 5,
    skala: 0.9,
  ),
  'kol': Komponen(
    'kol',
    BentukMakanan.daun,
    _W.daunPucat,
    _W.daunPucatTua,
    jumlah: 4,
    skala: 1.05,
    rasio: 0.85,
  ),
  'tauge': Komponen(
    'tauge',
    BentukMakanan.tauge,
    _W.tauge,
    _W.jagung,
    jumlah: 6,
    skala: 0.8,
  ),
  'buncis': Komponen(
    'buncis',
    BentukMakanan.kapsul,
    _W.daun,
    _W.daunTua,
    jumlah: 5,
    rasio: 0.24,
  ),
  'jagung': Komponen(
    'jagung',
    BentukMakanan.jagung,
    _W.jagung,
    _W.jagungTua,
    jumlah: 5,
    skala: 0.85,
  ),
  'tomat': Komponen(
    'tomat',
    BentukMakanan.irisan,
    _W.tomatDalam,
    _W.tomat,
    jumlah: 4,
    skala: 0.85,
  ),
  'daun-bawang': Komponen.hiasan(
    'daun-bawang',
    BentukMakanan.cincin,
    _W.daun,
    _W.daunTua,
    jumlah: 5,
  ),
  'seledri': Komponen.hiasan(
    'seledri',
    BentukMakanan.daun,
    _W.daunTua,
    _W.daunGelap,
    jumlah: 3,
    rasio: 0.8,
  ),
  'brokoli': Komponen(
    'brokoli',
    BentukMakanan.brokoli,
    _W.daunTua,
    _W.daunGelap,
  ),
  'labu-siam': Komponen(
    'labu-siam',
    BentukMakanan.kubus,
    _W.labu,
    _W.labuTua,
    jumlah: 5,
    skala: 0.85,
  ),
  'terong': Komponen(
    'terong',
    BentukMakanan.kapsul,
    _W.terong,
    _W.terongTua,
    rasio: 0.45,
  ),
  'timun': Komponen(
    'timun',
    BentukMakanan.irisan,
    _W.timun,
    _W.timunKulit,
    jumlah: 5,
    skala: 0.8,
  ),
  'jamur': Komponen('jamur', BentukMakanan.jamur, _W.jamur, _W.jamurTua),

  // Karbohidrat
  'nasi': Komponen(
    'nasi',
    BentukMakanan.nasi,
    _W.nasi,
    _W.nasiTua,
    tunggal: true,
  ),
  'mie-instan': Komponen(
    'mie',
    BentukMakanan.mie,
    _W.mie,
    _W.mieTua,
    tunggal: true,
  ),
  'bihun': Komponen(
    'bihun',
    BentukMakanan.mie,
    _W.bihun,
    _W.bihunTua,
    tunggal: true,
  ),
  'roti-tawar': Komponen(
    'roti',
    BentukMakanan.roti,
    _W.roti,
    _W.rotiKulit,
    tunggal: true,
  ),
  'tepung-terigu': Komponen.tanpa('tepung'),
  'pisang': Komponen(
    'pisang',
    BentukMakanan.kapsul,
    _W.pisang,
    _W.pisangTua,
    jumlah: 3,
    rasio: 0.36,
  ),
  'ubi': Komponen(
    'ubi',
    BentukMakanan.irisan,
    _W.ubi,
    _W.ubiKulit,
    skala: 0.95,
  ),

  // Bumbu
  'garam': Komponen.tanpa('garam'),
  'gula': Komponen.tanpa('gula'),
  'minyak-goreng': Komponen.tanpa('minyak'),
  'air': Komponen.tanpa('air'),
  'merica': Komponen.tanpa('merica'),
  'kaldu-bubuk': Komponen.tanpa('kaldu'),
  'santan': Komponen.tanpa('santan'),
  'bawang-merah': Komponen.hiasan(
    'bawang-merah',
    BentukMakanan.remah,
    _W.bawangMerah,
    _W.bawangMerahTua,
    jumlah: 3,
  ),
  'bawang-putih': Komponen.hiasan(
    'bawang-putih',
    BentukMakanan.remah,
    _W.bawangPutih,
    _W.bawangPutihTua,
    jumlah: 3,
  ),
  'cabai': Komponen.hiasan(
    'cabai',
    BentukMakanan.cabai,
    _W.cabai,
    _W.daunTua,
    jumlah: 3,
    skala: 1.5,
  ),
  'kecap-manis': Komponen.siraman('kecap', _W.kecap),
  'saus-tomat': Komponen.siraman('saus-tomat', _W.sausTomat),
  'saus-tiram': Komponen.siraman('saus-tiram', _W.sausTiram),
  'gula-merah': Komponen.siraman('gula-merah', _W.gulaMerah),
  'susu-kental-manis': Komponen.siraman('susu', _W.susu),
  'margarin': Komponen.hiasan(
    'margarin',
    BentukMakanan.kubus,
    _W.margarin,
    _W.margarinTua,
    jumlah: 1,
    skala: 1.3,
  ),
  'daun-salam': Komponen.hiasan(
    'daun-salam',
    BentukMakanan.daun,
    _W.daunGelap,
    _W.daunTua,
    jumlah: 1,
    skala: 1.8,
    rasio: 0.45,
  ),
  'jeruk-nipis': Komponen.hiasan(
    'jeruk-nipis',
    BentukMakanan.irisan,
    _W.jeruk,
    _W.jerukKulit,
    jumlah: 1,
    skala: 1.7,
  ),
  'meses': Komponen.hiasan(
    'meses',
    BentukMakanan.remah,
    _W.meses,
    _W.kecap,
    jumlah: 5,
  ),
};

/// Komponen sampul untuk sebuah bahan. Bahan tanpa komponen khusus jatuh ke
/// bentuk generik berwarna kategorinya; bumbu tak dikenal tidak digambar.
Komponen komponenUntuk(String bahanId, [Bahan? bahan]) {
  final khusus = petaKomponen[bahanId];
  if (khusus != null) return khusus;
  if (bahan == null) {
    return Komponen(bahanId, BentukMakanan.generik, _W.generik, _W.generikTua);
  }
  if (bahan.bumbuDasar || bahan.kategori == KategoriBahan.bumbu) {
    return Komponen.tanpa(bahanId);
  }
  final warna = AppColors.magnet(bahan.kategori);
  return Komponen(
    bahanId,
    BentukMakanan.generik,
    warna,
    Color.lerp(warna, AppColors.tinta, 0.3)!,
  );
}

/// Telur digambar menurut cara masaknya di resep: direbus (takaran menyebut
/// "rebus"), diorak-arik (gumpalan), dikocok/didadar, atau diceplok.
/// "orak-arik" dicek lebih dulu karena telur orak-arik juga dikocok.
Komponen _varianTelur(Resep resep, BahanResep telur) {
  if (telur.takaran.toLowerCase().contains('rebus')) return _telurRebus;
  final langkah = resep.langkah.join(' ').toLowerCase();
  if (langkah.contains('orak-arik')) return _telurOrakArik;
  final dikocok = RegExp(r'kocok|dadar').hasMatch(langkah);
  return dikocok ? _telurDadar : _telurCeplok;
}

// ---------------------------------------------------------------------------
// Rancangan & tata letak
// ---------------------------------------------------------------------------

/// Apa saja yang digambar di sampul satu resep (hasil [susunSampul]).
@immutable
class RancanganSampul {
  final WadahSampul wadah;
  final NadaSampul nada;

  /// Komponen utama (bahan non-bumbu pertama); null untuk sambal.
  final Komponen? utama;

  /// Warna pengganti komponen utama (mis. nasi goreng kecokelatan).
  final Color? warnaUtama;

  /// Utama dibalut tepung goreng.
  final bool balut;
  final List<Komponen> pendamping;
  final List<Komponen> hiasan;

  /// Warna siraman di atas makanan (kecap, saus, susu); null = tidak ada.
  final Color? siraman;

  /// Siraman berupa garis tipis, bukan aliran tebal.
  final bool siramanTipis;

  /// Warna genangan saus di bawah tumisan; null = tidak ada.
  final Color? genangan;

  /// Saus kental yang menyelimuti sebagian besar makanan; null = tidak ada.
  final Color? selimut;
  final Color kuah;
  final int benih;

  /// Pelengkap saji di tepi wadah (kerupuk, irisan timun, cabai rawit).
  final List<Komponen> pelengkap;

  /// Taburan halus di atas makanan utama (bawang goreng, keju, meses).
  final List<Komponen> taburan;

  /// Cara potongan utama yang banyak ditata.
  final TataUtama tata;

  const RancanganSampul({
    required this.wadah,
    required this.nada,
    required this.utama,
    required this.pendamping,
    required this.hiasan,
    required this.kuah,
    required this.benih,
    this.warnaUtama,
    this.balut = false,
    this.siraman,
    this.siramanTipis = false,
    this.genangan,
    this.selimut,
    this.pelengkap = const [],
    this.taburan = const [],
    this.tata = TataUtama.cincin,
  });

  /// Ringkasan komposisi (tanpa benih tata letak): dua resep dengan tanda
  /// sama akan tampak mirip. Ikut mencerminkan penimpaan [GayaSampul].
  String get tanda {
    String warna(Color? w) => w?.toARGB32().toRadixString(16) ?? '-';
    String daftar(List<Komponen> ks) =>
        ks.map((k) => '${k.nama}:${k.bentuk.name}').join('+');
    return [
      wadah.name,
      nada.name,
      '${utama?.nama}:${utama?.bentuk.name}${balut ? '+balut' : ''}',
      tata.name,
      daftar(pendamping),
      daftar(hiasan),
      daftar(pelengkap),
      daftar(taburan),
      warna(warnaUtama),
      '${warna(siraman)}${siramanTipis ? '-tipis' : ''}',
      warna(genangan),
      warna(selimut),
      warna(kuah),
    ].join('|');
  }
}

(Color, Color) _warnaNada(NadaSampul nada) => switch (nada) {
  NadaSampul.hijau => (AppColors.sajianHijau, AppColors.sajianHijauTua),
  NadaSampul.merah => (AppColors.sajianMerah, AppColors.sajianMerahTua),
  NadaSampul.cokelat => (AppColors.sajianCokelat, AppColors.sajianCokelatTua),
  NadaSampul.kuning => (AppColors.sajianKuning, AppColors.sajianKuningTua),
  NadaSampul.krem => (AppColors.sajianKrem, AppColors.sajianKremTua),
  NadaSampul.emas => (AppColors.sajianEmas, AppColors.sajianEmasTua),
};

Color _latarNada(NadaSampul nada) => switch (nada) {
  NadaSampul.hijau => AppColors.sampulHijau,
  NadaSampul.merah => AppColors.sampulMerah,
  NadaSampul.cokelat => AppColors.sampulCokelat,
  NadaSampul.kuning => AppColors.sampulKuning,
  NadaSampul.krem => AppColors.sampulKrem,
  NadaSampul.emas => AppColors.sampulEmas,
};

/// Menyusun sampul dari bahan resep:
/// - utama = bahan isi wajib pertama, digambar besar/banyak;
/// - pendamping = sampai 2 bahan isi berikutnya (wajib dulu, lalu opsional);
/// - hiasan = sampai 2 bumbu yang punya bentuk (cabai, bawang, …);
/// - siraman/genangan dari kecap dan saus;
/// - wadah dari [Resep.sajian].
RancanganSampul susunSampul(Resep resep, [Map<String, Bahan> byId = const {}]) {
  final nada = nadaSampul(resep);
  final urut = [...resep.bahanWajib, ...resep.bahan.where((b) => b.opsional)];
  final isi = <Komponen>[];
  final hiasan = <Komponen>[];
  Color? saus;
  for (final b in urut) {
    final k = b.bahanId == 'telur'
        ? _varianTelur(resep, b)
        : komponenUntuk(b.bahanId, byId[b.bahanId]);
    switch (k.peran) {
      case PeranMakanan.isi:
        if (isi.every((e) => e.nama != k.nama)) isi.add(k);
      case PeranMakanan.hiasan:
        if (hiasan.every((e) => e.nama != k.nama)) hiasan.add(k);
      case PeranMakanan.siraman:
        if (!b.opsional) saus ??= k.warna;
      case PeranMakanan.tanpa:
        break;
    }
  }

  final sajian = resep.sajian;
  final balut =
      sajian == JenisSajian.goreng &&
      resep.bahanWajib.any((b) => b.bahanId == 'tepung-terigu');
  // Di gorengan tepung, telur hanyalah pelapis adonan: tidak digambar.
  if (balut) isi.removeWhere((k) => k.nama.startsWith('telur-'));
  // Mie/nasi GORENG tidak berkuah dan bumbunya menyatu (bukan disiram).
  final digoreng = resep.id.contains('goreng');
  final wadah = switch (sajian) {
    JenisSajian.kuah => WadahSampul.mangkuk,
    JenisSajian.mie => digoreng ? WadahSampul.piring : WadahSampul.mangkuk,
    JenisSajian.sambal => WadahSampul.cobek,
    JenisSajian.manis => WadahSampul.daunPisang,
    _ => WadahSampul.piring,
  };
  final sambal = wadah == WadahSampul.cobek;
  final berkuah = wadah == WadahSampul.mangkuk;
  // Bubur: nasinya sudah menjadi "kuah" putih, jadi lauknya yang utama.
  final bubur =
      berkuah && isi.isNotEmpty && isi.first.bentuk == BentukMakanan.nasi;
  if (bubur && isi.length > 1) isi.removeAt(0);
  final utama = sambal || isi.isEmpty ? null : isi.first;
  final pendamping = (sambal ? isi : isi.skip(1)).take(2).toList();

  final (warnaNada, _) = _warnaNada(nada);
  final pekat = nada == NadaSampul.cokelat || nada == NadaSampul.merah;
  final karbo =
      utama?.bentuk == BentukMakanan.nasi || utama?.bentuk == BentukMakanan.mie;
  final menyatu = karbo && digoreng;
  // Nasi/mie/bihun GORENG selalu kecokelatan (bercampur kecap/bumbu),
  // walau nada resepnya bukan cokelat atau merah.
  final warnaUtama = menyatu
      ? Color.lerp(
          utama!.warna,
          pekat ? warnaNada : AppColors.sajianCokelat,
          0.38,
        )
      : null;
  // Mie/bihun goreng memperlihatkan helainya (bukan gulungan mie rebus).
  final utamaAkhir = menyatu && utama!.bentuk == BentukMakanan.mie
      ? Komponen(
          utama.nama,
          BentukMakanan.mieGoreng,
          utama.warna,
          utama.warnaTua,
          tunggal: utama.tunggal,
          rasio: utama.nama == 'bihun' ? 0.3 : 0.6,
        )
      : utama;

  final tumis = sajian == JenisSajian.tumis;
  final kuah = bubur
      ? _W.nasi
      : switch (nada) {
          NadaSampul.krem => _W.kuahSantan,
          NadaSampul.cokelat => _W.kuahKecap,
          NadaSampul.merah => _W.kuahMerah,
          NadaSampul.hijau => _W.kuahHijau,
          _ => _W.kuahBening,
        };

  final bawaan = RancanganSampul(
    wadah: wadah,
    nada: nada,
    utama: utamaAkhir,
    warnaUtama: warnaUtama,
    balut: balut,
    pendamping: pendamping,
    hiasan: hiasan.take(2).toList(),
    siraman: saus != null && !tumis && !berkuah && !sambal && !menyatu
        ? saus
        : null,
    genangan: tumis ? (saus ?? (pekat ? warnaNada : null)) : null,
    kuah: kuah,
    benih: resep.id.codeUnits.fold<int>(7, (a, b) => (a * 31 + b) & 0x3fffffff),
  );
  final gaya = petaSampulResep[resep.id];
  return gaya == null ? bawaan : _terapkan(bawaan, gaya);
}

/// Hasil bawaan [susunSampul] yang ditimpa [GayaSampul] khusus resep.
RancanganSampul _terapkan(RancanganSampul r, GayaSampul g) => RancanganSampul(
  wadah: g.wadah ?? r.wadah,
  nada: r.nada,
  utama: g.tanpaUtama ? null : (g.utama ?? r.utama),
  warnaUtama: GayaSampul.pilih(
    g.warnaUtama,
    // Warna pengganti bawaan hanya untuk utama bawaan.
    g.utama == null ? r.warnaUtama : null,
  ),
  balut: g.balut ?? r.balut,
  pendamping: g.pendamping ?? r.pendamping,
  hiasan: g.hiasan ?? r.hiasan,
  pelengkap: g.pelengkap ?? r.pelengkap,
  taburan: g.taburan ?? r.taburan,
  tata: g.tata ?? r.tata,
  siraman: GayaSampul.pilih(g.siraman, r.siraman),
  siramanTipis: g.siramanTipis ?? r.siramanTipis,
  genangan: GayaSampul.pilih(g.genangan, r.genangan),
  selimut: GayaSampul.pilih(g.selimut, r.selimut),
  kuah: g.kuah ?? r.kuah,
  benih: r.benih,
);

/// Satu potongan makanan yang sudah ditempatkan. Koordinat memakai satuan
/// jari-jari wadah (pusat wadah = 0,0; tepi wadah = 1).
@immutable
class Potongan {
  final Komponen komponen;
  final Offset pos;
  final double r;
  final double putar;

  /// 0 = utama, 1 = pendamping, 2 = hiasan, 3 = pelengkap di tepi wadah.
  final int lapis;

  const Potongan(this.komponen, this.pos, this.r, this.putar, this.lapis);
}

/// Jari-jari area makanan di dalam tiap wadah (satuan jari-jari wadah).
double batasIsi(WadahSampul wadah) => switch (wadah) {
  WadahSampul.piring => 0.72,
  WadahSampul.mangkuk => 0.7,
  WadahSampul.cobek => 0.52,
  WadahSampul.daunPisang => 0.68,
  WadahSampul.cup => 0.7,
  WadahSampul.mangkukKecil => 0.46,
};

/// Pelengkap saji berderet di tepi area makanan, mulai dari sudut acak
/// (benih tersendiri agar tata letak resep tanpa pelengkap tidak berubah).
List<Potongan> _tataPelengkap(RancanganSampul r, double batas) {
  if (r.pelengkap.isEmpty) return const [];
  final acak = Random(r.benih ^ 0x2545F491);
  var sudut = acak.nextDouble() * 2 * pi;
  final hasil = <Potongan>[];
  for (final k in r.pelengkap) {
    final rad = 0.17 * k.skala;
    final jarak = batas - rad;
    final langkah = 2 * asin(min(1.0, rad / jarak)) * 0.92;
    for (var i = 0; i < k.jumlah; i++) {
      hasil.add(
        Potongan(
          k,
          Offset.fromDirection(sudut, jarak),
          rad,
          sudut + pi / 2 + (acak.nextDouble() - 0.5) * 0.6,
          3,
        ),
      );
      sudut += langkah;
    }
  }
  return hasil;
}

/// Potongan utama [TataUtama.tumpuk], [TataUtama.jajar], atau
/// [TataUtama.kipas]. Semua potongan tetap di dalam [batas].
List<Potongan> _tataUtamaKhusus(
  Komponen k,
  TataUtama tata,
  double batas,
  Random acak,
) {
  final n = k.jumlah;
  final hasil = <Potongan>[];
  switch (tata) {
    case TataUtama.cincin:
      break;
    case TataUtama.tumpuk:
      // Sebaran spiral emas: rapat merata, saling menumpang sebagian.
      final rad = min(0.2 * k.skala, batas * 0.5);
      final jangkau = batas - rad;
      final awal = acak.nextDouble() * 2 * pi;
      for (var i = 0; i < n; i++) {
        var pos =
            Offset.fromDirection(
              awal + i * 2.39996,
              jangkau * sqrt((i + 0.5) / n),
            ) +
            Offset(acak.nextDouble() - 0.5, acak.nextDouble() - 0.5) *
                rad *
                0.3;
        if (pos.distance > jangkau) pos = pos / pos.distance * jangkau;
        hasil.add(Potongan(k, pos, rad, acak.nextDouble() * 2 * pi, 0));
      }
    case TataUtama.jajar:
    case TataUtama.kipas:
      final arah = -0.5 + (acak.nextDouble() - 0.5) * 0.5;
      final normal = Offset(-sin(arah), cos(arah));
      List<(Offset, double)> letak(double rad) => [
        for (var i = 0; i < n; i++)
          if (tata == TataUtama.jajar)
            (normal * ((i - (n - 1) / 2) * rad * 2 * k.rasio * 1.08), arah)
          else
            () {
              final sudut = arah + (i - (n - 1) / 2) * 0.42;
              return (
                Offset.fromDirection(arah + pi, batas * 0.42) +
                    Offset.fromDirection(sudut, rad * 0.98),
                sudut,
              );
            }(),
      ];
      var rad = 0.6 * k.skala;
      while (letak(rad).any((p) => p.$1.distance + rad > batas)) {
        rad *= 0.97;
      }
      for (final (pos, sudut) in letak(rad)) {
        hasil.add(
          Potongan(k, pos, rad, sudut + (acak.nextDouble() - 0.5) * 0.12, 0),
        );
      }
  }
  return hasil;
}

/// Menata potongan secara deterministik dari [RancanganSampul.benih].
///
/// - Utama tunggal: satu besar di tengah, komponen lain di atasnya.
/// - Utama banyak: disusun melingkar (potongan ke-5 dst. di tengah) dengan
///   ukuran yang dijamin muat, sehingga jumlahnya selalu utuh.
/// - Pendamping & hiasan: dicoba di beberapa posisi acak; diterima bila
///   seluruhnya di dalam area makanan dan cukup jauh dari potongan lain
///   (potongan selapis dijaga lebih renggang; terhadap lapis lain boleh
///   menumpang sebagian, seperti lauk di atas nasi). Bila sempit, jarak
///   minimum dilonggarkan bertahap; yang tetap tidak muat dilewati.
List<Potongan> tataSampul(RancanganSampul r) {
  final acak = Random(r.benih);
  final batas = batasIsi(r.wadah);
  final hasil = <Potongan>[];
  // Pelengkap ditempatkan lebih dulu agar potongan lain menghindarinya,
  // tetapi disisipkan ke daftar setelah pendamping (urutan gambar).
  final pelengkap = _tataPelengkap(r, batas);

  void sebar(Komponen k, int n, double rad, double batasIni, int lapis) {
    final jangkau = batasIni - rad;
    if (jangkau <= 0) return;
    for (var i = 0; i < n; i++) {
      Potongan? p;
      for (final longgar in const [0.96, 0.8, 0.64]) {
        for (var coba = 0; coba < 28 && p == null; coba++) {
          final sudut = acak.nextDouble() * 2 * pi;
          final jarak = jangkau * sqrt(acak.nextDouble());
          final pos = Offset(cos(sudut) * jarak, sin(sudut) * jarak);
          final putar = acak.nextDouble() * 2 * pi;
          if ([...hasil, ...pelengkap].every(
            (q) =>
                (q.komponen.tunggal && q.lapis == 0) ||
                (q.pos - pos).distance >=
                    (q.r + rad) * (q.lapis == lapis ? longgar : longgar * 0.55),
          )) {
            p = Potongan(k, pos, rad, putar, lapis);
          }
        }
        if (p != null) break;
      }
      if (p != null) hasil.add(p);
    }
  }

  final utama = r.utama;
  final tunggal = utama?.tunggal ?? false;
  var batasAtas = batas;
  if (utama != null && tunggal) {
    var rad = min(0.62 * utama.skala, batas - 0.06);
    var pos = Offset(
      (acak.nextDouble() - 0.5) * 0.06,
      (acak.nextDouble() - 0.5) * 0.06,
    );
    if (pelengkap.isNotEmpty) {
      // Beri ruang untuk pelengkap: geser menjauh dan sedikit mengecil.
      final arah = pelengkap.fold(Offset.zero, (a, p) => a + p.pos);
      if (arah.distance > 0) pos -= arah / arah.distance * 0.08;
      rad -= 0.06;
    }
    hasil.add(Potongan(utama, pos, rad, acak.nextDouble() * 2 * pi, 0));
    batasAtas = rad * 0.86;
  } else if (utama != null && r.tata != TataUtama.cincin) {
    hasil.addAll(_tataUtamaKhusus(utama, r.tata, batas, acak));
  } else if (utama != null) {
    final n = utama.jumlah;
    final diCincin = n >= 5 ? n - 1 : n;
    var rad =
        (n <= 2 ? 0.36 : (n == 3 ? 0.3 : (n == 4 ? 0.27 : 0.235))) *
        utama.skala;
    if (diCincin >= 2) {
      // Tali busur antar tetangga harus ≥ 2 × rad × 0,84.
      final sinus = sin(pi / diCincin);
      rad = min(rad, batas * sinus / (0.84 + sinus));
    }
    final cincin = diCincin == 1 ? 0.0 : batas - rad;
    final awal = acak.nextDouble() * 2 * pi;
    for (var i = 0; i < n; i++) {
      final diTengah = i >= diCincin;
      final sudut =
          awal + i * 2 * pi / diCincin + (acak.nextDouble() - 0.5) * 0.3;
      final jarak = diTengah ? 0.0 : cincin * (0.9 + acak.nextDouble() * 0.1);
      hasil.add(
        Potongan(
          utama,
          Offset(cos(sudut) * jarak, sin(sudut) * jarak),
          rad,
          acak.nextDouble() * 2 * pi,
          0,
        ),
      );
    }
  }
  for (var i = 0; i < r.pendamping.length; i++) {
    final k = r.pendamping[i];
    final dasar = utama == null ? 0.2 : (i == 0 ? 0.19 : 0.16);
    sebar(
      k,
      i == 0 ? min(3, k.jumlah) : 2,
      dasar * k.skala * (tunggal ? 0.9 : 1),
      batasAtas,
      1,
    );
  }
  final sebelumHiasan = hasil.length;
  for (final k in r.hiasan) {
    sebar(k, k.jumlah, 0.1 * k.skala, batasAtas, 2);
  }
  return pelengkap.isEmpty
      ? hasil
      : [
          ...hasil.take(sebelumHiasan),
          ...pelengkap,
          ...hasil.skip(sebelumHiasan),
        ];
}

// ---------------------------------------------------------------------------
// Widget & pelukis
// ---------------------------------------------------------------------------

/// Sampul resep yang digambar dengan kode (bukan foto). Sajian dilihat
/// tegak lurus dari atas di dalam wadahnya; isinya disusun dari bahan wajib
/// resep (lihat [susunSampul]) sehingga tiap resep punya wajah sendiri.
/// Warnanya sama di tema terang dan gelap (ilustrasi).
///
/// Di bawah [ambangDetail] (ukuran kartu) bintik, kilau, dan hiasan
/// terkecil disembunyikan agar tetap bersih; halaman detail menampilkan
/// semuanya.
class SampulResep extends StatelessWidget {
  final Resep resep;
  final double ukuran;
  final double radius;

  const SampulResep({
    super.key,
    required this.resep,
    this.ukuran = AppSpacing.sampul,
    this.radius = AppSpacing.radiusM,
  });

  /// Sisi ubin (dp) mulai detail halus ditampilkan.
  static const ambangDetail = 96.0;

  @override
  Widget build(BuildContext context) {
    final byId =
        Get.find<KatalogService>().katalog.value?.bahanById ?? const {};
    return ExcludeSemantics(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: SizedBox.square(
          dimension: ukuran,
          child: CustomPaint(painter: SampulPainter(susunSampul(resep, byId))),
        ),
      ),
    );
  }
}

class SampulPainter extends CustomPainter {
  final RancanganSampul rancangan;

  /// Memaksa detail halus tampil/sembunyi; null = menurut ukuran kanvas
  /// (lihat [SampulResep.ambangDetail]).
  final bool? detailPaksa;

  const SampulPainter(this.rancangan, {this.detailPaksa});

  static const _tinta = AppColors.tinta;

  /// Wadah mengisi ± 73% sisi ubin.
  static const porsiWadah = 0.73;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final detail = detailPaksa ?? s >= SampulResep.ambangDetail;
    final r = rancangan;
    final jari = s * porsiWadah / 2;
    final pusat = Offset(size.width / 2, size.height / 2);
    final tg = max(1.0, s * 0.016);
    final pena = PenaMakanan(canvas, tg, detail);

    canvas
      ..drawRect(Offset.zero & size, Paint()..color = _latarNada(r.nada))
      // Bayangan lembut bergeser ke kanan bawah.
      ..drawCircle(
        pusat + Offset(jari * 0.07, jari * 0.1),
        jari,
        Paint()..color = AppColors.bayangan,
      )
      ..save()
      ..translate(pusat.dx, pusat.dy);

    _wadah(canvas, pena, jari);

    // Makanan tidak pernah keluar dari wadah.
    final klip = switch (r.wadah) {
      WadahSampul.mangkukKecil => jari * _mangkukKecilDalam,
      WadahSampul.cup => jari * _cupDalam,
      _ => jari - tg,
    };
    canvas
      ..save()
      ..clipPath(
        Path()..addOval(Rect.fromCircle(center: Offset.zero, radius: klip)),
      );
    final (warnaNada, warnaNadaTua) = _warnaNada(r.nada);
    if (r.wadah == WadahSampul.cobek) {
      pena.gumpal(
        Offset.zero,
        jari * 0.6,
        warnaNada,
        r.benih,
        tepi: warnaNadaTua,
      );
    }
    if (r.genangan != null) {
      pena.gumpal(
        Offset.zero,
        jari * 0.66,
        Color.lerp(r.genangan, _W.piring, 0.25)!,
        r.benih,
      );
    }
    final potongan = tataSampul(r);
    void lukis(bool hiasan) {
      for (var i = 0; i < potongan.length; i++) {
        final p = potongan[i];
        if ((p.lapis == 2) != hiasan) continue;
        // Hiasan terkecil dan taburan halus disembunyikan di ukuran kartu.
        if (!detail && p.lapis == 2 && p.r < 0.11 && i.isOdd) continue;
        if (!detail && p.komponen.hanyaDetail) continue;
        canvas
          ..save()
          ..translate(p.pos.dx * jari, p.pos.dy * jari)
          ..rotate(p.putar);
        final k = p.komponen;
        final balut = r.balut && p.lapis == 0;
        pena.gambar(
          balut ? BentukMakanan.gorengan : k.bentuk,
          k,
          p.r * jari,
          Random(r.benih + i * 97),
          warna: p.lapis == 0 ? r.warnaUtama : null,
        );
        canvas.restore();
      }
    }

    // Makanan dulu, lalu saus kental yang menyelimutinya, lalu hiasan.
    lukis(false);
    if (r.selimut != null) _selimut(pena, jari, r);
    lukis(true);
    if (r.siraman != null) _siraman(canvas, jari, r);
    // Taburan halus di atas makanan utama (atau seluruh area makanan).
    if (r.taburan.isNotEmpty) {
      final dasar = potongan
          .where((p) => p.lapis == 0 && p.komponen.tunggal)
          .firstOrNull;
      final o = (dasar?.pos ?? Offset.zero) * jari;
      final rad = (dasar?.r ?? batasIsi(r.wadah)) * 0.8 * jari;
      for (var j = 0; j < r.taburan.length; j++) {
        final k = r.taburan[j];
        if (!detail && k.hanyaDetail) continue;
        canvas
          ..save()
          ..translate(o.dx, o.dy);
        pena.gambar(k.bentuk, k, rad, Random(r.benih + 991 * (j + 1)));
        canvas.restore();
      }
    }
    canvas.restore();

    // Garis tepi wadah di atas isi.
    canvas.drawCircle(Offset.zero, jari, pena.garis(_tinta, tg * 1.5));
    if (r.wadah == WadahSampul.cobek) _ulekan(canvas, pena, jari);
    canvas.restore();
  }

  /// Jari-jari bagian dalam mangkuk kecil dan cup (satuan jari-jari wadah).
  static const _mangkukKecilDalam = 0.5;
  static const _cupDalam = 0.82;

  /// Saus kental berombak yang menutupi sebagian besar makanan.
  void _selimut(PenaMakanan pena, double jari, RancanganSampul r) {
    final rad = jari * batasIsi(r.wadah) * 0.72;
    final o = Offset.fromDirection(r.benih * 0.7, jari * 0.05);
    pena.gumpal(o, rad, r.selimut!, r.benih + 5, tepi: _tinta);
    if (pena.detail) {
      pena.c.drawArc(
        Rect.fromCircle(center: o, radius: rad * 0.55),
        pi * 1.15,
        pi * 0.35,
        false,
        pena.garis(Color.lerp(r.selimut, _W.piring, 0.45)!, pena.tg),
      );
    }
  }

  void _wadah(Canvas canvas, PenaMakanan pena, double jari) {
    final r = rancangan;
    Paint isi(Color c) => Paint()..color = c;
    switch (r.wadah) {
      case WadahSampul.cup:
        // Gelas plastik tampak atas: cincin bibir tebal, isi di dalamnya.
        canvas
          ..drawCircle(Offset.zero, jari, isi(_W.cup))
          ..drawCircle(
            Offset.zero,
            jari * 0.91,
            pena.garis(_W.cupBibir, jari * 0.1),
          )
          ..drawCircle(Offset.zero, jari * _cupDalam, isi(r.kuah))
          ..drawCircle(
            Offset.zero,
            jari * _cupDalam,
            pena.garis(_tinta, pena.tg * 0.8),
          );
      case WadahSampul.mangkukKecil:
        // Piring dengan mangkuk kecil berisi saus di tengahnya.
        canvas
          ..drawCircle(Offset.zero, jari, isi(_W.piring))
          ..drawCircle(
            Offset.zero,
            jari * 0.8,
            pena.garis(_W.piringBibir, pena.tg),
          )
          ..drawCircle(Offset.zero, jari * 0.64, isi(_W.piring))
          ..drawCircle(Offset.zero, jari * 0.64, pena.garis(_tinta, pena.tg))
          ..drawCircle(Offset.zero, jari * _mangkukKecilDalam, isi(r.kuah))
          ..drawCircle(
            Offset.zero,
            jari * _mangkukKecilDalam,
            pena.garis(_tinta, pena.tg * 0.8),
          );
      case WadahSampul.piring:
        canvas
          ..drawCircle(Offset.zero, jari, isi(_W.piring))
          ..drawCircle(
            Offset.zero,
            jari * 0.8,
            pena.garis(_W.piringBibir, pena.tg),
          );
      case WadahSampul.mangkuk:
        canvas
          ..drawCircle(Offset.zero, jari, isi(_W.piring))
          ..drawCircle(Offset.zero, jari * 0.85, isi(r.kuah))
          ..drawCircle(
            Offset.zero,
            jari * 0.85,
            pena.garis(_tinta, pena.tg * 0.8),
          );
        if (pena.detail) {
          canvas.drawArc(
            Rect.fromCircle(center: Offset.zero, radius: jari * 0.74),
            pi * 1.1,
            pi * 0.35,
            false,
            pena.garis(_W.piring.withValues(alpha: 0.7), pena.tg),
          );
        }
      case WadahSampul.cobek:
        canvas
          ..drawCircle(Offset.zero, jari, isi(_W.batu))
          ..drawCircle(Offset.zero, jari * 0.8, isi(_W.batuDalam));
        if (pena.detail) {
          final acak = Random(r.benih);
          for (var i = 0; i < 10; i++) {
            final sudut = acak.nextDouble() * 2 * pi;
            canvas.drawCircle(
              Offset(cos(sudut), sin(sudut)) * jari * 0.9,
              jari * 0.018,
              isi(_W.batuDalam),
            );
          }
        }
      case WadahSampul.daunPisang:
        canvas
          ..drawCircle(Offset.zero, jari, isi(_W.piring))
          ..save()
          ..clipPath(
            Path()..addOval(
              Rect.fromCircle(center: Offset.zero, radius: jari * 0.9),
            ),
          )
          ..rotate((r.benih % 7 - 3) * 0.12);
        final daun = RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: jari * 1.9,
            height: jari * 1.25,
          ),
          Radius.circular(jari * 0.3),
        );
        canvas
          ..drawRRect(daun, isi(_W.daunPisang))
          ..drawLine(
            Offset(-jari, 0),
            Offset(jari, 0),
            pena.garis(_W.daunPisangTua, pena.tg),
          );
        if (pena.detail) {
          for (var i = -4; i <= 4; i++) {
            final x = i * jari * 0.2;
            canvas
              ..drawLine(
                Offset(x, 0),
                Offset(x + jari * 0.12, -jari * 0.62),
                pena.garis(_W.daunPisangTua, pena.tg * 0.5),
              )
              ..drawLine(
                Offset(x, 0),
                Offset(x + jari * 0.12, jari * 0.62),
                pena.garis(_W.daunPisangTua, pena.tg * 0.5),
              );
          }
        }
        canvas
          ..drawRRect(daun, pena.garis(_tinta, pena.tg * 0.8))
          ..restore();
    }
  }

  /// Siraman berkelok di atas makanan.
  void _siraman(Canvas canvas, double jari, RancanganSampul r) {
    final sudut = (r.benih % 12) * pi / 6;
    final tipis = r.siramanTipis;
    final lebar = jari * (tipis ? 0.46 : 0.52);
    final ayun = tipis ? 0.6 : 1.0;
    final jalur = Path()..moveTo(-lebar, -jari * 0.12 * ayun);
    for (var i = 1; i <= 5; i++) {
      final x = -lebar + 2 * lebar * i / 5;
      jalur.quadraticBezierTo(
        x - lebar / 5,
        (i.isOdd ? 1 : -1) * jari * 0.32 * ayun,
        x,
        (i.isOdd ? 1 : -1) * jari * 0.1 * ayun,
      );
    }
    canvas
      ..save()
      ..rotate(sudut)
      ..drawPath(
        jalur,
        Paint()
          ..color = r.siraman!
          ..style = PaintingStyle.stroke
          ..strokeWidth = jari * (tipis ? 0.04 : 0.085)
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      )
      ..restore();
  }

  void _ulekan(Canvas canvas, PenaMakanan pena, double jari) {
    final a = Offset(jari * 0.18, -jari * 0.12);
    final b = Offset(jari * 0.98, -jari * 0.92);
    canvas
      ..drawLine(a, b, pena.garis(_tinta, jari * 0.3 + pena.tg * 2))
      ..drawLine(a, b, pena.garis(_W.ulekan, jari * 0.3));
    if (pena.detail) {
      canvas.drawLine(
        Offset.lerp(a, b, 0.2)! + Offset(-jari * 0.05, -jari * 0.05),
        Offset.lerp(a, b, 0.8)! + Offset(-jari * 0.05, -jari * 0.05),
        pena.garis(_W.piring.withValues(alpha: 0.5), pena.tg),
      );
    }
  }

  @override
  bool shouldRepaint(SampulPainter lama) =>
      lama.detailPaksa != detailPaksa ||
      lama.rancangan.benih != rancangan.benih ||
      lama.rancangan.tanda != rancangan.tanda;
}
