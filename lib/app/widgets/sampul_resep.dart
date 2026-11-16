import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/models/bahan_model.dart';
import '../data/models/resep_model.dart';
import '../data/services/katalog_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_warna_makanan.dart';

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

/// Bentuk dasar yang bisa digambar pelukis sampul.
enum BentukMakanan {
  telurCeplok,
  telurDadar,
  telurRebus,
  tempe,
  kubus,
  ayam,
  sosis,
  udang,
  mie,
  nasi,
  daun,
  brokoli,
  irisan,
  jagung,
  cabai,
  cincin,
  gorengan,
  roti,
  kapsul,
  remah,
  tauge,
  jamur,
  generik,
}

/// Peran sebuah bahan di sampul.
enum PeranMakanan {
  /// Makanan utama/pendamping (protein, sayur, karbohidrat).
  isi,

  /// Taburan kecil dari bumbu (cabai, bawang, daun bawang).
  hiasan,

  /// Cairan yang disiramkan (kecap, saus).
  siraman,

  /// Tidak digambar (garam, air, minyak, tepung, …).
  tanpa,
}

/// Cara satu bahan digambar di sampul.
@immutable
class Komponen {
  final String nama;
  final BentukMakanan bentuk;
  final Color warna;
  final Color warnaTua;
  final PeranMakanan peran;

  /// Jumlah potongan saat menjadi komponen utama.
  final int jumlah;

  /// Pengali ukuran potongan.
  final double skala;

  /// Tebal relatif (bentuk lonjong) atau lebar relatif (daun).
  final double rasio;

  /// Digambar satu kali besar di tengah (nasi, mie, telur dadar, roti);
  /// komponen lain ditata di atasnya.
  final bool tunggal;

  const Komponen(
    this.nama,
    this.bentuk,
    this.warna,
    this.warnaTua, {
    this.peran = PeranMakanan.isi,
    this.jumlah = 4,
    this.skala = 1,
    this.rasio = 0.5,
    this.tunggal = false,
  });

  const Komponen.hiasan(
    this.nama,
    this.bentuk,
    this.warna,
    this.warnaTua, {
    this.jumlah = 4,
    this.skala = 1,
    this.rasio = 0.5,
  }) : peran = PeranMakanan.hiasan,
       tunggal = false;

  const Komponen.siraman(this.nama, this.warna)
    : bentuk = BentukMakanan.generik,
      warnaTua = warna,
      peran = PeranMakanan.siraman,
      jumlah = 0,
      skala = 1,
      rasio = 0.5,
      tunggal = false;

  const Komponen.tanpa(this.nama)
    : bentuk = BentukMakanan.generik,
      warna = _W.generik,
      warnaTua = _W.generikTua,
      peran = PeranMakanan.tanpa,
      jumlah = 0,
      skala = 1,
      rasio = 0.5,
      tunggal = false;
}

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
/// "rebus"), dikocok/diorak-arik (dadar), atau diceplok.
Komponen _varianTelur(Resep resep, BahanResep telur) {
  if (telur.takaran.toLowerCase().contains('rebus')) return _telurRebus;
  final langkah = resep.langkah.join(' ').toLowerCase();
  final dikocok = RegExp(r'kocok|orak-arik|dadar').hasMatch(langkah);
  return dikocok ? _telurDadar : _telurCeplok;
}

// ---------------------------------------------------------------------------
// Rancangan & tata letak
// ---------------------------------------------------------------------------

