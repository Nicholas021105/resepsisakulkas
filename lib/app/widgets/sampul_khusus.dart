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
    this.luasSelimut,
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

  /// Bagian luas dasar yang tertutup [selimut] (0–1); tepi makanan di luar
  /// saus tetap terlihat.
  final double? luasSelimut;
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

/// Orak-arik di atas mie/nasi goreng: gumpalan kuning bertepi keemasan
/// (tanpa garis tinta di tiap gumpal) agar kuningnya terbaca di kartu.
const _telurOrakArikKuning = Komponen(
  'telur-orak-arik',
  BentukMakanan.remah,
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
const _kejuParut = Komponen.hiasan(
  'keju-parut',
  BentukMakanan.taburan,
  _W.keju,
  _W.kejuTua,
  jumlah: 1,
  rasio: 0.2,
);
const _meses = Komponen.hiasan(
  'meses',
  BentukMakanan.taburan,
  _W.meses,
  _W.kecap,
  jumlah: 1,
  rasio: 0.2,
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
const _bawangMerahCincin = Komponen.hiasan(
  'bawang-merah-iris',
  BentukMakanan.cincin,
  _W.bawangMerah,
  _W.bawangMerahTua,
  jumlah: 4,
  skala: 1.1,
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
  // Helai tebal keemasan, telur orak-arik kuning, sawi. Data: telurnya
  // diorak-arik (bukan ceplok) dan tanpa cabai.
  'mie-goreng-telur': GayaSampul(
    pendamping: [
      _telurOrakArikKuning,
      Komponen(
        'sawi',
        BentukMakanan.daun,
        _W.daunMuda,
        _W.daunTua,
        jumlah: 2,
        skala: 1.3,
        rasio: 0.62,
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
    taburan: [_bawangGoreng],
  ),
  // Bubur putih yang lega: satu gundukan ayam suwir di tengah, 2 cakwe
  // besar, kerupuk di tepi, satu siraman kecap tipis. Daun bawang dan
  // bawang goreng hanya saat detail.
  'bubur-ayam': GayaSampul(
    utama: Komponen(
      'ayam-suwir',
      BentukMakanan.suwir,
      _W.ayamSuwir,
      _W.ayamSuwirTua,
      jumlah: 1,
      skala: 1.2,
    ),
    pendamping: [
      Komponen(
        'cakwe',
        BentukMakanan.cakwe,
        _W.cakwe,
        _W.cakweTua,
        jumlah: 2,
        skala: 1.35,
      ),
    ],
    hiasan: [
      Komponen.hiasan(
        'daun-bawang',
        BentukMakanan.cincin,
        _W.daun,
        _W.daunTua,
        jumlah: 4,
        hanyaDetail: true,
      ),
    ],
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
    // Pelengkap lazim ayam goreng; juga mengisi piring yang lapang.
    pelengkap: [_timunIris],
  ),

  // --- Penyesuaian kecil ---------------------------------------------------

  // Tahu digoreng dulu (kulit keemasan), lalu dimasak di saus kecap.
  'tahu-kecap': GayaSampul(
    utama: Komponen(
      'tahu-goreng',
      BentukMakanan.kubus,
      _W.tahuGoreng,
      _W.tahuGorengTua,
      jumlah: 5,
      skala: 0.9,
    ),
    hiasan: [_cabaiIris, _bawangMerahIris],
  ),
  'ayam-kecap': GayaSampul(
    utama: Komponen(
      'ayam-kecap',
      BentukMakanan.ayamKecap,
      _W.ayamKecap,
      _W.kecap,
      jumlah: 3,
      skala: 1.1,
    ),
  ),
  'ayam-bakar-kecap': GayaSampul(
    utama: Komponen(
      'ayam-bakar',
      BentukMakanan.ayamBakar,
      _W.ayamBakar,
      _W.kecap,
      jumlah: 3,
      skala: 1.1,
    ),
    pendamping: [],
    hiasan: [],
    // Kecapnya sudah menjadi lapisan karamel, bukan siraman.
    siraman: GayaSampul.tanpaWarna,
    pelengkap: [
      _timunIris,
      Komponen(
        'jeruk-iris',
        BentukMakanan.irisan,
        _W.jeruk,
        _W.jerukKulit,
        jumlah: 1,
      ),
    ],
  ),
  'bakwan-sayur': GayaSampul(
    utama: Komponen(
      'bakwan',
      BentukMakanan.bakwan,
      _W.gorengan,
      _W.gorenganTua,
      jumlah: 4,
      skala: 1.15,
    ),
    balut: false,
    pendamping: [],
    hiasan: [],
  ),
  // Tauge yang padat sebagai isi utama, tahu goreng dadu sebagai pendamping.
  'oseng-tahu-tauge': GayaSampul(
    utama: Komponen(
      'tauge',
      BentukMakanan.tauge,
      _W.tauge,
      _W.jagung,
      jumlah: 18,
      skala: 1.1,
    ),
    tata: TataUtama.tumpuk,
    pendamping: [
      Komponen(
        'tahu-dadu',
        BentukMakanan.kubus,
        _W.tahuGoreng,
        _W.tahuGorengTua,
        jumlah: 3,
        skala: 0.75,
      ),
    ],
    hiasan: [_cabaiIris, _bawangPutihIris],
  ),
  // Irisan serong besar berkulit merah kecokelatan, bawang merah iris, di
  // genangan saus merah.
  'tumis-sosis': GayaSampul(
    utama: Komponen(
      'sosis-iris',
      BentukMakanan.irisanMiring,
      _W.sosisDalam,
      _W.sosis,
      jumlah: 7,
      skala: 1.25,
      rasio: 0.56,
    ),
    tata: TataUtama.tumpuk,
    hiasan: [_bawangMerahCincin, _bawangPutihIris],
    genangan: _W.cabaiTua,
  ),
  // Helai tipis pucat dengan wortel korek api dan kol (data: telurnya
  // opsional; tanpa telur agar tidak tertukar dengan mie goreng).
  'bihun-goreng': GayaSampul(
    pendamping: [
      Komponen(
        'wortel-korek',
        BentukMakanan.batang,
        _W.wortel,
        _W.wortelTua,
        jumlah: 3,
        skala: 1.05,
        rasio: 0.1,
      ),
      Komponen(
        'kol',
        BentukMakanan.daun,
        _W.daunPucat,
        _W.daunPucatTua,
        jumlah: 2,
        skala: 1.1,
        rasio: 0.85,
      ),
    ],
    hiasan: [_bawangPutihIris],
  ),
  'kolak-pisang-ubi': GayaSampul(
    kuah: _W.kuahKolak,
    utama: Komponen(
      'pisang-potong',
      BentukMakanan.irisanMiring,
      _W.pisang,
      _W.pisangTua,
      jumlah: 6,
      skala: 1.1,
      rasio: 0.6,
    ),
    pendamping: [
      Komponen(
        'ubi-kubus',
        BentukMakanan.kubus,
        _W.ubi,
        _W.ubiKulit,
        jumlah: 3,
        skala: 0.95,
      ),
    ],
  ),
  // Kuah kental kuning pucat: butir jagung, serat telur, daun bawang.
  'sup-jagung-telur': GayaSampul(
    kuah: _W.kuahJagung,
    utama: Komponen(
      'jagung-pipil',
      BentukMakanan.butirJagung,
      _W.jagung,
      _W.jagungTua,
      jumlah: 9,
      skala: 0.85,
    ),
    tata: TataUtama.tumpuk,
    pendamping: [
      Komponen(
        'serat-telur',
        BentukMakanan.seratTelur,
        _W.telurPutih,
        _W.telurTepi,
        jumlah: 3,
        skala: 1.3,
      ),
    ],
    hiasan: [_daunBawangIris],
  ),
  'jagung-susu-keju': GayaSampul(
    wadah: WadahSampul.cup,
    kuah: _W.susu,
    utama: Komponen(
      'jagung-pipil',
      BentukMakanan.butirJagung,
      _W.jagung,
      _W.jagungTua,
      jumlah: 14,
      skala: 0.95,
    ),
    tata: TataUtama.tumpuk,
    pendamping: [],
    hiasan: [],
    siraman: _W.susu,
    taburan: [_kejuParut],
  ),
  'roti-bakar-cokelat-keju': GayaSampul(
    utama: Komponen(
      'roti-bakar',
      BentukMakanan.rotiBakar,
      _W.rotiBakar,
      _W.rotiKulit,
      tunggal: true,
    ),
    pendamping: [],
    hiasan: [],
    taburan: [_meses, _kejuParut],
  ),
  'pisang-bakar-cokelat-keju': GayaSampul(
    utama: Komponen(
      'pisang-bakar',
      BentukMakanan.kapsul,
      _W.pisangBakar,
      _W.pisangTua,
      jumlah: 3,
      rasio: 0.36,
    ),
    tata: TataUtama.jajar,
    pendamping: [],
    hiasan: [],
    siraman: _W.susu,
    siramanTipis: true,
    taburan: [_meses, _kejuParut],
  ),
  // Roti dicelup telur lalu digoreng: lembar keemasan, tanpa telur terpisah.
  'roti-telur': GayaSampul(
    utama: Komponen(
      'roti-telur',
      BentukMakanan.roti,
      _W.rotiTelur,
      _W.rotiKulit,
      tunggal: true,
    ),
    pendamping: [],
    hiasan: [],
  ),
  'roti-lapis-telur-keju': GayaSampul(
    utama: Komponen(
      'roti-lapis',
      BentukMakanan.rotiLapis,
      _W.roti,
      _W.rotiKulit,
      tunggal: true,
    ),
    pendamping: [],
    hiasan: [],
  ),
  // Bayam, tauge, dan kol rebus melingkar di tepi; bumbu kacang hanya di
  // tengah (bukan garis siraman).
  'pecel-sayur': GayaSampul(
    utama: Komponen(
      'sayur-pecel',
      BentukMakanan.sayurPecel,
      _W.daun,
      _W.daunTua,
      tunggal: true,
      skala: 1.1,
    ),
    pendamping: [],
    hiasan: [],
    siraman: GayaSampul.tanpaWarna,
    selimut: _W.bumbuKacang,
    luasSelimut: 0.53,
  ),
  // --- Pembeda kelompok telur ----------------------------------------------

  // Dadar bulat tipis bertepi kecokelatan; irisan bawang & daun bawang.
  'telur-dadar': GayaSampul(
    utama: Komponen(
      'telur-dadar',
      BentukMakanan.dadarBulat,
      _W.dadar,
      _W.dadarCokelat,
      tunggal: true,
      skala: 1.05,
    ),
    pendamping: [],
    hiasan: [
      Komponen.hiasan(
        'bawang-merah-iris',
        BentukMakanan.cincin,
        _W.bawangMerah,
        _W.bawangMerahTua,
        jumlah: 4,
        skala: 1.1,
      ),
      _daunBawangIris,
    ],
  ),
  // Dilipat setengah lingkaran; wortel, daun bawang, tomat menyembul.
  'omelet-sayur': GayaSampul(
    utama: Komponen(
      'omelet-lipat',
      BentukMakanan.dadarLipat,
      _W.dadar,
      _W.dadarCokelat,
      tunggal: true,
      skala: 1.05,
    ),
    pendamping: [],
    hiasan: [],
  ),
  // Dadar tebal dipotong empat, kornet terlihat di sisi potong.
  'telur-kornet': GayaSampul(
    utama: Komponen(
      'telur-kornet',
      BentukMakanan.dadarPotong,
      _W.dadar,
      _W.dadarTua,
      tunggal: true,
      skala: 1.05,
    ),
    pendamping: [],
    hiasan: [_daunBawangIris],
  ),
  // Telur tebal mengembang; saus asam manis menutup ± 60% bagian tengah,
  // cincin tepi keemasan tampak di sekelilingnya. Data: tanpa kacang
  // polong maupun daun bawang (sayurnya kol & wortel).
  'fuyunghai': GayaSampul(
    utama: Komponen(
      'fuyunghai',
      BentukMakanan.fuyunghai,
      _W.dadar,
      _W.dadarTua,
      tunggal: true,
      skala: 1.05,
    ),
    pendamping: [],
    hiasan: [],
    siraman: GayaSampul.tanpaWarna,
    selimut: _W.sausTomat,
    luasSelimut: 0.45,
  ),

  // --- Polesan & kepadatan --------------------------------------------------

  // Telur ceplok berkecap ditaburi irisan cabai dan bawang merah.
  'telur-ceplok-kecap': GayaSampul(
    hiasan: [
      _cabaiIris,
      Komponen.hiasan(
        'bawang-merah-iris',
        BentukMakanan.cincin,
        _W.bawangMerah,
        _W.bawangMerahTua,
        jumlah: 4,
        skala: 1.1,
      ),
    ],
  ),
  // Satu telur ceplok besar di atas nasi, kecap, dan margarin.
  'nasi-telur': GayaSampul(
    pendamping: [
      Komponen(
        'telur-ceplok',
        BentukMakanan.telurCeplok,
        _W.telurPutih,
        _W.telurKuning,
        jumlah: 1,
        skala: 2.1,
      ),
      Komponen(
        'margarin',
        BentukMakanan.kubus,
        _W.margarin,
        _W.margarinTua,
        jumlah: 1,
        skala: 1.0,
      ),
    ],
    hiasan: [],
  ),

  // Tiga nasi goreng dibedakan lewat topping: telur orak-arik kuning
  // (nasi goreng), irisan sosis bulat (sosis), teri & lalapan (teri).
  'nasi-goreng': GayaSampul(
    pendamping: [_telurOrakArikKuning],
    hiasan: [_bawangMerahCincin, _cabaiIris],
    taburan: [_bawangGoreng],
  ),
  // Data: sosis "iris bulat"; telurnya opsional (tidak digambar).
  'nasi-goreng-sosis': GayaSampul(
    pendamping: [
      Komponen(
        'sosis-bulat',
        BentukMakanan.irisan,
        _W.sosisDalam,
        _W.sosis,
        jumlah: 3,
        skala: 1.05,
      ),
    ],
    hiasan: [_bawangMerahCincin],
    taburan: [_bawangGoreng],
  ),

  // Bawang goreng hanya pada masakan yang lazim memakainya (detail saja).
  'sop-ayam': GayaSampul(taburan: [_bawangGoreng]),
  'sayur-sop': GayaSampul(taburan: [_bawangGoreng]),
  'opor-ayam': GayaSampul(taburan: [_bawangGoreng]),
  'semur-ayam-kentang': GayaSampul(taburan: [_bawangGoreng]),

  // Mangkuk kecil berisi kecap dengan irisan cabai, bawang merah, tomat.
  'sambal-kecap': GayaSampul(
    wadah: WadahSampul.mangkukKecil,
    kuah: _W.kecap,
    tanpaUtama: true,
    pendamping: [],
    hiasan: [
      Komponen.hiasan(
        'cabai-iris',
        BentukMakanan.cincin,
        _W.cabai,
        _W.cabaiTua,
        jumlah: 6,
        skala: 1.1,
      ),
      Komponen.hiasan(
        'bawang-merah-iris',
        BentukMakanan.cincin,
        _W.bawangMerah,
        _W.bawangMerahTua,
        jumlah: 4,
        skala: 1.15,
      ),
      Komponen.hiasan(
        'tomat-dadu',
        BentukMakanan.kubus,
        _W.tomatDalam,
        _W.tomat,
        jumlah: 3,
        skala: 1.1,
      ),
    ],
  ),
};
