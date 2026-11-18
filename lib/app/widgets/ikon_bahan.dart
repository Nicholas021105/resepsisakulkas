import 'dart:math';

import 'package:flutter/material.dart';

import '../data/models/bahan_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_warna_makanan.dart';
import 'pena_makanan.dart';

typedef _W = WarnaMakanan;

/// Ikon bahan berukuran tetap, digambar sendiri dengan gaya yang sama
/// seperti sampul resep (`SampulResep`): flat 2D, garis tepi tinta, warna
/// dari [WarnaMakanan]. Ikon menampilkan bahan MENTAH/UTUH (telur utuh,
/// tomat bulat), sedangkan sampul menampilkan potongan matangnya.
///
/// Semua bahan di dataset punya pelukis ([punyaPelukis]). Bahan baru dari
/// server yang belum dikenal digambar sebagai bentuk generik berwarna
/// kategorinya; emoji hanya dipakai bila kategorinya juga tidak diketahui.
/// Data JSON tidak diubah, jadi data server tetap cocok.
class IkonBahan extends StatelessWidget {
  final String id;
  final String emoji;
  final double ukuran;

  /// Kategori bahan, untuk ikon cadangan bila [id] tidak dikenal.
  final KategoriBahan? kategori;

  const IkonBahan({
    super.key,
    required this.id,
    required this.emoji,
    this.ukuran = 28,
    this.kategori,
  });

  IkonBahan.dari(Bahan bahan, {Key? key, double ukuran = 28})
    : this(
        key: key,
        id: bahan.id,
        emoji: bahan.emoji,
        ukuran: ukuran,
        kategori: bahan.kategori,
      );

  /// Sisi ikon (dp) mulai bintik, urat, butir, dan garis label digambar.
  static const ambangDetail = 24.0;

  /// Emoji pengganti: 🥫 kornet sama persis dengan saus tomat.
  static const _gantiEmoji = {'kornet': '🥩'};

  /// Bahan ini digambar dengan CustomPainter (bukan emoji).
  static bool punyaPelukis(String id) => IkonBahanPainter.dikenal.contains(id);

  /// Emoji yang ditampilkan bila bahan tidak punya pelukis dan kategorinya
  /// tidak diketahui.
  static String emojiTampil(String id, String emoji) =>
      _gantiEmoji[id] ?? emoji;

  @override
  Widget build(BuildContext context) {
    final kat = kategori;
    final Widget isi;
    if (punyaPelukis(id)) {
      isi = CustomPaint(painter: IkonBahanPainter(id));
    } else if (kat != null) {
      isi = CustomPaint(
        painter: IkonBahanPainter(id, cadangan: AppColors.magnet(kat)),
      );
    } else {
      isi = Center(
        child: Text(
          emojiTampil(id, emoji),
          // Ikon: ukurannya tetap, tidak ikut textScaler.
          textScaler: TextScaler.noScaling,
          style: TextStyle(fontSize: ukuran * 0.8, height: 1),
        ),
      );
    }
    return ExcludeSemantics(
      child: SizedBox.square(dimension: ukuran, child: isi),
    );
  }
}

/// Pelukis semua ikon bahan. Digambar di grid 48 × 48 unit (area gambar
/// 4..44) lalu diskalakan ke kanvas; garis tepi setebal
/// `max(1, sisi × 0,055)` piksel di ukuran berapa pun.
class IkonBahanPainter extends CustomPainter {
  final String id;

  /// Memaksa detail tampil/sembunyi; null = menurut ukuran kanvas
  /// (lihat [IkonBahan.ambangDetail]).
  final bool? detail;

  /// Warna bentuk generik untuk [id] yang tidak dikenal; null = tidak
  /// menggambar apa pun untuk id itu.
  final Color? cadangan;

  const IkonBahanPainter(
    this.id, {
    this.detail,
    this.cadangan,
    this.mentah = false,
  });

  /// Id bahan yang punya gambar khusus.
  static const dikenal = {
    'telur', 'tahu', 'tempe', 'ayam', 'sosis', 'udang', 'ikan-teri', //
    'kornet', 'keju', 'kacang-tanah', 'tomat', 'wortel', 'terong', 'timun',
    'labu-siam', 'kentang', 'ubi', 'jagung', 'cabai', 'pisang', //
    'jeruk-nipis', 'jamur', 'brokoli', 'tauge', 'buncis', 'bayam', //
    'kangkung', 'sawi-hijau', 'kol', 'seledri', 'daun-bawang', 'daun-salam',
    'bawang-merah', 'bawang-putih', 'kecap-manis', 'saus-tomat', //
    'saus-tiram', 'minyak-goreng', 'susu-kental-manis', 'garam', 'merica',
    'gula', 'kaldu-bubuk', 'tepung-terigu', 'santan', 'margarin', 'meses',
    'gula-merah', 'air', 'nasi', 'mie-instan', 'bihun', 'roti-tawar',
  };

  /// Sisi grid gambar.
  static const grid = 48.0;

  /// Tanpa koreksi ukuran optis ([_optis]); hanya untuk mengukur gambar
  /// asli saat menyusun tabel koreksi.
  @visibleForTesting
  final bool mentah;

  /// Koreksi ukuran optis per ikon: (skala, pusat x, pusat y) bounding box
  /// gambar asli di grid 48. Gambar diskalakan di sekitar pusatnya lalu
  /// dipindah ke tengah kanvas, sehingga sisi terpanjang tiap ikon
  /// (termasuk garis tepi) 34–40 unit: bentuk bulat/kotak padat ± 35,
  /// bentuk sedang ± 37, bentuk ramping/diagonal ± 39. Garis tepi tidak ikut
  /// diskalakan. Dijaga oleh `test/ikon_bahan_test.dart`.
  static const _optis = <String, (double, double, double)>{
    'telur': (0.852, 24.00, 24.00),
    'tahu': (0.964, 24.00, 24.00),
    'tempe': (0.852, 24.00, 24.00),
    'ayam': (1.046, 25.05, 23.35),
    'sosis': (1.103, 24.00, 24.00),
    'udang': (0.935, 22.25, 26.00),
    'ikan-teri': (0.935, 20.70, 27.15),
    'kornet': (0.983, 25.65, 24.50),
    'keju': (0.900, 24.00, 24.50),
    'kacang-tanah': (1.018, 23.80, 24.75),
    'tomat': (0.800, 24.00, 23.25),
    'wortel': (1.087, 26.15, 21.55),
    'terong': (1.052, 22.70, 24.15),
    'timun': (1.131, 24.00, 24.00),
    'labu-siam': (0.864, 24.00, 22.20),
    'kentang': (0.892, 23.75, 24.50),
    'ubi': (1.178, 23.65, 23.95),
    'jagung': (1.025, 22.95, 24.90),
    'cabai': (1.097, 23.15, 20.00),
    'pisang': (1.231, 21.35, 17.20),
    'jeruk-nipis': (0.852, 24.00, 24.00),
    'jamur': (0.852, 24.00, 23.00),
    'brokoli': (0.876, 24.00, 23.00),
    'tauge': (0.882, 23.60, 26.40),
    'buncis': (0.954, 26.30, 21.40),
    'bayam': (1.097, 22.00, 25.50),
    'kangkung': (1.120, 22.35, 25.70),
    'sawi-hijau': (1.117, 23.10, 24.85),
    'kol': (0.876, 24.00, 24.00),
    'seledri': (1.000, 23.50, 23.45),
    'daun-bawang': (1.077, 23.40, 23.30),
    'daun-salam': (1.080, 22.15, 25.80),
    'bawang-merah': (0.825, 24.00, 22.75),
    'bawang-putih': (0.825, 24.00, 22.75),
    'kecap-manis': (0.984, 24.00, 24.50),
    'saus-tomat': (0.957, 24.00, 24.50),
    'saus-tiram': (1.110, 24.00, 27.50),
    'minyak-goreng': (0.957, 24.00, 24.50),
    'susu-kental-manis': (1.042, 24.00, 28.00),
    'garam': (1.040, 24.00, 25.50),
    'merica': (1.040, 24.00, 25.50),
    'gula': (1.077, 23.95, 27.35),
    'kaldu-bubuk': (0.983, 24.00, 24.00),
    'tepung-terigu': (0.917, 24.00, 24.25),
    'santan': (0.917, 24.00, 24.25),
    'margarin': (1.012, 24.00, 28.50),
    'meses': (0.983, 24.00, 25.50),
    'gula-merah': (0.900, 24.00, 25.50),
    'air': (0.905, 24.00, 24.00),
    'nasi': (0.852, 24.00, 26.30),
    'mie-instan': (0.900, 24.00, 24.00),
    'bihun': (0.901, 24.00, 24.00),
    'roti-tawar': (0.900, 24.00, 24.50),
  };

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    if (s <= 0) return;
    final skala = s / grid;
    final (koreksi, cx, cy) = mentah
        ? (1.0, grid / 2, grid / 2)
        : _optis[id] ?? (1.0, grid / 2, grid / 2);
    final pena = PenaMakanan(
      canvas,
      max(1.0, s * 0.055) / skala / koreksi,
      detail ?? s >= IkonBahan.ambangDetail,
    );
    canvas
      ..save()
      ..translate((size.width - s) / 2, (size.height - s) / 2)
      ..scale(skala)
      ..translate(grid / 2, grid / 2)
      ..scale(koreksi)
      ..translate(-cx, -cy);
    _Lukis(canvas, pena).gambar(id, cadangan);
    canvas.restore();
  }

  @override
  bool shouldRepaint(IkonBahanPainter lama) =>
      lama.id != id ||
      lama.detail != detail ||
      lama.cadangan != cadangan ||
      lama.mentah != mentah;
}