enum WadahSampul { piring, mangkuk, cobek, daunPisang }

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

  /// Warna genangan saus di bawah tumisan; null = tidak ada.
  final Color? genangan;
  final Color kuah;
  final int benih;

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
    this.genangan,
  });

  /// Ringkasan komposisi (tanpa benih tata letak): dua resep dengan tanda
  /// sama akan tampak mirip.
  String get tanda => [
    wadah.name,
    nada.name,
    '${utama?.nama}${balut ? '+balut' : ''}',
    pendamping.map((k) => k.nama).join('+'),
    hiasan.map((k) => k.nama).join('+'),
    siraman?.toARGB32().toRadixString(16) ?? '-',
    genangan?.toARGB32().toRadixString(16) ?? '-',
  ].join('|');
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
  final warnaUtama = menyatu && pekat
      ? Color.lerp(utama!.warna, warnaNada, 0.38)
      : null;

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

  return RancanganSampul(
    wadah: wadah,
    nada: nada,
    utama: utama,
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
}

/// Satu potongan makanan yang sudah ditempatkan. Koordinat memakai satuan
/// jari-jari wadah (pusat wadah = 0,0; tepi wadah = 1).
@immutable
class Potongan {
  final Komponen komponen;
  final Offset pos;
  final double r;
  final double putar;

  /// 0 = utama, 1 = pendamping, 2 = hiasan.
  final int lapis;

  const Potongan(this.komponen, this.pos, this.r, this.putar, this.lapis);
}

