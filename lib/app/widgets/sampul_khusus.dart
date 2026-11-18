import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import '../theme/app_warna_makanan.dart';
import 'pena_makanan.dart';

typedef _W = WarnaMakanan;

/// Wadah sajian di sampul resep.
enum WadahSampul {
  piring,
  mangkuk,
  cobek,
  daunPisang,

  /// Gelas plastik tampak atas dengan cincin bibir tebal (jagung susu keju).
  cup,

  /// Mangkuk kecil di tengah piring (sambal kecap, cocolan).
  mangkukKecil,
}

/// Cara potongan utama yang berjumlah banyak ditata.
enum TataUtama {
  /// Melingkar di dekat tepi, potongan ke-5 dst. di tengah (bawaan).
  cincin,

  /// Tumpukan padat yang saling menumpang (orek, tumisan sayur).
  tumpuk,

  /// Berjajar sejajar (pisang goreng, roti).
  jajar,

  /// Mengembang seperti kipas dari satu titik.
  kipas,
}

/// Penimpa hasil bawaan `susunSampul` untuk satu resep. Semua field
/// opsional: null berarti "pakai hasil bawaan". Untuk MENGHAPUS warna
/// bawaan (mis. genangan pada orek yang kering), pakai [tanpaWarna].
///
/// Dipakai bila komposisi otomatis dari bahan tidak menyerupai wujud asli
/// masakannya (cara potong, olahan, susunan, pelengkap saji).
@immutable
class GayaSampul {
  const GayaSampul({
    this.utama,
    this.tanpaUtama = false,
    this.pendamping,
    this.hiasan,
    this.pelengkap,
    this.taburan,
    this.wadah,
    this.tata,
    this.warnaUtama,
    this.kuah,
    this.siraman,
    this.siramanTipis,
    this.genangan,
    this.selimut,
    this.balut,
  });

  /// Penanda "tanpa warna" untuk [siraman], [genangan], [warnaUtama], dan
  /// [selimut].
  static const tanpaWarna = Color(0x00000000);

  final Komponen? utama;

  /// Tanpa komponen utama; isinya hanya pendamping/hiasan (sambal kecap).
  final bool tanpaUtama;

  final List<Komponen>? pendamping;
  final List<Komponen>? hiasan;

  /// Pelengkap saji di tepi wadah (kerupuk, irisan timun, cabai rawit
  /// utuh). `Komponen.jumlah` = banyaknya potongan.
  final List<Komponen>? pelengkap;

  /// Taburan halus yang ditebar di atas makanan utama (bawang goreng, keju
  /// parut, meses), bentuk [BentukMakanan.taburan].
  final List<Komponen>? taburan;

  final WadahSampul? wadah;
  final TataUtama? tata;
  final Color? warnaUtama;
  final Color? kuah;
  final Color? siraman;

  /// Siraman berupa garis tipis (kecap di bubur), bukan aliran tebal.
  final bool? siramanTipis;
  final Color? genangan;

  /// Saus kental yang menyelimuti sebagian besar makanan (bumbu kacang
  /// pecel, saus asam manis fuyunghai).
  final Color? selimut;
  final bool? balut;

  /// [baru] bila diisi ([tanpaWarna] → null), selain itu [lama].
  static Color? pilih(Color? baru, Color? lama) =>
      baru == null ? lama : (baru == tanpaWarna ? null : baru);
}

// ---------------------------------------------------------------------------
// Komponen olahan yang dipakai beberapa resep
// ---------------------------------------------------------------------------

const _cabaiIris = Komponen.hiasan(
  'cabai-iris',
  BentukMakanan.cincin,
  _W.cabai,
  _W.cabaiTua,
  jumlah: 5,
  skala: 0.9,
);
const _cabaiRawit = Komponen(
  'cabai-rawit',
  BentukMakanan.cabai,
  _W.cabai,
  _W.daunTua,
  jumlah: 2,
  skala: 0.95,
);
const _daunBawangIris = Komponen.hiasan(
  'daun-bawang',
  BentukMakanan.cincin,
  _W.daun,
  _W.daunTua,
  jumlah: 5,
);
const _bawangMerahIris = Komponen.hiasan(
  'bawang-merah',
  BentukMakanan.remah,
  _W.bawangMerah,
  _W.bawangMerahTua,
  jumlah: 3,
);
const _bawangPutihIris = Komponen.hiasan(
  'bawang-putih',
  BentukMakanan.remah,
  _W.bawangPutih,
  _W.bawangPutihTua,
  jumlah: 3,
);
const _daunSalam = Komponen.hiasan(
  'daun-salam',
  BentukMakanan.daun,
  _W.daunGelap,
  _W.daunTua,
  jumlah: 1,
  skala: 1.8,
  rasio: 0.45,
);

