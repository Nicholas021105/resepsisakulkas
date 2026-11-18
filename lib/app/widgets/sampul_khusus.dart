import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import 'pena_makanan.dart';

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
    this.wadah,
    this.tata,
    this.warnaUtama,
    this.kuah,
    this.siraman,
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

  final WadahSampul? wadah;
  final TataUtama? tata;
  final Color? warnaUtama;
  final Color? kuah;
  final Color? siraman;
  final Color? genangan;

  /// Saus kental yang menyelimuti sebagian besar makanan (bumbu kacang
  /// pecel, saus asam manis fuyunghai).
  final Color? selimut;
  final bool? balut;

  /// [baru] bila diisi ([tanpaWarna] → null), selain itu [lama].
  static Color? pilih(Color? baru, Color? lama) =>
      baru == null ? lama : (baru == tanpaWarna ? null : baru);
}

/// Gaya khusus per resep (kunci = id resep). Resep yang tidak ada di sini
/// memakai komposisi otomatis dari bahannya.
const petaSampulResep = <String, GayaSampul>{};