/// Satu sesi melukis ikon di grid 48 unit.
class _Lukis {
  _Lukis(this.c, this.p);

  final Canvas c;
  final PenaMakanan p;

  static const _tinta = AppColors.tinta;
  static const _pusat = Offset(24, 24);

  /// Arah benda memanjang: kiri-bawah → kanan-atas (40°).
  static const _diag = -40 * pi / 180;

  double get tg => p.tg;
  bool get detail => p.detail;

  Paint isi(Color w) => p.isi(w);
  Paint garis(Color w, [double? tebal]) => p.garis(w, tebal ?? tg);
  void kontur(Path jalur, Color w) => p.kontur(jalur, w);

  void lingkar(Offset o, double r, Color w) =>
      kontur(Path()..addOval(Rect.fromCircle(center: o, radius: r)), w);

  /// Menggambar [f] dengan titik asal di [o] dan diputar [sudut].
  void putar(Offset o, double sudut, void Function() f) {
    c
      ..save()
      ..translate(o.dx, o.dy)
      ..rotate(sudut);
    f();
    c.restore();
  }

  /// Bentuk pustaka sampul ([PenaMakanan.gambar]) di [o].
  void bentuk(
    BentukMakanan b,
    Color w,
    Color tua, {
    double r = 18,
    double sudut = 0,
    Offset o = _pusat,
    double rasio = 0.5,
  }) => putar(
    o,
    sudut,
    () => p.gambar(b, Komponen('ikon', b, w, tua, rasio: rasio), r, Random(7)),
  );

  /// Garis tebal bertepi tinta (batang, tangkai, tali).
  void batang(Path jalur, Color w, double tebal) => c
    ..drawPath(jalur, garis(_tinta, tebal + tg * 2))
    ..drawPath(jalur, garis(w, tebal));

  Path garisLurus(Offset a, Offset b) => Path()
    ..moveTo(a.dx, a.dy)
    ..lineTo(b.dx, b.dy);

  /// Tetesan kecil (label minyak, susu) berujung di atas [atas].
  void tetes(Offset atas, double r, Color w) {
    final bawah = atas + Offset(0, r * 2.4);
    final j = Path()
      ..moveTo(atas.dx, atas.dy)
      ..quadraticBezierTo(
        atas.dx + r * 1.2,
        bawah.dy - r * 1.1,
        atas.dx + r,
        bawah.dy - r * 0.2,
      )
      ..arcToPoint(
        Offset(atas.dx - r, bawah.dy - r * 0.2),
        radius: Radius.circular(r),
      )
      ..quadraticBezierTo(
        atas.dx - r * 1.2,
        bawah.dy - r * 1.1,
        atas.dx,
        atas.dy,
      )
      ..close();
    c
      ..drawPath(j, isi(w))
      ..drawPath(j, garis(_tinta, tg * 0.6));
  }

  void gambar(String id, Color? cadangan) {
    switch (id) {
      // A. Protein
      case 'telur':
        _telur();
      case 'tahu':
        _tahu();
      case 'tempe':
        bentuk(BentukMakanan.tempe, _W.tempe, _W.tempeTua, r: 19);
      case 'ayam':
        bentuk(
          BentukMakanan.ayam,
          _W.ayam,
          _W.ayamTua,
          r: 19,
          sudut: _diag,
          o: const Offset(25, 23),
        );
      case 'sosis':
        bentuk(BentukMakanan.sosis, _W.sosis, _W.sosisTua, r: 19, sudut: _diag);
      case 'udang':
        bentuk(
          BentukMakanan.udang,
          _W.udang,
          _W.udangTua,
          r: 21,
          o: const Offset(23, 26),
        );
      case 'ikan-teri':
        _teri();
      case 'kornet':
        _kornet();
      case 'keju':
        _keju();
      case 'kacang-tanah':
        _kacang();
      // B. Sayur & buah utuh
      case 'tomat':
        _tomat();
      case 'wortel':
        _wortel();
      case 'terong':
        _terong();
      case 'timun':
        _timun();
      case 'labu-siam':
        _labuSiam();
      case 'kentang':
        _kentang();
      case 'ubi':
        _ubi();
      case 'jagung':
        _jagung();
      case 'cabai':
        _cabai();
      case 'pisang':
        _pisang();
      case 'jeruk-nipis':
        bentuk(BentukMakanan.irisan, _W.jeruk, _W.jerukKulit, r: 19);
      case 'jamur':
        bentuk(
          BentukMakanan.jamur,
          _W.jamur,
          _W.jamurTua,
          r: 19,
          o: const Offset(24, 23),
        );
      case 'brokoli':
        bentuk(
          BentukMakanan.brokoli,
          _W.daunTua,
          _W.daunGelap,
          r: 19,
          o: const Offset(24, 23),
        );
      case 'tauge':
        _tauge();
      case 'buncis':
        _buncis();
      // C. Daun
      case 'bayam':
        _bayam();
      case 'kangkung':
        _kangkung();
      case 'sawi-hijau':
        _sawi();
      case 'kol':
        _kol();
      case 'seledri':
        _seledri();
      case 'daun-bawang':
        _daunBawang();
      case 'daun-salam':
        _daunSalam();
      // D. Umbi bumbu
      case 'bawang-merah':
        _bawang(merah: true);
      case 'bawang-putih':
        _bawang(merah: false);
      // E. Kemasan
      case 'kecap-manis':
        // Botol ramping tinggi, label krem berpita kuning.
        _botol(
          lebarBadan: 16,
          leher: 8,
          warnaBadan: _W.kecap,
          warnaTutup: _W.cabai,
          warnaLabel: _W.labelKrem,
          gambarLabel: (l) {
            final pita = Rect.fromLTRB(l.left, l.top + 3, l.right, l.top + 6);
            c
              ..drawRect(pita, isi(_W.telurKuning))
              ..drawLine(pita.topLeft, pita.topRight, garis(_tinta, tg * 0.4))
              ..drawLine(
                pita.bottomLeft,
                pita.bottomRight,
                garis(_tinta, tg * 0.4),
              );
          },
        );
      case 'saus-tomat':
        _botol(
          lebarBadan: 22,
          warnaBadan: _W.sausTomat,
          warnaTutup: _W.piring,
          warnaLabel: _W.piring,
          gambarLabel: (l) {
            final o = l.center + const Offset(0, 0.4);
            c
              ..drawCircle(o, 3.2, isi(_W.tomat))
              ..drawCircle(o, 3.2, garis(_tinta, tg * 0.6))
              ..drawCircle(o + const Offset(0, -3.2), 1.1, isi(_W.daunTua));
          },
        );
      case 'saus-tiram':
        // Botol gemuk pendek, badan cokelat kemerahan, kipas cangkang.
        _botol(
          lebarBadan: 30,
          leher: 12,
          turun: 6,
          warnaBadan: _W.sausTiramBotol,
          warnaTutup: _W.wortel,
          warnaLabel: _W.labelKrem,
          gambarLabel: (l) {
            // Cangkang tiram: kipas setengah lingkaran.
            final pusat = Offset(l.center.dx, l.bottom - 1.4);
            final kipas = Rect.fromCircle(center: pusat, radius: 6);
            c
              ..drawArc(kipas, pi, pi, true, isi(_W.cangkang))
              ..drawArc(kipas, pi, pi, true, garis(_tinta, tg * 0.6));
            if (detail) {
              for (final sudut in [-2.45, -1.9, -1.25, -0.7]) {
                c.drawLine(
                  pusat,
                  pusat + Offset.fromDirection(sudut, 5),
                  garis(_W.labelKrem, tg * 0.45),
                );
              }
            }
          },
        );
      case 'minyak-goreng':
        _botol(
          lebarBadan: 24,
          warnaBadan: _W.telurKuning,
          warnaTutup: _W.daunTua,
          warnaLabel: _W.piring,
          gambarLabel: (l) =>
              tetes(Offset(l.center.dx, l.top + 1.6), 2.4, _W.telurKuning),
        );
      case 'susu-kental-manis':
        _kalengSusu();
      // F. Wadah & lainnya
      case 'garam':
        _pengocok(_W.garam, _tinta);
      case 'merica':
        _pengocok(_W.merica, _W.garam);
      case 'gula':
        _gula();
      case 'kaldu-bubuk':
        _kaldu();
      case 'tepung-terigu':
        _tepung();
      case 'santan':
        _santan();
      case 'margarin':
        _margarin();
      case 'meses':
        _meses();
      case 'gula-merah':
        _gulaMerah();
      case 'air':
        _air();
      case 'nasi':
        _nasi();
      case 'mie-instan':
        _mie();
      case 'bihun':
        _bihun();
      case 'roti-tawar':
        _roti();
      default:
        if (cadangan != null) {
          bentuk(
            BentukMakanan.generik,
            cadangan,
            Color.lerp(cadangan, _tinta, 0.3)!,
            r: 19,
            o: const Offset(23, 24),
          );
        }
    }
  }