/// Jari-jari area makanan di dalam tiap wadah (satuan jari-jari wadah).
double batasIsi(WadahSampul wadah) => switch (wadah) {
  WadahSampul.piring => 0.72,
  WadahSampul.mangkuk => 0.7,
  WadahSampul.cobek => 0.52,
  WadahSampul.daunPisang => 0.68,
};

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
          if (hasil.every(
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
    final rad = min(0.62 * utama.skala, batas - 0.06);
    hasil.add(
      Potongan(
        utama,
        Offset(
          (acak.nextDouble() - 0.5) * 0.06,
          (acak.nextDouble() - 0.5) * 0.06,
        ),
        rad,
        acak.nextDouble() * 2 * pi,
        0,
      ),
    );
    batasAtas = rad * 0.86;
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
  for (final k in r.hiasan) {
    sebar(k, k.jumlah, 0.1 * k.skala, batasAtas, 2);
  }
  return hasil;
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
    final pena = _Pena(canvas, tg, detail);

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
    canvas
      ..save()
      ..clipPath(
        Path()
          ..addOval(Rect.fromCircle(center: Offset.zero, radius: jari - tg)),
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
    for (var i = 0; i < potongan.length; i++) {
      final p = potongan[i];
      // Hiasan terkecil disembunyikan di ukuran kartu.
      if (!detail && p.lapis == 2 && p.r < 0.11 && i.isOdd) continue;
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
    if (r.siraman != null) _siraman(canvas, jari, r);
    canvas.restore();

    // Garis tepi wadah di atas isi.
    canvas.drawCircle(Offset.zero, jari, pena.garis(_tinta, tg * 1.5));
    if (r.wadah == WadahSampul.cobek) _ulekan(canvas, pena, jari);
    canvas.restore();
  }

  void _wadah(Canvas canvas, _Pena pena, double jari) {
    final r = rancangan;
    Paint isi(Color c) => Paint()..color = c;
    switch (r.wadah) {
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
    final lebar = jari * 0.52;
    final jalur = Path()..moveTo(-lebar, -jari * 0.12);
    for (var i = 1; i <= 5; i++) {
      final x = -lebar + 2 * lebar * i / 5;
      jalur.quadraticBezierTo(
        x - lebar / 5,
        (i.isOdd ? 1 : -1) * jari * 0.32,
        x,
        (i.isOdd ? 1 : -1) * jari * 0.1,
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
          ..strokeWidth = jari * 0.085
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      )
      ..restore();
  }

  void _ulekan(Canvas canvas, _Pena pena, double jari) {
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

/// Pustaka komponen makanan: tiap bentuk digambar di titik asal dengan
/// jari-jari [r] (kanvas sudah digeser dan diputar pemanggil).
class _Pena {
  _Pena(this.c, this.tg, this.detail);

  final Canvas c;

  /// Tebal garis tepi.
  final double tg;

  /// Tampilkan bintik, kilau, dan urat halus.
  final bool detail;

  static const _tinta = AppColors.tinta;

  Paint isi(Color w) => Paint()..color = w;

  Paint garis(Color w, double tebal) => Paint()
    ..color = w
    ..style = PaintingStyle.stroke
    ..strokeWidth = tebal
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  void _kontur(Path jalur, Color warna) => c
    ..drawPath(jalur, isi(warna))
    ..drawPath(jalur, garis(_tinta, tg));

  /// Gabungan beberapa lingkaran dengan satu garis tepi luar.
  void _gabung(List<(Offset, double)> bulatan, Color warna, {Color? tepi}) {
    for (final (o, rad) in bulatan) {
      c.drawCircle(o, rad + tg, isi(tepi ?? _tinta));
    }
    for (final (o, rad) in bulatan) {
      c.drawCircle(o, rad, isi(warna));
    }
  }

  /// Gumpalan berombak (sambal, genangan saus, gundukan nasi).
  void gumpal(Offset o, double r, Color warna, int benih, {Color? tepi}) {
    final acak = Random(benih);
    final bulatan = <(Offset, double)>[
      (o, r * 0.78),
      for (var i = 0; i < 9; i++)
        (
          o +
              Offset(cos(i * 2 * pi / 9), sin(i * 2 * pi / 9)) *
                  r *
                  (0.62 + acak.nextDouble() * 0.1),
          r * (0.26 + acak.nextDouble() * 0.1),
        ),
    ];
    if (tepi == null) {
      for (final (p, rad) in bulatan) {
        c.drawCircle(p, rad, isi(warna));
      }
    } else {
      _gabung(bulatan, warna, tepi: tepi);
    }
  }

  void gambar(
    BentukMakanan bentuk,
    Komponen k,
    double r,
    Random acak, {
    Color? warna,
  }) {
    final w = warna ?? k.warna;
    switch (bentuk) {
      case BentukMakanan.telurCeplok:
        _gabung([
          (Offset.zero, r * 0.8),
          (Offset(r * 0.4, r * 0.24), r * 0.52),
          (Offset(-r * 0.32, -r * 0.38), r * 0.46),
          (Offset(-r * 0.22, r * 0.44), r * 0.4),
        ], w);
        final kuning = Offset(-r * 0.04, -r * 0.02);
        c
          ..drawCircle(kuning, r * 0.36, isi(_W.telurKuning))
          ..drawCircle(kuning, r * 0.36, garis(_W.telurKuningTua, tg * 0.8));
        if (detail) {
          c.drawArc(
            Rect.fromCircle(center: kuning, radius: r * 0.22),
            pi * 1.1,
            pi * 0.4,
            false,
            garis(_W.telurPutih, tg * 0.8),
          );
        }
      case BentukMakanan.telurDadar:
        final dadar = Rect.fromCenter(
          center: Offset.zero,
          width: r * 2,
          height: r * 1.72,
        );
        _kontur(Path()..addOval(dadar), w);
        c.drawOval(dadar.deflate(r * 0.13), garis(k.warnaTua, tg));
        if (detail) {
          for (var i = 0; i < 5; i++) {
            final sudut = acak.nextDouble() * 2 * pi;
            c.drawCircle(
              Offset(cos(sudut), sin(sudut) * 0.85) *
                  r *
                  (0.2 + acak.nextDouble() * 0.45),
              r * 0.05,
              isi(k.warnaTua.withValues(alpha: 0.7)),
            );
          }
        }
      case BentukMakanan.telurRebus:
        _kontur(
          Path()..addOval(
            Rect.fromCenter(center: Offset.zero, width: r * 1.5, height: r * 2),
          ),
          w,
        );
        c
          ..drawCircle(Offset(0, r * 0.12), r * 0.42, isi(_W.telurKuning))
          ..drawCircle(
            Offset(0, r * 0.12),
            r * 0.42,
            garis(_W.telurKuningTua, tg * 0.8),
          );
      case BentukMakanan.tempe:
        _kontur(
          Path()..addRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(
                center: Offset.zero,
                width: r * 2,
                height: r * 1.26,
              ),
              Radius.circular(r * 0.2),
            ),
          ),
          w,
        );
        // Kedelai: bintik besar selalu ada, bintik halus hanya saat detail.
        const bintik = [
          (-0.55, -0.2),
          (0.1, 0.22),
          (0.6, -0.12),
          (-0.15, -0.3),
          (-0.6, 0.3),
          (0.45, 0.32),
          (0.25, -0.34),
        ];
        final n = detail ? bintik.length : 3;
        for (var i = 0; i < n; i++) {
          c.drawCircle(
            Offset(r * bintik[i].$1, r * bintik[i].$2),
            r * (i < 3 ? 0.13 : 0.08),
            isi(_W.tempeBintik),
          );
        }
      case BentukMakanan.kubus:
        final luar = RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: r * 1.6, height: r * 1.6),
          Radius.circular(r * 0.26),
        );
        _kontur(Path()..addRRect(luar), k.warnaTua);
        c.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset(-r * 0.1, -r * 0.1),
              width: r * 1.12,
              height: r * 1.12,
            ),
            Radius.circular(r * 0.18),
          ),
          isi(w),
        );
      case BentukMakanan.ayam:
        // Paha: tulang dulu, daging menutup pangkalnya.
        final a = Offset(r * 0.3, 0), b = Offset(r * 0.78, 0);
        c
          ..drawLine(a, b, garis(_tinta, r * 0.3 + tg * 2))
          ..drawCircle(b, r * 0.2 + tg, isi(_tinta))
          ..drawLine(a, b, garis(_W.tulang, r * 0.3))
          ..drawCircle(b, r * 0.2, isi(_W.tulang));
        _kontur(
          Path()..addOval(
            Rect.fromCenter(
              center: Offset(-r * 0.22, 0),
              width: r * 1.5,
              height: r * 1.2,
            ),
          ),
          w,
        );
        if (detail) {
          c
            ..drawArc(
              Rect.fromCenter(
                center: Offset(-r * 0.22, 0),
                width: r * 1.0,
                height: r * 0.75,
              ),
              pi * 0.15,
              pi * 0.5,
              false,
              garis(k.warnaTua, tg * 0.8),
            )
            ..drawCircle(Offset(-r * 0.5, -r * 0.2), r * 0.06, isi(k.warnaTua));
        }
      case BentukMakanan.sosis:
        final badan = RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: r * 2, height: r * 0.84),
          Radius.circular(r * 0.42),
        );
        _kontur(Path()..addRRect(badan), w);
        if (detail) {
          for (final x in [-0.4, 0.0, 0.4]) {
            c.drawLine(
              Offset(r * (x - 0.1), -r * 0.22),
              Offset(r * (x + 0.1), r * 0.22),
              garis(k.warnaTua, tg * 0.8),
            );
          }
        }
      case BentukMakanan.udang:
        final busur = Rect.fromCircle(center: Offset.zero, radius: r * 0.56);
        const awal = 0.5, sapu = 4.3;
        final ujung = Offset(cos(awal + sapu), sin(awal + sapu)) * r * 0.56;
        final arah = awal + sapu + pi / 2;
        final ekor = Path()
          ..moveTo(ujung.dx, ujung.dy)
          ..lineTo(
            ujung.dx + cos(arah - 0.6) * r * 0.5,
            ujung.dy + sin(arah - 0.6) * r * 0.5,
          )
          ..lineTo(
            ujung.dx + cos(arah + 0.6) * r * 0.5,
            ujung.dy + sin(arah + 0.6) * r * 0.5,
          )
          ..close();
        _kontur(ekor, k.warnaTua);
        c
          ..drawArc(busur, awal, sapu, false, garis(_tinta, r * 0.5 + tg * 2))
          ..drawArc(busur, awal, sapu, false, garis(w, r * 0.5));
        if (detail) {
          for (var i = 1; i <= 3; i++) {
            final sudut = awal + sapu * i / 4;
            c.drawLine(
              Offset(cos(sudut), sin(sudut)) * r * 0.36,
              Offset(cos(sudut), sin(sudut)) * r * 0.76,
              garis(k.warnaTua, tg * 0.8),
            );
          }
        }
      case BentukMakanan.mie:
        _kontur(
          Path()..addOval(Rect.fromCircle(center: Offset.zero, radius: r)),
          k.warnaTua,
        );
        // Gulungan: busur-busur bergeser mengelilingi pusat.
        for (var i = 0; i < 5; i++) {
          final sudut = i * 1.9 + acak.nextDouble();
          final helai = Rect.fromCircle(
            center: Offset(cos(sudut), sin(sudut)) * r * 0.14,
            radius: r * (0.78 - i * 0.15),
          );
          final sapu = 3.6 + acak.nextDouble();
          c
            ..drawArc(
              helai,
              sudut,
              sapu,
              false,
              garis(Color.lerp(k.warnaTua, _tinta, 0.45)!, r * 0.14 + tg),
            )
            ..drawArc(helai, sudut, sapu, false, garis(w, r * 0.14));
        }
      case BentukMakanan.nasi:
        final bulatan = <(Offset, double)>[
          (Offset.zero, r * 0.8),
          for (var i = 0; i < 10; i++)
            (
              Offset(cos(i * pi / 5), sin(i * pi / 5)) * r * 0.7,
              r * (0.26 + acak.nextDouble() * 0.06),
            ),
        ];
        _gabung(bulatan, w);
        if (detail) {
          final butir = garis(Color.lerp(w, k.warnaTua, 0.8)!, tg * 0.8);
          for (var i = 0; i < 14; i++) {
            final sudut = acak.nextDouble() * 2 * pi;
            final o =
                Offset(cos(sudut), sin(sudut)) * r * acak.nextDouble() * 0.7;
            final arah = acak.nextDouble() * pi;
            c.drawLine(o, o + Offset(cos(arah), sin(arah)) * r * 0.1, butir);
          }
        }
      case BentukMakanan.daun:
        final lebar = r * k.rasio * 1.5;
        final daun = Path()
          ..moveTo(-r, 0)
          ..quadraticBezierTo(-r * 0.1, -lebar, r, 0)
          ..quadraticBezierTo(-r * 0.1, lebar, -r, 0)
          ..close();
        _kontur(daun, w);
        c.drawLine(
          Offset(-r * 0.8, 0),
          Offset(r * 0.75, 0),
          garis(k.warnaTua, tg * 0.9),
        );
        if (detail) {
          for (final x in [-0.35, 0.0, 0.35]) {
            for (final arah in [-1, 1]) {
              c.drawLine(
                Offset(r * x, 0),
                Offset(r * (x + 0.18), arah * lebar * 0.32),
                garis(k.warnaTua, tg * 0.6),
              );
            }
          }
        }
      case BentukMakanan.brokoli:
        final batang = RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(0, r * 0.62),
            width: r * 0.42,
            height: r * 0.7,
          ),
          Radius.circular(r * 0.12),
        );
        _kontur(Path()..addRRect(batang), _W.daunMuda);
        _gabung([
          (Offset(-r * 0.4, -r * 0.05), r * 0.46),
          (Offset(r * 0.38, -r * 0.1), r * 0.48),
          (Offset(0, -r * 0.42), r * 0.48),
          (Offset(0, r * 0.08), r * 0.42),
        ], w);
        if (detail) {
          for (final (x, y) in [
            (-0.4, -0.1),
            (0.3, -0.2),
            (0.0, -0.5),
            (0.1, 0.1),
          ]) {
            c.drawCircle(Offset(r * x, r * y), r * 0.08, isi(k.warnaTua));
          }
        }
      case BentukMakanan.irisan:
        _kontur(
          Path()..addOval(Rect.fromCircle(center: Offset.zero, radius: r)),
          k.warnaTua,
        );
        c.drawCircle(Offset.zero, r * 0.7, isi(w));
        if (detail) {
          for (var i = 0; i < 3; i++) {
            final sudut = i * pi / 3;
            c.drawLine(
              Offset(cos(sudut), sin(sudut)) * r * 0.5,
              Offset(cos(sudut), sin(sudut)) * -r * 0.5,
              garis(k.warnaTua.withValues(alpha: 0.55), tg * 0.6),
            );
          }
        }
      case BentukMakanan.jagung:
        for (final y in [-0.3, 0.3]) {
          for (final x in [-0.62, 0.0, 0.62]) {
            final butir = RRect.fromRectAndRadius(
              Rect.fromCenter(
                center: Offset(r * x, r * y),
                width: r * 0.58,
                height: r * 0.54,
              ),
              Radius.circular(r * 0.18),
            );
            c
              ..drawRRect(butir, isi(w))
              ..drawRRect(butir, garis(_tinta, tg * 0.75));
          }
        }
        if (detail) {
          for (final x in [-0.7, -0.08, 0.54]) {
            c.drawCircle(
              Offset(r * x, -r * 0.38),
              r * 0.06,
              isi(_W.telurPutih),
            );
          }
        }
      case BentukMakanan.cabai:
        final badan = Path()
          ..moveTo(-r * 0.75, r * 0.05)
          ..quadraticBezierTo(0, -r * 0.55, r * 0.9, r * 0.1);
        c
          ..drawLine(
            Offset(-r * 0.75, r * 0.05),
            Offset(-r, -r * 0.14),
            garis(k.warnaTua, r * 0.2),
          )
          ..drawPath(badan, garis(_tinta, r * 0.4 + tg * 1.6))
          ..drawPath(badan, garis(w, r * 0.4));
      case BentukMakanan.cincin:
        c
          ..drawCircle(Offset.zero, r * 0.66, garis(k.warnaTua, r * 0.5))
          ..drawCircle(Offset.zero, r * 0.66, garis(w, r * 0.3));
      case BentukMakanan.gorengan:
        // Balutan tepung keemasan; warna bahan aslinya mengintip.
        final tebal = max(k.rasio, 0.62).clamp(0.62, 0.92);
        final balut = RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: r * 2,
            height: r * 2 * tebal,
          ),
          Radius.circular(r * tebal),
        );
        _kontur(Path()..addRRect(balut), _W.gorengan);
        if (detail) {
          for (var i = 0; i < 9; i++) {
            final sudut = i * 2 * pi / 9 + acak.nextDouble() * 0.3;
            c.drawCircle(
              Offset(cos(sudut) * r * 0.82, sin(sudut) * r * tebal * 0.8),
              r * 0.07,
              isi(_W.gorenganTua),
            );
          }
        }
        for (final (x, y) in [(-0.35, -0.08), (0.3, 0.12), (0.02, -0.2)]) {
          final o = Offset(r * x, r * y * tebal / 0.62);
          c
            ..drawCircle(o, r * 0.15, isi(k.warna))
            ..drawCircle(o, r * 0.15, garis(_W.gorenganTua, tg * 0.7));
        }
      case BentukMakanan.roti:
        // Dua lembar bertumpuk miring.
        for (final (dx, dy, putar) in [
          (-0.2, -0.14, -0.22),
          (0.2, 0.14, 0.2),
        ]) {
          c
            ..save()
            ..translate(r * dx, r * dy)
            ..rotate(putar);
          final lembar = RRect.fromRectAndCorners(
            Rect.fromCenter(
              center: Offset.zero,
              width: r * 1.34,
              height: r * 1.34,
            ),
            topLeft: Radius.circular(r * 0.42),
            topRight: Radius.circular(r * 0.42),
            bottomLeft: Radius.circular(r * 0.14),
            bottomRight: Radius.circular(r * 0.14),
          );
          _kontur(Path()..addRRect(lembar), k.warnaTua);
          c.drawRRect(lembar.deflate(r * 0.12), isi(w));
          if (detail) {
            for (var i = 0; i < 4; i++) {
              c.drawCircle(
                Offset(
                  (acak.nextDouble() - 0.5) * r * 0.8,
                  (acak.nextDouble() - 0.5) * r * 0.8,
                ),
                r * 0.05,
                isi(k.warnaTua.withValues(alpha: 0.45)),
              );
            }
          }
          c.restore();
        }
      case BentukMakanan.kapsul:
        final tinggi = r * 2 * k.rasio;
        _kontur(
          Path()..addRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(
                center: Offset.zero,
                width: r * 2,
                height: tinggi,
              ),
              Radius.circular(tinggi / 2),
            ),
          ),
          w,
        );
        if (detail && tinggi > tg * 5) {
          c.drawLine(
            Offset(-r * 0.55, tinggi * 0.18),
            Offset(r * 0.55, tinggi * 0.18),
            garis(k.warnaTua, tg * 0.8),
          );
        }
      case BentukMakanan.remah:
        const titik = [
          (-0.45, -0.3, 0.34),
          (0.4, -0.25, 0.3),
          (0.0, 0.35, 0.36),
          (-0.5, 0.4, 0.22),
          (0.5, 0.4, 0.24),
        ];
        _gabung(
          [for (final (x, y, rad) in titik) (Offset(r * x, r * y), r * rad)],
          w,
          tepi: k.warnaTua,
        );
      case BentukMakanan.tauge:
        final batang = Path()
          ..moveTo(-r, r * 0.1)
          ..quadraticBezierTo(0, -r * 0.7, r * 0.75, r * 0.15);
        c
          ..drawPath(batang, garis(_tinta, r * 0.26 + tg * 1.4))
          ..drawPath(batang, garis(w, r * 0.26))
          ..drawCircle(
            Offset(r * 0.78, r * 0.15),
            r * 0.22 + tg * 0.7,
            isi(_tinta),
          )
          ..drawCircle(Offset(r * 0.78, r * 0.15), r * 0.22, isi(k.warnaTua));
      case BentukMakanan.jamur:
        _kontur(
          Path()..addRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTRB(-r * 0.24, -r * 0.1, r * 0.24, r * 0.9),
              Radius.circular(r * 0.14),
            ),
          ),
          _W.telurPutih,
        );
        final tudung = Path()
          ..moveTo(-r, r * 0.05)
          ..arcToPoint(
            Offset(r, r * 0.05),
            radius: Radius.elliptical(r, r * 0.95),
          )
          ..quadraticBezierTo(0, r * 0.3, -r, r * 0.05)
          ..close();
        _kontur(tudung, w);
        if (detail) {
          c.drawArc(
            Rect.fromCenter(
              center: Offset(0, -r * 0.1),
              width: r * 1.2,
              height: r * 0.9,
            ),
            pi * 1.15,
            pi * 0.4,
            false,
            garis(k.warnaTua, tg * 0.8),
          );
        }
      case BentukMakanan.generik:
        _gabung([
          (Offset(-r * 0.2, 0), r * 0.7),
          (Offset(r * 0.35, -r * 0.15), r * 0.55),
          (Offset(r * 0.2, r * 0.3), r * 0.5),
        ], w);
        if (detail) {
          c.drawCircle(Offset(-r * 0.2, -r * 0.1), r * 0.16, isi(k.warnaTua));
        }
    }
  }
}