/// Taburan bawang goreng: hanya saat detail.
const _bawangGoreng = Komponen.hiasan(
  'bawang-goreng',
  BentukMakanan.taburan,
  _W.bawangGoreng,
  _W.bawangGorengTua,
  jumlah: 1,
  rasio: 0.6,
  hanyaDetail: true,
);
const _telurOrakArik = Komponen(
  'telur-orak-arik',
  BentukMakanan.orakArik,
  _W.dadar,
  _W.dadarTua,
  jumlah: 3,
  skala: 1.15,
);
const _teri = Komponen.hiasan(
  'teri',
  BentukMakanan.ikanTeri,
  _W.teri,
  _W.teriTua,
  jumlah: 9,
  skala: 1.3,
);
const _timunIris = Komponen(
  'timun-iris',
  BentukMakanan.irisan,
  _W.timun,
  _W.timunKulit,
  jumlah: 2,
);
const _tomatIris = Komponen(
  'tomat-iris',
  BentukMakanan.irisan,
  _W.tomatDalam,
  _W.tomat,
  jumlah: 1,
);

/// Gaya khusus per resep (kunci = id resep). Resep yang tidak ada di sini
/// memakai komposisi otomatis dari bahannya.
const petaSampulResep = <String, GayaSampul>{
  // Tempe korek api berkecap, menumpuk; orek itu kering (tanpa genangan).
  'orek-tempe': GayaSampul(
    utama: Komponen(
      'tempe-orek',
      BentukMakanan.batang,
      _W.tempeKecap,
      _W.tempeTua,
      jumlah: 24,
      skala: 1.1,
      rasio: 0.2,
    ),
    tata: TataUtama.tumpuk,
    pendamping: [],
    hiasan: [_cabaiIris, _bawangMerahIris, _daunSalam],
    genangan: GayaSampul.tanpaWarna,
  ),
  // Lembar tempe lebar berbalut tepung pucat setengah matang.
  'tempe-mendoan': GayaSampul(
    utama: Komponen(
      'mendoan',
      BentukMakanan.lembarTepung,
      _W.tepungMendoan,
      _W.tempe,
      jumlah: 3,
      skala: 1.25,
    ),
    balut: false,
    pendamping: [],
    hiasan: [_daunBawangIris],
    pelengkap: [_cabaiRawit],
  ),
  'tahu-goreng': GayaSampul(
    utama: Komponen(
      'tahu-goreng',
      BentukMakanan.tahuGoreng,
      _W.tahuGoreng,
      _W.tahuGorengTua,
      jumlah: 5,
      skala: 0.95,
    ),
    pendamping: [],
    hiasan: [],
    pelengkap: [
      Komponen(
        'cabai-rawit',
        BentukMakanan.cabai,
        _W.cabai,
        _W.daunTua,
        jumlah: 3,
        skala: 0.95,
      ),
    ],
  ),
  // Dadar tebal berisi tahu, disiram kecap dan ditaburi irisan cabai.
  'tahu-telur': GayaSampul(
    utama: Komponen(
      'tahu-telur',
      BentukMakanan.telurDadar,
      _W.dadar,
      _W.dadarTua,
      tunggal: true,
      skala: 1.12,
    ),
    pendamping: [
      Komponen(
        'tahu',
        BentukMakanan.kubus,
        _W.tahu,
        _W.tahuTua,
        jumlah: 3,
        skala: 0.62,
      ),
    ],
    hiasan: [_cabaiIris],
    siraman: _W.kecap,
  ),
  'tumis-kangkung': GayaSampul(
    utama: Komponen(
      'kangkung',
      BentukMakanan.batangKangkung,
      _W.daunMuda,
      _W.daunTua,
      jumlah: 20,
      skala: 1.2,
    ),
    tata: TataUtama.tumpuk,
    pendamping: [],
    hiasan: [_cabaiIris, _bawangPutihIris],
    genangan: _W.sausTiram,
  ),
  // Data: telurnya diorak-arik (bukan ceplok) dan tanpa cabai.
  'mie-goreng-telur': GayaSampul(
    pendamping: [
      _telurOrakArik,
      Komponen(
        'sawi',
        BentukMakanan.daun,
        _W.daunMuda,
        _W.daunTua,
        jumlah: 2,
        rasio: 0.55,
      ),
    ],
    hiasan: [_bawangPutihIris],
  ),
  'perkedel-kentang': GayaSampul(
    utama: Komponen(
      'perkedel',
      BentukMakanan.perkedel,
      _W.gorengan,
      _W.gorenganTua,
      jumlah: 5,
      skala: 1.05,
    ),
    pendamping: [],
    hiasan: [],
  ),
  // Data: tanpa wortel; telurnya diorak-arik.
  'tumis-buncis': GayaSampul(
    utama: Komponen(
      'buncis-iris',
      BentukMakanan.irisanMiring,
      _W.daunMuda,
      _W.daun,
      jumlah: 18,
      skala: 0.8,
      rasio: 0.34,
    ),
    tata: TataUtama.tumpuk,
    pendamping: [_telurOrakArik],
    hiasan: [_bawangPutihIris, _bawangMerahIris],
  ),
  'tempe-teri-pedas': GayaSampul(
    utama: Komponen(
      'tempe-kering',
      BentukMakanan.batang,
      _W.tempeBalado,
      _W.tempeTua,
      jumlah: 16,
      rasio: 0.22,
    ),
    tata: TataUtama.tumpuk,
    pendamping: [],
    hiasan: [
      Komponen.hiasan(
        'teri',
        BentukMakanan.ikanTeri,
        _W.teri,
        _W.teriTua,
        jumlah: 10,
        skala: 1.3,
      ),
      _cabaiIris,
    ],
    genangan: _W.sambalTua,
  ),
  'nasi-goreng-teri': GayaSampul(
    hiasan: [_teri, _cabaiIris],
    pelengkap: [_timunIris, _tomatIris],
  ),
  // Bubur putih: ayam suwir, cakwe, kerupuk di tepi, kecap tipis.
  'bubur-ayam': GayaSampul(
    utama: Komponen(
      'ayam-suwir',
      BentukMakanan.suwir,
      _W.ayamSuwir,
      _W.ayamSuwirTua,
      jumlah: 1,
      skala: 1.15,
    ),
    pendamping: [
      Komponen(
        'cakwe',
        BentukMakanan.cakwe,
        _W.cakwe,
        _W.cakweTua,
        jumlah: 3,
        skala: 1.15,
      ),
    ],
    hiasan: [_daunBawangIris],
    pelengkap: [
      Komponen(
        'kerupuk',
        BentukMakanan.kerupuk,
        _W.kerupuk,
        _W.kerupukTua,
        jumlah: 2,
        skala: 1.35,
      ),
    ],
    siraman: _W.kecap,
    siramanTipis: true,
    taburan: [_bawangGoreng],
  ),
  // Data: langkahnya hanya "kocok", tetapi masakannya orak-arik.
  'telur-orak-arik-tomat': GayaSampul(
    utama: Komponen(
      'orak-arik',
      BentukMakanan.orakArik,
      _W.dadar,
      _W.dadarTua,
      jumlah: 7,
      skala: 1.3,
    ),
    tata: TataUtama.tumpuk,
    pendamping: [
      Komponen(
        'tomat-dadu',
        BentukMakanan.kubus,
        _W.tomatDalam,
        _W.tomat,
        jumlah: 3,
        skala: 0.7,
      ),
    ],
    hiasan: [_daunBawangIris],
  ),
  'pisang-goreng': GayaSampul(
    utama: Komponen(
      'pisang-goreng',
      BentukMakanan.pisangGoreng,
      _W.gorengan,
      _W.gorenganTua,
      jumlah: 3,
      rasio: 0.36,
    ),
    tata: TataUtama.jajar,
    balut: false,
    pendamping: [],
    hiasan: [],
  ),
  // Irisan ubi bulat berbalut tepung (data: ubi dicelup adonan).
  'ubi-goreng': GayaSampul(
    utama: Komponen(
      'ubi-goreng',
      BentukMakanan.ubiGoreng,
      _W.gorengan,
      _W.ubi,
      jumlah: 5,
      skala: 1.05,
    ),
    balut: false,
    pendamping: [],
    hiasan: [],
  ),
  'perkedel-jagung': GayaSampul(
    utama: Komponen(
      'perkedel-jagung',
      BentukMakanan.gorenganJagung,
      _W.gorengan,
      _W.gorenganTua,
      jumlah: 5,
      skala: 1.05,
    ),
    balut: false,
    pendamping: [],
    hiasan: [],
  ),
  'udang-goreng-tepung': GayaSampul(
    utama: Komponen(
      'udang-tepung',
      BentukMakanan.udangTepung,
      _W.gorengan,
      _W.gorenganTua,
      jumlah: 6,
    ),
    balut: false,
    pendamping: [],
    hiasan: [],
    pelengkap: [
      Komponen(
        'jeruk-iris',
        BentukMakanan.irisan,
        _W.jeruk,
        _W.jerukKulit,
        jumlah: 1,
        skala: 1.25,
      ),
    ],
  ),
  'ayam-goreng-tepung': GayaSampul(
    utama: Komponen(
      'ayam-tepung',
      BentukMakanan.ayamTepung,
      _W.gorengan,
      _W.gorenganTua,
      jumlah: 3,
      skala: 1.15,
    ),
    balut: false,
    pendamping: [],
    hiasan: [],
  ),
};