  // -------------------------------------------------------------------------
  // A. Protein
  // -------------------------------------------------------------------------

  void _telur() {
    final j = Path()
      ..moveTo(24, 5)
      ..cubicTo(33, 5, 38.5, 21, 38.5, 29.5)
      ..cubicTo(38.5, 38, 32, 43, 24, 43)
      ..cubicTo(16, 43, 9.5, 38, 9.5, 29.5)
      ..cubicTo(9.5, 21, 15, 5, 24, 5)
      ..close();
    kontur(j, _W.telurPutih);
    if (detail) {
      c.drawArc(
        Rect.fromCircle(center: const Offset(21.5, 22), radius: 9),
        pi * 1.08,
        pi * 0.34,
        false,
        garis(_W.telurTepi, tg * 1.1),
      );
    }
  }

  void _tahu() {
    bentuk(BentukMakanan.kubus, _W.tahu, _W.tahuTua, r: 21);
    if (detail) {
      for (final (x, y) in [(18.5, 19.0), (27.0, 23.5), (20.5, 28.5)]) {
        c.drawCircle(Offset(x, y), 1.2, isi(_W.tahuTua));
      }
    }
  }

  void _teri() {
    putar(_pusat, _diag, () {
      for (final (dx, dy) in [(-2.0, -6.8), (2.0, 6.8)]) {
        kontur(
          Path()
            ..moveTo(dx - 11, dy)
            ..lineTo(dx - 18.5, dy - 5)
            ..lineTo(dx - 18.5, dy + 5)
            ..close(),
          _W.teriTua,
        );
        kontur(
          Path()..addOval(
            Rect.fromCenter(center: Offset(dx, dy), width: 27, height: 9.5),
          ),
          _W.teri,
        );
        if (detail) {
          c.drawArc(
            Rect.fromCircle(center: Offset(dx + 3, dy), radius: 4),
            -pi * 0.3,
            pi * 0.6,
            false,
            garis(_W.teriTua, tg * 0.6),
          );
        }
        // Mata tetap ada di non-detail.
        c.drawCircle(Offset(dx + 8.5, dy - 1), 1.5, isi(_tinta));
      }
    });
  }

  void _kornet() {
    // Kaleng kornet: trapesium tampak samping, atas lebih sempit.
    final badan = Path()
      ..moveTo(13.5, 10)
      ..lineTo(34.5, 10)
      ..lineTo(39.5, 42)
      ..lineTo(8.5, 42)
      ..close();
    final label = Path()
      ..moveTo(11.6, 18.5)
      ..lineTo(36.4, 18.5)
      ..lineTo(38.6, 34.5)
      ..lineTo(9.4, 34.5)
      ..close();
    c
      ..drawPath(badan, isi(_W.teri))
      ..drawPath(label, isi(_W.kornetTua))
      ..drawPath(label, garis(_tinta, tg * 0.6))
      ..drawLine(
        const Offset(13, 13.5),
        const Offset(35, 13.5),
        garis(_W.teriTua, tg * 0.7),
      )
      ..drawLine(
        const Offset(9.6, 38.5),
        const Offset(38.4, 38.5),
        garis(_W.teriTua, tg * 0.7),
      );
    // Sepotong daging kornet di label.
    final daging = RRect.fromRectAndRadius(
      Rect.fromCenter(center: const Offset(24, 26.5), width: 14, height: 9),
      const Radius.circular(2.5),
    );
    c
      ..drawRRect(daging, isi(_W.kornet))
      ..drawRRect(daging, garis(_tinta, tg * 0.6));
    if (detail) {
      final serat = garis(_W.kornetTua, tg * 0.5);
      for (final x in [20.0, 24.0, 28.0]) {
        c.drawLine(Offset(x - 1, 24), Offset(x + 1, 29), serat);
      }
    }
    c.drawPath(badan, garis(_tinta));
    if (detail) {
      // Kunci pembuka di samping atas.
      final kunci = garis(_tinta, tg * 0.7);
      c
        ..drawLine(const Offset(35, 12.5), const Offset(40.5, 9), kunci)
        ..drawCircle(const Offset(41.6, 8.2), 1.6, kunci);
    }
  }

  void _keju() {
    final baji = Path()
      ..moveTo(6, 39)
      ..lineTo(42, 39)
      ..lineTo(42, 10)
      ..close();
    c
      ..save()
      ..clipPath(baji)
      ..drawPath(baji, isi(_W.keju))
      ..drawRect(const Rect.fromLTRB(0, 34, 48, 48), isi(_W.kejuTua));
    if (detail) {
      for (final (x, y, r) in [
        (34.0, 27.0, 3.2),
        (38.0, 18.5, 2.0),
        (28.0, 31.0, 1.8),
      ]) {
        c.drawCircle(Offset(x, y), r, isi(_W.kejuTua));
      }
    }
    c
      ..restore()
      ..drawPath(baji, garis(_tinta));
  }

  void _kacang() {
    putar(const Offset(24, 24.5), _diag, () {
      p.gabung([
        (const Offset(-8, 0), 9.6),
        (const Offset(8.5, 0), 8.8),
      ], _W.kacang);
      if (detail) {
        for (final (x, y) in [
          (-12.0, -3.0),
          (-7.0, 3.5),
          (-5.0, -4.5),
          (-11.0, 4.0),
          (6.0, -3.5),
          (11.0, 2.5),
          (10.0, -4.0),
          (5.5, 4.0),
        ]) {
          c.drawCircle(Offset(x, y), 0.9, isi(_W.kacangTua));
        }
      }
    });
  }

  // -------------------------------------------------------------------------
  // B. Sayur & buah utuh
  // -------------------------------------------------------------------------

  void _tomat() {
    const o = Offset(24, 27);
    lingkar(o, 16.5, _W.tomat);
    if (detail) {
      c.drawArc(
        Rect.fromCircle(center: o, radius: 11.5),
        pi * 1.08,
        pi * 0.3,
        false,
        garis(_W.tomatDalam, tg * 1.1),
      );
    }
    // Kelopak bintang lima.
    const k = Offset(24, 12.5);
    final bintang = Path();
    for (var i = 0; i < 10; i++) {
      final sudut = -pi / 2 + i * pi / 5;
      final r = i.isEven ? 7.5 : 2.8;
      final t = k + Offset.fromDirection(sudut, r);
      i == 0 ? bintang.moveTo(t.dx, t.dy) : bintang.lineTo(t.dx, t.dy);
    }
    kontur(bintang..close(), _W.daunTua);
    batang(garisLurus(k, const Offset(25.5, 5.5)), _W.daunTua, 2.2);
  }

  void _wortel() {
    putar(_pusat, _diag, () {
      for (final sudut in [-0.55, 0.0, 0.55]) {
        putar(const Offset(11, 0), sudut, () {
          kontur(
            Path()
              ..moveTo(0, 0)
              ..quadraticBezierTo(5, -3.6, 10.5, 0)
              ..quadraticBezierTo(5, 3.6, 0, 0)
              ..close(),
            _W.daunTua,
          );
        });
      }
      kontur(
        Path()
          ..moveTo(-19, 0)
          ..lineTo(9, -7.2)
          ..quadraticBezierTo(14, -7.2, 14, -2.5)
          ..lineTo(14, 2.5)
          ..quadraticBezierTo(14, 7.2, 9, 7.2)
          ..close(),
        _W.wortel,
      );
      if (detail) {
        for (final (x, sisi, panjang) in [
          (-9.0, -1.0, 2.2),
          (-2.0, 1.0, 3.0),
          (4.5, -1.0, 3.2),
        ]) {
          final lebar = 7.2 * (x + 19) / 28;
          c.drawLine(
            Offset(x, sisi * lebar),
            Offset(x + 1.2, sisi * (lebar - panjang)),
            garis(_W.wortelTua, tg * 0.7),
          );
        }
      }
    });
  }

  void _terong() {
    putar(const Offset(23, 25), _diag, () {
      kontur(
        Path()
          ..moveTo(10, -4.5)
          ..cubicTo(4, -4.5, -2, -10, -10, -10)
          ..cubicTo(-17, -10, -20, -4, -19, 1)
          ..cubicTo(-18, 7, -12, 9, -6, 8)
          ..cubicTo(1, 7, 5, 4, 10, 4.5)
          ..close(),
        _W.terong,
      );
      if (detail) {
        c.drawPath(
          Path()
            ..moveTo(-14, 3.5)
            ..quadraticBezierTo(-8, 6.5, -1, 4.5),
          garis(_W.terongTua, tg * 0.8),
        );
      }
      batang(
        garisLurus(const Offset(14, 0), const Offset(20, -1.5)),
        _W.daunTua,
        2.6,
      );
      kontur(
        Path()
          ..moveTo(15, -5)
          ..quadraticBezierTo(18, 0, 15, 5)
          ..lineTo(7.5, 7)
          ..lineTo(10.5, 2.5)
          ..lineTo(5.5, 0)
          ..lineTo(10.5, -2.5)
          ..lineTo(7.5, -7)
          ..close(),
        _W.daunTua,
      );
    });
  }

  void _timun() {
    putar(_pusat, _diag, () {
      kontur(
        Path()..addRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset.zero, width: 38, height: 13),
            const Radius.circular(6.5),
          ),
        ),
        _W.timunKulit,
      );
      for (final (x0, x1, y) in [(-12.0, 11.0, -2.6), (-8.0, 13.0, 2.6)]) {
        c.drawLine(Offset(x0, y), Offset(x1, y), garis(_W.timun, tg * 0.8));
      }
      if (detail) {
        for (final (x, y) in [
          (-14.0, 0.0),
          (-3.0, 0.2),
          (8.0, -0.2),
          (15.0, 0.0),
        ]) {
          c.drawCircle(Offset(x, y), 0.8, isi(_W.timun));
        }
      }
    });
  }

  void _labuSiam() {
    batang(
      garisLurus(const Offset(24, 10), const Offset(25.5, 5)),
      _W.daunTua,
      2.6,
    );
    kontur(
      Path()
        ..moveTo(24, 9)
        ..cubicTo(30, 9, 31, 15, 33, 19)
        ..cubicTo(40, 24, 41, 33, 37, 38)
        ..cubicTo(33, 43, 26, 43, 24, 40)
        ..cubicTo(22, 43, 15, 43, 11, 38)
        ..cubicTo(7, 33, 8, 24, 15, 19)
        ..cubicTo(17, 15, 18, 9, 24, 9)
        ..close(),
      _W.labu,
    );
    c.drawPath(
      Path()
        ..moveTo(21, 15)
        ..quadraticBezierTo(15, 28, 19, 39.5)
        ..moveTo(27, 15)
        ..quadraticBezierTo(33, 28, 29, 39.5),
      garis(_W.labuTua, tg * 0.8),
    );
  }

  void _kentang() {
    p.gabung([
      (const Offset(18, 25.5), 11),
      (const Offset(29, 22.5), 11.5),
      (const Offset(32, 30), 8),
    ], _W.kentang);
    // Dua mata cekung, tetap ada di non-detail agar beda dari telur/roti.
    for (final o in const [Offset(17, 22.5), Offset(30.5, 27)]) {
      c
        ..drawArc(
          Rect.fromCircle(center: o, radius: 2.3),
          pi * 0.1,
          pi * 0.8,
          false,
          garis(_W.kentangTua, tg * 0.8),
        )
        ..drawCircle(o, 1.1, isi(_W.kentangTua));
    }
    if (detail) {
      for (final o in const [Offset(23, 30), Offset(27, 17), Offset(13, 28)]) {
        c.drawCircle(o, 0.6, isi(_W.kentangTua));
      }
    }
  }

  void _ubi() {
    putar(_pusat, _diag, () {
      final ekor = garis(_tinta, tg * 0.8);
      c
        ..drawLine(const Offset(-19, 1), const Offset(-22, 2), ekor)
        ..drawLine(const Offset(18.5, -1), const Offset(21.5, -2.5), ekor);
      kontur(
        Path()
          ..moveTo(-20, 1)
          ..cubicTo(-12, -11, 10, -11, 19, -1)
          ..cubicTo(10, 10, -12, 11, -20, 1)
          ..close(),
        _W.ubiKulit,
      );
      if (detail) {
        c.drawPath(
          Path()
            ..moveTo(-10, -3.5)
            ..quadraticBezierTo(-7, -4.8, -4, -4)
            ..moveTo(2, 3.5)
            ..quadraticBezierTo(5, 4.8, 8, 3.8)
            ..moveTo(4, -5)
            ..quadraticBezierTo(7, -5.6, 10, -4.4),
          garis(_W.ubiKulitTua, tg * 0.7),
        );
      }
    });
  }

  void _jagung() {
    putar(const Offset(25, 23), _diag, () {
      final tongkol = Path()
        ..moveTo(-14, -6.5)
        ..lineTo(12, -5.5)
        ..quadraticBezierTo(19, -4.5, 19, 0)
        ..quadraticBezierTo(19, 4.5, 12, 5.5)
        ..lineTo(-14, 6.5)
        ..close();
      c
        ..drawPath(tongkol, isi(_W.jagung))
        ..save()
        ..clipPath(tongkol);
      final butir = garis(_W.jagungTua, tg * 0.6);
      for (final x in detail ? [-8.0, -3.0, 2.0, 7.0, 12.0] : [-4.0, 5.0]) {
        c.drawLine(Offset(x, -8), Offset(x, 8), butir);
      }
      for (final y in detail ? [-2.4, 2.4] : [0.0]) {
        c.drawLine(Offset(-16, y), Offset(20, y), butir);
      }
      c
        ..restore()
        ..drawPath(tongkol, garis(_tinta));
      // Kelobot membungkus pangkal tongkol.
      batang(
        garisLurus(const Offset(-19, 0), const Offset(-22.5, 0.5)),
        _W.daunTua,
        3,
      );
      for (final arah in [-1.0, 1.0]) {
        kontur(
          Path()
            ..moveTo(-20, 0)
            ..quadraticBezierTo(-14, arah * 11.5, 1.5, arah * 9.5)
            ..quadraticBezierTo(-8, arah * 4, -20, 0)
            ..close(),
          _W.daunMuda,
        );
      }
    });
  }

  /// Cabai: tebal di pangkal (kanan atas), meruncing dan sedikit melengkung
  /// ke atas di ujung (kiri bawah), dengan kelopak topi dan tangkai.
  void _cabai() {
    putar(_pusat, _diag, () {
      batang(
        Path()
          ..moveTo(14, 0)
          ..quadraticBezierTo(19, 0, 20.5, -4.5),
        _W.daunTua,
        3,
      );
      kontur(
        Path()
          ..moveTo(11, -4.6)
          ..cubicTo(4, -4, -6, -1, -12, -1)
          ..quadraticBezierTo(-16.5, -1.2, -19.5, -4.5)
          ..quadraticBezierTo(-17.5, 2.5, -12, 3.4)
          ..cubicTo(-5, 4.8, 4, 6, 11, 4.6)
          ..quadraticBezierTo(13.5, 0, 11, -4.6)
          ..close(),
        _W.cabai,
      );
      if (detail) {
        c.drawPath(
          Path()
            ..moveTo(6, -2)
            ..quadraticBezierTo(0, -0.6, -6, 0.6),
          garis(_W.tomatDalam, tg * 0.8),
        );
      }
      kontur(
        Path()
          ..moveTo(8.5, -5.6)
          ..quadraticBezierTo(12.5, -6.8, 15, -3.5)
          ..lineTo(15, 3.5)
          ..quadraticBezierTo(12.5, 6.8, 8.5, 5.6)
          ..lineTo(10.8, 2.6)
          ..lineTo(8, 0)
          ..lineTo(10.8, -2.6)
          ..close(),
        _W.daunTua,
      );
    });
  }

  void _pisang() {
    putar(const Offset(24, 25), _diag, () {
      batang(
        garisLurus(const Offset(15.5, -6.5), const Offset(20, -9.5)),
        _W.pisangTua,
        3,
      );
      kontur(
        Path()
          ..moveTo(-17, -6.5)
          ..quadraticBezierTo(0, 17, 17, -7)
          ..quadraticBezierTo(0, -1, -17, -6.5)
          ..close(),
        _W.pisang,
      );
      if (detail) {
        c.drawPath(
          Path()
            ..moveTo(-12, -3.5)
            ..quadraticBezierTo(0, 9, 12, -3.8),
          garis(_W.pisangTua, tg * 0.7),
        );
      }
      // Ujung gelap.
      c
        ..drawCircle(const Offset(-16.5, -6.5), 1.9, isi(_tinta))
        ..drawCircle(const Offset(-16.5, -6.5), 1.1, isi(_W.pisangTua));
    });
  }

  void _tauge() {
    putar(_pusat, _diag, () {
      for (final (dx, dy) in [(-2.0, -9.0), (1.5, 0.0), (-1.0, 9.0)]) {
        // Batang huruf J: lurus lalu melengkung di ujung bawah.
        final ekor = Offset(dx - 12.5, dy + 5);
        batang(
          Path()
            ..moveTo(dx + 13, dy)
            ..cubicTo(dx + 2, dy - 1.2, dx - 12, dy - 1.2, dx - 15, dy + 2.2)
            ..quadraticBezierTo(dx - 16, dy + 4.6, ekor.dx, ekor.dy),
          _W.tauge,
          4,
        );
        if (detail) {
          final akar = garis(_tinta, tg * 0.45);
          c
            ..drawLine(ekor, ekor + const Offset(1.5, 2.6), akar)
            ..drawLine(ekor, ekor + const Offset(2.8, 1), akar);
        }
        lingkar(Offset(dx + 14.5, dy), 3.8, _W.jagung);
      }
    });
  }

  void _buncis() {
    putar(_pusat, _diag, () {
      for (final (dy, belok) in [(-5.3, -0.06), (5.3, 0.06)]) {
        putar(Offset(0, dy), belok, () {
          batang(
            garisLurus(const Offset(17, 0), const Offset(21, -1.5)),
            _W.daunTua,
            2.4,
          );
          kontur(
            Path()
              ..moveTo(-19.5, 1.5)
              ..quadraticBezierTo(-17, -4.2, -11, -4.2)
              ..lineTo(14, -4.2)
              ..quadraticBezierTo(18.5, -4.2, 18.5, 0)
              ..quadraticBezierTo(18.5, 4.2, 14, 4.2)
              ..lineTo(-11, 4.2)
              ..quadraticBezierTo(-16, 4.2, -19.5, 1.5)
              ..close(),
            _W.daun,
          );
          if (detail) {
            for (final x in [-9.0, -2.5, 4.0, 10.5]) {
              c.drawArc(
                Rect.fromCircle(center: Offset(x, 0.6), radius: 2.6),
                pi * 1.15,
                pi * 0.7,
                false,
                garis(_W.daunTua, tg * 0.6),
              );
            }
          }
        });
      }
    });
  }

  // -------------------------------------------------------------------------
  // C. Daun
  // -------------------------------------------------------------------------

  /// Daun pustaka sampul di titik [o] (koordinat lokal pemanggil).
  void _daun(
    Offset o,
    double r,
    Color w,
    Color tua, {
    double rasio = 0.5,
    double sudut = 0,
  }) => bentuk(
    BentukMakanan.daun,
    w,
    tua,
    r: r,
    o: o,
    sudut: sudut,
    rasio: rasio,
  );

  void _bayam() {
    putar(_pusat, _diag, () {
      batang(
        garisLurus(const Offset(-21, 0), const Offset(-12, 0)),
        _W.daunMuda,
        2.4,
      );
      _daun(const Offset(3, 0), 16, _W.daun, _W.daunTua, rasio: 0.9);
    });
  }

  /// Daun panah (kangkung): pangkal bercuping, ujung runcing ke +x.
  void _daunPanah(Offset pangkal, double sudut, double panjang, double lebar) {
    putar(pangkal, sudut, () {
      final w = lebar / 2;
      kontur(
        Path()
          ..moveTo(panjang, 0)
          ..quadraticBezierTo(panjang * 0.4, -w * 1.25, -2.5, -w)
          ..lineTo(2, 0)
          ..lineTo(-2.5, w)
          ..quadraticBezierTo(panjang * 0.4, w * 1.25, panjang, 0)
          ..close(),
        _W.daunTua,
      );
      if (detail) {
        c.drawLine(
          const Offset(2, 0),
          Offset(panjang - 2.5, 0),
          garis(_W.daunGelap, tg * 0.5),
        );
      }
    });
  }

  void _kangkung() {
    putar(_pusat, _diag, () {
      // Batang berongga: ujung potongnya tampak sebagai lubang.
      batang(
        garisLurus(const Offset(-19, 0), const Offset(5, 0)),
        _W.daunMuda,
        4,
      );
      _daunPanah(const Offset(-10, -1), -0.85, 11, 7);
      _daunPanah(const Offset(-3, 1), 0.8, 11, 7);
      _daunPanah(const Offset(4, 0), 0, 15, 8);
      lingkar(const Offset(-19.5, 0), 2.6, _W.daunMuda);
      c.drawCircle(const Offset(-19.5, 0), 1.1, isi(_W.daunTua));
    });
  }

  void _sawi() {
    putar(_pusat, _diag, () {
      _daun(const Offset(6, 0), 14, _W.daunMuda, _W.daunTua, rasio: 0.85);
      kontur(
        Path()..addRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTRB(-21, -4.5, -1, 4.5),
            const Radius.circular(4.5),
          ),
        ),
        _W.batangPucat,
      );
      c.drawLine(
        const Offset(-3, 0),
        const Offset(12, 0),
        garis(_W.batangPucat, 2.2),
      );
    });
  }

  void _kol() {
    lingkar(_pusat, 18.5, _W.daunPucat);
    final lapis = garis(_W.daunPucatTua, tg * 0.9);
    c
      ..drawArc(
        Rect.fromCircle(center: _pusat, radius: 14),
        pi * 1.25,
        pi * 0.85,
        false,
        lapis,
      )
      ..drawArc(
        Rect.fromCircle(center: const Offset(26, 25.5), radius: 9.5),
        pi * 0.55,
        pi * 1.3,
        false,
        lapis,
      )
      ..drawArc(
        Rect.fromCircle(center: const Offset(24.5, 24.5), radius: 4.5),
        pi * 1.6,
        pi * 1.3,
        false,
        lapis,
      );
    if (detail) {
      final urat = garis(_W.daunPucatTua, tg * 0.55);
      for (final sudut in [0.35, 1.9, 2.9]) {
        final arah = Offset.fromDirection(sudut);
        c.drawLine(_pusat + arah * 10.5, _pusat + arah * 16, urat);
      }
    }
  }

  void _seledri() {
    putar(_pusat, _diag, () {
      const ujung = Offset(5, 0);
      batang(garisLurus(const Offset(-20, 0), ujung), _W.daun, 4);
      for (final sudut in [-0.85, 0.0, 0.85]) {
        putar(ujung + Offset.fromDirection(sudut, 1.5), sudut, () {
          // Daun kecil bergerigi tiga cuping.
          const l = 12.5, w = 4.6;
          final j = Path()..moveTo(0, 0);
          for (final (x, y) in const [
            (0.2, -0.7),
            (0.36, -0.45),
            (0.55, -1.0),
            (0.68, -0.55),
            (0.86, -0.75),
            (1.0, 0.0),
            (0.86, 0.75),
            (0.68, 0.55),
            (0.55, 1.0),
            (0.36, 0.45),
            (0.2, 0.7),
          ]) {
            j.lineTo(l * x, w * y);
          }
          kontur(j..close(), _W.daunTua);
          if (detail) {
            c.drawLine(
              const Offset(1, 0),
              const Offset(l - 2.5, 0),
              garis(_W.daunGelap, tg * 0.5),
            );
          }
        });
      }
    });
  }

  void _daunBawang() {
    putar(_pusat, _diag, () {
      // Helai cabang di belakang.
      putar(const Offset(-5, -1), -0.38, () {
        kontur(
          Path()..addRRect(
            RRect.fromRectAndRadius(
              const Rect.fromLTRB(0, -3.2, 21, 3.2),
              const Radius.circular(3.2),
            ),
          ),
          _W.daun,
        );
      });
      final tabung = Path()
        ..addRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTRB(-18, -3.8, 20, 3.8),
            const Radius.circular(3.8),
          ),
        );
      c
        ..save()
        ..clipPath(tabung)
        ..drawPath(tabung, isi(_W.daun))
        ..drawRect(const Rect.fromLTRB(-30, -10, -6, 10), isi(_W.bawangPutih))
        ..restore()
        ..drawLine(
          const Offset(-6, -3.8),
          const Offset(-6, 3.8),
          garis(_W.daunTua, tg * 0.7),
        )
        ..drawPath(tabung, garis(_tinta));
      if (detail) {
        final akar = garis(_tinta, tg * 0.55);
        for (final dy in [-2.4, 0.0, 2.4]) {
          c.drawLine(Offset(-18, dy * 0.6), Offset(-21.5, dy), akar);
        }
      }
    });
  }

  void _daunSalam() {
    putar(_pusat, _diag, () {
      batang(
        garisLurus(const Offset(-21, 0), const Offset(-14, 0)),
        _W.daunTua,
        2.6,
      );
      // Daun lonjong runcing; urat hanya saat detail.
      const r = 17.0, lebar = 13.0;
      putar(const Offset(2.5, 0), 0, () {
        kontur(
          Path()
            ..moveTo(-r, 0)
            ..quadraticBezierTo(-r * 0.1, -lebar, r, 0)
            ..quadraticBezierTo(-r * 0.1, lebar, -r, 0)
            ..close(),
          _W.daunGelap,
        );
        if (detail) {
          final urat = garis(_W.daunTua, tg * 0.7);
          c.drawLine(
            const Offset(-r * 0.8, 0),
            const Offset(r * 0.75, 0),
            urat,
          );
          for (final x in [-0.4, 0.0, 0.4]) {
            for (final arah in [-1, 1]) {
              c.drawLine(
                Offset(r * x, 0),
                Offset(r * (x + 0.2), arah * lebar * 0.3),
                garis(_W.daunTua, tg * 0.5),
              );
            }
          }
        }
      });
    });
  }

  // -------------------------------------------------------------------------
  // D. Umbi bumbu
  // -------------------------------------------------------------------------

  void _bawang({required bool merah}) {
    final akar = garis(_tinta, tg * 0.7);
    for (final dx in [-3.0, 0.0, 3.0]) {
      c.drawLine(Offset(24 + dx * 0.5, 41), Offset(24 + dx, 44), akar);
    }
    final Path umbi;
    if (merah) {
      umbi = Path()
        ..moveTo(24, 8)
        ..cubicTo(27, 15, 40, 20, 39.5, 31)
        ..cubicTo(39, 40, 31, 42, 24, 42)
        ..cubicTo(17, 42, 9, 40, 8.5, 31)
        ..cubicTo(8, 20, 21, 15, 24, 8)
        ..close();
    } else {
      umbi = Path()
        ..moveTo(24, 8)
        ..cubicTo(26, 14, 42, 18, 41.5, 30)
        ..cubicTo(41, 40, 32, 42, 24, 42)
        ..cubicTo(16, 42, 7, 40, 6.5, 30)
        ..cubicTo(6, 18, 22, 14, 24, 8)
        ..close();
    }
    kontur(umbi, merah ? _W.bawangMerah : _W.bawangPutih);
    final siung = merah
        ? (Path()
            ..moveTo(24, 12)
            ..quadraticBezierTo(15, 27, 20, 41)
            ..moveTo(24, 12)
            ..quadraticBezierTo(33, 27, 28, 41))
        : (Path()
            ..moveTo(24, 12)
            ..quadraticBezierTo(11, 23, 14, 38.5)
            ..moveTo(24, 12)
            ..quadraticBezierTo(18.5, 27, 20.5, 41.5)
            ..moveTo(24, 12)
            ..quadraticBezierTo(29.5, 27, 27.5, 41.5)
            ..moveTo(24, 12)
            ..quadraticBezierTo(37, 23, 34, 38.5));
    c.drawPath(
      siung,
      garis(merah ? _W.bawangMerahTua : _W.bawangPutihTua, tg * 0.8),
    );
    // Pucuk kering.
    batang(
      garisLurus(const Offset(24, 9), const Offset(25.5, 4.5)),
      _W.bawangAkar,
      2.4,
    );
  }

  // -------------------------------------------------------------------------
  // E. Kemasan
  // -------------------------------------------------------------------------

  /// Template botol bersama: tutup y 6–15, leher y 15–19, bahu melengkung,
  /// badan sampai y 43, label y 28–37. Botol pendek menurunkan tutup, leher,
  /// dan bahu sejauh [turun]; dasar dan label tetap di tempatnya.
  void _botol({
    required double lebarBadan,
    required Color warnaBadan,
    required Color warnaTutup,
    required Color warnaLabel,
    double turun = 0,
    double leher = 10,
    void Function(Rect label)? gambarLabel,
  }) {
    const cx = 24.0;
    final t = turun;
    final xl = cx - lebarBadan / 2, xr = cx + lebarBadan / 2;
    final badan = Path()
      ..moveTo(cx - leher / 2, 14 + t)
      ..lineTo(cx - leher / 2, 19 + t)
      ..quadraticBezierTo(xl, 20 + t, xl, min(26.5 + t, 28))
      ..lineTo(xl, 40)
      ..quadraticBezierTo(xl, 43, xl + 3, 43)
      ..lineTo(xr - 3, 43)
      ..quadraticBezierTo(xr, 43, xr, 40)
      ..lineTo(xr, min(26.5 + t, 28))
      ..quadraticBezierTo(xr, 20 + t, cx + leher / 2, 19 + t)
      ..lineTo(cx + leher / 2, 14 + t)
      ..close();
    final label = Rect.fromLTRB(xl, 28, xr, 37);
    final tepiLabel = garis(_tinta, tg * 0.6);
    c
      ..drawPath(badan, isi(warnaBadan))
      ..drawRect(label, isi(warnaLabel))
      ..drawLine(label.topLeft, label.topRight, tepiLabel)
      ..drawLine(label.bottomLeft, label.bottomRight, tepiLabel);
    gambarLabel?.call(label);
    c.drawPath(badan, garis(_tinta));
    final lebarTutup = leher + 2;
    kontur(
      Path()..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(
            cx - lebarTutup / 2,
            6 + t,
            cx + lebarTutup / 2,
            15 + t,
          ),
          const Radius.circular(2),
        ),
      ),
      warnaTutup,
    );
    if (detail) {
      // Gerigi tutup.
      for (final x in [cx - lebarTutup / 4, cx, cx + lebarTutup / 4]) {
        c.drawLine(
          Offset(x, 8.5 + t),
          Offset(x, 12.5 + t),
          garis(_tinta, tg * 0.4),
        );
      }
    }
  }

  void _kalengSusu() {
    const badan = Rect.fromLTRB(9, 16, 39, 40);
    c.drawRect(badan, isi(_W.susu));
    const label = Rect.fromLTRB(9, 22, 39, 34);
    final tepiLabel = garis(_tinta, tg * 0.6);
    c
      ..drawRect(label, isi(_W.susuLabel))
      ..drawLine(label.topLeft, label.topRight, tepiLabel)
      ..drawLine(label.bottomLeft, label.bottomRight, tepiLabel);
    tetes(Offset(label.center.dx, label.top + 1.4), 3.6, _W.susu);
    c.drawRect(badan, garis(_tinta));
    for (final (atas, bawah) in [(13.0, 17.5), (38.5, 43.0)]) {
      kontur(
        Path()..addRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTRB(7.5, atas, 40.5, bawah),
            const Radius.circular(2),
          ),
        ),
        _W.teri,
      );
    }
  }

  // -------------------------------------------------------------------------
  // F. Wadah & lainnya
  // -------------------------------------------------------------------------

  /// Pengocok garam/merica: badan berwarna, tutup kubah abu berlubang tiga.
  void _pengocok(Color badan, Color lubang) {
    kontur(
      Path()
        ..moveTo(14, 19)
        ..lineTo(34, 19)
        ..lineTo(35.5, 40)
        ..quadraticBezierTo(35.7, 43, 32.5, 43)
        ..lineTo(15.5, 43)
        ..quadraticBezierTo(12.3, 43, 12.5, 40)
        ..close(),
      badan,
    );
    kontur(
      Path()
        ..moveTo(12.5, 21)
        ..lineTo(12.5, 17.5)
        ..arcToPoint(
          const Offset(35.5, 17.5),
          radius: const Radius.elliptical(11.5, 9.5),
        )
        ..lineTo(35.5, 21)
        ..close(),
      _W.garamTutup,
    );
    if (detail) {
      for (final (x, y) in [(19.0, 14.0), (24.0, 11.5), (29.0, 14.0)]) {
        c.drawCircle(Offset(x, y), 1.4, isi(lubang));
      }
    }
  }

  void _gula() {
    for (final (x, y, sudut) in [
      (16.5, 34.5, -0.08),
      (31.5, 34.5, 0.06),
      (24.0, 20.5, 0.14),
    ]) {
      bentuk(
        BentukMakanan.kubus,
        _W.gulaPasir,
        _W.gulaPasirTua,
        r: 9,
        o: Offset(x, y),
        sudut: sudut,
      );
    }
  }

  void _kaldu() {
    const kiri = 9.0, kanan = 39.0, gigi = 6;
    const lebarGigi = (kanan - kiri) / gigi;
    final j = Path()..moveTo(kiri, 9.5);
    for (var i = 0; i < gigi; i++) {
      final x = kiri + i * lebarGigi;
      j
        ..lineTo(x + lebarGigi / 2, 6.5)
        ..lineTo(x + lebarGigi, 9.5);
    }
    j.lineTo(kanan, 38.5);
    for (var i = 0; i < gigi; i++) {
      final x = kanan - i * lebarGigi;
      j
        ..lineTo(x - lebarGigi / 2, 41.5)
        ..lineTo(x - lebarGigi, 38.5);
    }
    kontur(j..close(), _W.kaldu);
    if (detail) {
      final segel = garis(_W.kalduTua, tg * 0.7);
      c
        ..drawLine(
          const Offset(kiri + 1, 12.5),
          const Offset(kanan - 1, 12.5),
          segel,
        )
        ..drawLine(
          const Offset(kiri + 1, 35.5),
          const Offset(kanan - 1, 35.5),
          segel,
        );
    }
    bentuk(
      BentukMakanan.kubus,
      _W.mie,
      _W.mieTua,
      r: 8,
      o: const Offset(24, 24),
      sudut: 0.18,
    );
  }

  void _tepung() {
    final karung = Path()
      ..moveTo(18, 15)
      ..cubicTo(10, 19, 8, 28, 8.5, 36)
      ..quadraticBezierTo(9, 43, 16, 43)
      ..lineTo(32, 43)
      ..quadraticBezierTo(39, 43, 39.5, 36)
      ..cubicTo(40, 28, 38, 19, 30, 15)
      ..close();
    final jumbai = Path()
      ..moveTo(18.5, 15.5)
      ..lineTo(15, 7)
      ..lineTo(20, 9.5)
      ..lineTo(24, 5.5)
      ..lineTo(28, 9.5)
      ..lineTo(33, 7)
      ..lineTo(29.5, 15.5)
      ..close();
    kontur(jumbai, _W.karung);
    kontur(karung, _W.karung);
    batang(
      garisLurus(const Offset(17.5, 15.5), const Offset(30.5, 15.5)),
      _W.karungTua,
      2.4,
    );
    // Label gandum.
    final tua = _W.karungTua;
    c.drawLine(
      const Offset(24, 38),
      const Offset(24, 24),
      garis(tua, tg * 0.8),
    );
    for (final (x, y, sudut) in [
      (24.0, 22.5, 0.0),
      (21.6, 26.0, -0.55),
      (26.4, 26.0, 0.55),
      (21.6, 30.0, -0.55),
      (26.4, 30.0, 0.55),
      if (detail) (21.6, 34.0, -0.55),
      if (detail) (26.4, 34.0, 0.55),
    ]) {
      putar(Offset(x, y), sudut, () {
        c.drawOval(
          Rect.fromCenter(center: Offset.zero, width: 2.6, height: 4),
          isi(tua),
        );
      });
    }
  }

  void _santan() {
    // Kotak karton santan tampak depan (flat), senada dengan kaleng susu
    // dan sachet kaldu: badan putih susu, pita kelapaKulit, gambar setengah
    // kelapa, tutup ulir kecil di atas.
    kontur(
      Path()..addRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTRB(20.5, 5.5, 27.5, 11),
          const Radius.circular(1.2),
        ),
      ),
      _W.daunTua,
    );
    if (detail) {
      for (final x in [22.8, 25.2]) {
        c.drawLine(Offset(x, 7), Offset(x, 9.5), garis(_tinta, tg * 0.4));
      }
    }
    final badan = Path()
      ..moveTo(15.5, 10)
      ..lineTo(32.5, 10)
      ..lineTo(37, 15)
      ..lineTo(37, 41)
      ..quadraticBezierTo(37, 43, 35, 43)
      ..lineTo(13, 43)
      ..quadraticBezierTo(11, 43, 11, 41)
      ..lineTo(11, 15)
      ..close();
    c
      ..drawPath(badan, isi(_W.susu))
      ..save()
      ..clipPath(badan)
      ..drawRect(const Rect.fromLTRB(0, 17, 48, 22), isi(_W.kelapaKulit))
      ..drawRect(const Rect.fromLTRB(0, 39, 48, 48), isi(_W.kelapaKulit))
      ..restore();
    final tepi = garis(_tinta, tg * 0.6);
    c
      ..drawLine(const Offset(11, 15), const Offset(37, 15), tepi)
      ..drawLine(const Offset(11, 17), const Offset(37, 17), tepi)
      ..drawLine(const Offset(11, 22), const Offset(37, 22), tepi)
      ..drawLine(const Offset(11, 39), const Offset(37, 39), tepi);
    // Setengah kelapa: tempurung dan daging putih.
    const pusat = Offset(24, 28.5);
    final tempurung = Rect.fromCircle(center: pusat, radius: 8);
    c
      ..drawArc(tempurung, 0, pi, true, isi(_W.kelapaKulit))
      ..drawArc(tempurung, 0, pi, true, garis(_tinta, tg * 0.7))
      ..drawArc(
        Rect.fromCircle(center: pusat, radius: 5.6),
        0,
        pi,
        true,
        isi(_W.kelapa),
      );
    c.drawPath(badan, garis(_tinta));
  }

  void _margarin() {
    kontur(
      Path()
        ..moveTo(9, 21)
        ..lineTo(39, 21)
        ..lineTo(36.5, 41)
        ..quadraticBezierTo(36, 43, 34, 43)
        ..lineTo(14, 43)
        ..quadraticBezierTo(12, 43, 11.5, 41)
        ..close(),
      _W.margarin,
    );
    if (detail) {
      final label = garis(_W.margarinTua, tg * 0.7);
      c
        ..drawLine(const Offset(14, 29), const Offset(34, 29), label)
        ..drawLine(const Offset(15, 35), const Offset(33, 35), label);
    }
    kontur(
      Path()..addRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTRB(7, 14, 41, 22),
          const Radius.circular(3),
        ),
      ),
      _W.margarinTua,
    );
  }

  void _meses() {
    final badan = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTRB(10, 15, 38, 43),
          const Radius.circular(5),
        ),
      );
    final isiToples = Path()
      ..moveTo(8, 25)
      ..quadraticBezierTo(17, 20, 24, 24.5)
      ..quadraticBezierTo(31, 29, 40, 23.5)
      ..lineTo(40, 45)
      ..lineTo(8, 45)
      ..close();
    c
      ..drawPath(badan, isi(_W.toples))
      ..save()
      ..clipPath(badan)
      ..drawPath(isiToples, isi(_W.meses));
    // Butir meses di atas tumpukan dan di dalamnya.
    for (final (x, y, sudut) in [
      (16.0, 19.5, 0.5),
      (28.0, 21.0, -0.7),
      (34.0, 19.0, 0.2),
    ]) {
      final o = Offset(x, y);
      c.drawLine(o, o + Offset.fromDirection(sudut, 3), garis(_W.meses, 1.8));
    }
    if (detail) {
      final terang = garis(_W.gulaMerah, 1.4);
      for (final (x, y, sudut) in [
        (14.0, 31.0, 0.4),
        (21.0, 36.0, -0.6),
        (28.0, 32.0, 1.2),
        (33.0, 38.0, 0.1),
        (17.0, 40.0, -1.1),
        (25.0, 28.0, 0.0),
      ]) {
        final o = Offset(x, y);
        c.drawLine(o, o + Offset.fromDirection(sudut, 2.6), terang);
      }
    }
    c
      ..restore()
      ..drawPath(badan, garis(_tinta));
    kontur(
      Path()..addRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTRB(13, 8, 35, 16),
          const Radius.circular(2.5),
        ),
      ),
      _W.tutupToples,
    );
  }

  void _gulaMerah() {
    final batok = Path()
      ..moveTo(6, 37)
      ..cubicTo(6, 20, 14, 11, 24, 11)
      ..cubicTo(34, 11, 42, 20, 42, 37)
      ..quadraticBezierTo(42, 40, 39, 40)
      ..lineTo(9, 40)
      ..quadraticBezierTo(6, 40, 6, 37)
      ..close();
    c
      ..drawPath(batok, isi(_W.gulaMerah))
      ..save()
      ..clipPath(batok);
    final alur = garis(_W.gulaMerahTua, tg * 0.8);
    for (final y in [if (detail) 17.0, 24.0, 31.5]) {
      c.drawPath(
        Path()
          ..moveTo(0, y)
          ..quadraticBezierTo(24, y + 5, 48, y),
        alur,
      );
    }
    c
      ..restore()
      ..drawPath(batok, garis(_tinta));
  }

  void _air() {
    kontur(
      Path()
        ..moveTo(24, 5)
        ..cubicTo(26, 12, 37, 21, 37, 30)
        ..cubicTo(37, 38, 31, 43, 24, 43)
        ..cubicTo(17, 43, 11, 38, 11, 30)
        ..cubicTo(11, 21, 22, 12, 24, 5)
        ..close(),
      _W.air,
    );
    c.drawArc(
      Rect.fromCircle(center: const Offset(24, 30), radius: 8.5),
      pi * 0.08,
      pi * 0.42,
      false,
      garis(_W.airTua, tg),
    );
    if (detail) {
      c.drawArc(
        Rect.fromCircle(center: const Offset(24, 30), radius: 7.5),
        pi * 1.05,
        pi * 0.3,
        false,
        garis(_W.piring, tg),
      );
    }
  }

  void _nasi() {
    p.gabung([
      (const Offset(24, 22), 11.5),
      (const Offset(14.5, 25.5), 7),
      (const Offset(33.5, 25.5), 7),
      (const Offset(18.5, 17.5), 6.5),
      (const Offset(29.5, 17.5), 6.5),
    ], _W.nasi);
    if (detail) {
      final butir = garis(_W.nasiTua, tg * 0.7);
      for (final (x, y, sudut) in [
        (18.0, 16.0, 0.4),
        (25.0, 13.5, -0.3),
        (30.5, 18.0, 0.9),
        (21.0, 21.5, -0.8),
        (14.0, 23.0, 0.2),
        (33.5, 23.5, -0.4),
      ]) {
        final o = Offset(x, y);
        c.drawLine(o, o + Offset.fromDirection(sudut, 2.2), butir);
      }
    }
    kontur(
      Path()..addRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTRB(17, 39, 31, 43.5),
          const Radius.circular(1.5),
        ),
      ),
      _W.piring,
    );
    final mangkuk = Path()
      ..moveTo(5, 26)
      ..lineTo(43, 26)
      ..cubicTo(43, 36, 35, 41, 24, 41)
      ..cubicTo(13, 41, 5, 36, 5, 26)
      ..close();
    c
      ..drawPath(mangkuk, isi(_W.piring))
      ..save()
      ..clipPath(mangkuk)
      ..drawLine(
        const Offset(0, 31),
        const Offset(48, 31),
        garis(_W.piringBibir, 2.6),
      )
      ..restore()
      ..drawPath(mangkuk, garis(_tinta));
  }

  void _mie() {
    final blok = RRect.fromRectAndRadius(
      const Rect.fromLTRB(6, 10, 42, 38),
      const Radius.circular(4),
    );
    kontur(Path()..addRRect(blok), _W.mie);
    final keriting = garis(_W.mieTua, tg * 0.8);
    for (final y in detail ? [15.0, 20.5, 26.0, 31.5] : [16.5, 24.0, 31.5]) {
      final j = Path()..moveTo(9.5, y);
      for (var x = 9.5, i = 0; x < 38; x += 3, i++) {
        j.lineTo(x + 3, y + (i.isEven ? -1.8 : 1.8));
      }
      c.drawPath(j, keriting);
    }
  }

  void _bihun() {
    // Ikatan bihun tampak samping, miring diagonal: helai TIPIS sejajar
    // (mie = blok kotak zig-zag), diikat dua tali di sepertiga atas dan
    // bawah, kedua ujungnya sedikit mekar.
    putar(_pusat, _diag, () {
      final ikat = Path()
        ..moveTo(-20, -7.5)
        ..quadraticBezierTo(0, -3.6, 20, -7.5)
        ..quadraticBezierTo(21.6, 0, 20, 7.5)
        ..quadraticBezierTo(0, 3.6, -20, 7.5)
        ..quadraticBezierTo(-21.6, 0, -20, -7.5)
        ..close();
      c
        ..drawPath(ikat, isi(_W.bihun))
        ..save()
        ..clipPath(ikat);
      final n = detail ? 8 : 4;
      final helai = garis(_W.bihunTua, tg * (detail ? 0.4 : 0.5));
      for (var i = 1; i < n; i++) {
        final t = -1 + i * 2 / n;
        c.drawPath(
          Path()
            ..moveTo(-23, t * 8)
            ..quadraticBezierTo(0, t * 3.6, 23, t * 8),
          helai,
        );
      }
      c
        ..restore()
        ..drawPath(ikat, garis(_tinta));
      for (final x in [-7.0, 7.0]) {
        batang(garisLurus(Offset(x, -5.4), Offset(x, 5.4)), _W.bihunTua, 2);
      }
    });
  }

  void _roti() {
    Path lembar(double kurang) => Path.combine(
      PathOperation.union,
      Path()..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(9 + kurang, 17, 39 - kurang, 42 - kurang),
          Radius.circular(max(1, 3 - kurang / 2)),
        ),
      ),
      Path()
        ..addOval(Rect.fromLTRB(6 + kurang, 7 + kurang, 26, 27 - kurang))
        ..addOval(Rect.fromLTRB(22, 7 + kurang, 42 - kurang, 27 - kurang)),
    );
    kontur(lembar(0), _W.rotiKulit);
    c.drawPath(lembar(3.4), isi(_W.roti));
    if (detail) {
      final pori = isi(_W.rotiKulit.withValues(alpha: 0.45));
      for (final (x, y) in [
        (17.0, 20.0),
        (29.0, 18.0),
        (22.0, 29.0),
        (31.0, 33.0),
        (16.0, 35.0),
      ]) {
        c.drawCircle(Offset(x, y), 0.9, pori);
      }
    }
  }
}
