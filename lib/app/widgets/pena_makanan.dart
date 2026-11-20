import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import '../theme/app_colors.dart';
import '../theme/app_warna_makanan.dart';

typedef _W = WarnaMakanan;

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

  // Bentuk olahan untuk sampul khusus (sampul_khusus.dart).

  /// Potongan korek api / batang kecil (orek, kering tempe, wortel korek).
  /// Tebal = 2 × r × `rasio`.
  batang,

  /// Lembar lebar tipis bergelombang berbalut tepung (mendoan); warnaTua =
  /// warna isi yang mengintip.
  lembarTepung,

  /// Bulatan pipih keemasan bertepi lebih gelap, berbintik hijau.
  perkedel,

  /// Helai-helai serat tipis bergerombol (ayam suwir).
  suwir,

  /// Gumpalan telur acak tak beraturan.
  orakArik,

  /// Udang melengkung berbalut tepung dengan ekor merah mencuat.
  udangTepung,

  /// Potongan ayam bertepung kasar bergerigi dengan ujung tulang.
  ayamTepung,

  /// Pisang memanjang sedikit melengkung, berbalut tepung keemasan.
  pisangGoreng,

  /// Gorengan tak beraturan dengan butir jagung menyembul.
  gorenganJagung,

  /// Potongan oval miring (sosis, buncis iris serong); warna = isi,
  /// warnaTua = kulit, tinggi = 2 × r × `rasio`.
  irisanMiring,

  /// Batang kangkung berongga (tampak lubang di ujung potong) dengan daun
  /// ramping; warna = batang, warnaTua = daun.
  batangKangkung,

  /// Pita-pita telur kocok di kuah.
  seratTelur,

  /// Butir kecil acak (bawang goreng, keju parut, meses). `rasio` ≤ 0,3 =
  /// helai pendek, selain itu butir bulat.
  taburan,

  /// Kerupuk bulat bergelombang.
  kerupuk,

  /// Potongan cakwe: dua batang adonan goreng berdempet.
  cakwe,

  /// Mie/bihun goreng dengan helai terlihat. `rasio` < 0,4 = helai tipis.
  mieGoreng,

  /// Kubus tahu berkulit goreng keemasan; sebagian terpotong sehingga sisi
  /// dalam putihnya terlihat.
  tahuGoreng,

  /// Ikan teri kecil: badan ramping, ekor bercabang.
  ikanTeri,

  /// Irisan ubi berbalut tepung: daging oranye (warnaTua) tampak, kulit
  /// ungu di tepi.
  ubiGoreng,

  /// Paha ayam terlapis kecap; kilau saus saat detail.
  ayamKecap,

  /// Paha ayam bakar dengan garis bekas bakaran gosong.
  ayamBakar,

  /// Bakwan: gorengan kasar tak beraturan dengan serutan wortel dan kol.
  bakwan,

  /// Gerombol butir jagung pipil.
  butirJagung,

  /// Dua lembar roti panggang dengan garis bekas panggangan.
  rotiBakar,

  /// Dua lembar roti bertumpuk miring; telur dan keju menyembul di tepi.
  rotiLapis,

  /// Dadar bulat tipis bertepi kecokelatan (warnaTua).
  dadarBulat,

  /// Dadar dilipat setengah lingkaran, sayur menyembul dari lipatan.
  dadarLipat,

  /// Dadar tebal dipotong empat; isi (kornet) terlihat di sisi potong.
  dadarPotong,

  /// Fuyunghai: telur tebal mengembang (sisi tebalnya tampak) dengan
  /// serpih kol & wortel di permukaan.
  fuyunghai,

  /// Sayur rebus pecel (bayam, tauge, kol) ditata melingkar di tepi;
  /// tengahnya disediakan untuk bumbu kacang.
  sayurPecel,

  /// Gundukan nasi goreng (bentuk seperti [nasi]); saat detail butir nasi
  /// yang lebih terang tampak di permukaannya.
  nasiGoreng,
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

  /// Hanya digambar saat detail (taburan halus seperti bawang goreng).
  final bool hanyaDetail;

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
    this.hanyaDetail = false,
  });

  const Komponen.hiasan(
    this.nama,
    this.bentuk,
    this.warna,
    this.warnaTua, {
    this.jumlah = 4,
    this.skala = 1,
    this.rasio = 0.5,
    this.hanyaDetail = false,
  }) : peran = PeranMakanan.hiasan,
       tunggal = false;

  const Komponen.siraman(this.nama, this.warna)
    : bentuk = BentukMakanan.generik,
      warnaTua = warna,
      peran = PeranMakanan.siraman,
      jumlah = 0,
      skala = 1,
      rasio = 0.5,
      tunggal = false,
      hanyaDetail = false;

  const Komponen.tanpa(this.nama)
    : bentuk = BentukMakanan.generik,
      warna = _W.generik,
      warnaTua = _W.generikTua,
      peran = PeranMakanan.tanpa,
      jumlah = 0,
      skala = 1,
      rasio = 0.5,
      tunggal = false,
      hanyaDetail = false;
}

/// Pena bersama sampul resep dan ikon bahan: garis tepi tinta, warna dari
/// [WarnaMakanan], dan sakelar [detail] untuk bintik/urat halus.
///
/// Pustaka komponen makanan: tiap bentuk digambar di titik asal dengan
/// jari-jari [r] (kanvas sudah digeser dan diputar pemanggil).
class PenaMakanan {
  PenaMakanan(this.c, this.tg, this.detail);

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

  void kontur(Path jalur, Color warna) => c
    ..drawPath(jalur, isi(warna))
    ..drawPath(jalur, garis(_tinta, tg));

  /// Gabungan beberapa lingkaran dengan satu garis tepi luar.
  void gabung(List<(Offset, double)> bulatan, Color warna, {Color? tepi}) {
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
      gabung(bulatan, warna, tepi: tepi);
    }
  }

  /// Tahu goreng ke-[urutan] (mulai 0) yang dipotong lurus: ke-3 dan ke-5,
  /// sehingga dari 5 kubus hanya 2 yang memperlihatkan sisi putihnya.
  static bool tahuTerpotong(int urutan) => urutan == 2 || urutan == 4;

  /// Lelehan saus kental bertepi tak beraturan (bukan bergerigi teratur)
  /// berpusat [o], jari-jari rata-rata [r], bertepi tinta.
  void lelehan(Offset o, double r, Color warna, Random acak) =>
      kontur(_tidakRata(r, r * 0.94, 12, 0.2, acak, o: o), warna);

  /// Menggambar [bentuk] berjari-jari [r] di titik asal.
  ///
  /// [urutan] = urutan potongan ini di antara potongan sekomponen (0, 1, …);
  /// bentuk boleh memakainya untuk variasi yang pasti (tahu goreng ke-3 dan
  /// ke-5 terpotong).
  void gambar(
    BentukMakanan bentuk,
    Komponen k,
    double r,
    Random acak, {
    Color? warna,
    int urutan = 0,
  }) {
    final w = warna ?? k.warna;
    switch (bentuk) {
      case BentukMakanan.telurCeplok:
        gabung([
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
        kontur(Path()..addOval(dadar), w);
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
        kontur(
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
        kontur(
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
        kontur(Path()..addRRect(luar), k.warnaTua);
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
        kontur(
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
        kontur(Path()..addRRect(badan), w);
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
        kontur(ekor, k.warnaTua);
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
        kontur(
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
        gabung(bulatan, w);
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
        kontur(daun, w);
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
        kontur(Path()..addRRect(batang), _W.daunMuda);
        gabung([
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
        kontur(
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
        kontur(Path()..addRRect(balut), _W.gorengan);
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
          kontur(Path()..addRRect(lembar), k.warnaTua);
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
        kontur(
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
        gabung(
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
        kontur(
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
        kontur(tudung, w);
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
        gabung([
          (Offset(-r * 0.2, 0), r * 0.7),
          (Offset(r * 0.35, -r * 0.15), r * 0.55),
          (Offset(r * 0.2, r * 0.3), r * 0.5),
        ], w);
        if (detail) {
          c.drawCircle(Offset(-r * 0.2, -r * 0.1), r * 0.16, isi(k.warnaTua));
        }
      case BentukMakanan.batang:
        _batang(k, r, w);
      case BentukMakanan.lembarTepung:
        _lembarTepung(k, r, w, acak);
      case BentukMakanan.perkedel:
        _perkedel(k, r, w, acak);
      case BentukMakanan.suwir:
        _suwir(k, r, w, acak);
      case BentukMakanan.orakArik:
        _orakArik(k, r, w, acak);
      case BentukMakanan.udangTepung:
        _udangTepung(k, r, w, acak);
      case BentukMakanan.ayamTepung:
        _ayamTepung(k, r, w, acak);
      case BentukMakanan.pisangGoreng:
        _pisangGoreng(k, r, w, acak);
      case BentukMakanan.gorenganJagung:
        _gorenganJagung(k, r, w, acak);
      case BentukMakanan.irisanMiring:
        _irisanMiring(k, r, w);
      case BentukMakanan.batangKangkung:
        _batangKangkung(k, r, w);
      case BentukMakanan.seratTelur:
        _seratTelur(k, r, w, acak);
      case BentukMakanan.taburan:
        _taburan(k, r, w, acak);
      case BentukMakanan.kerupuk:
        _kerupuk(k, r, w, acak);
      case BentukMakanan.cakwe:
        _cakwe(k, r, w);
      case BentukMakanan.mieGoreng:
        _mieGoreng(k, r, w, acak);
      case BentukMakanan.tahuGoreng:
        _tahuGoreng(k, r, w, acak, dipotong: tahuTerpotong(urutan));
      case BentukMakanan.ikanTeri:
        _ikanTeri(k, r, w);
      case BentukMakanan.ubiGoreng:
        _ubiGoreng(k, r, w, acak);
      case BentukMakanan.ayamKecap:
        gambar(BentukMakanan.ayam, k, r, acak, warna: w);
        if (detail) {
          c.drawArc(
            Rect.fromCenter(
              center: Offset(-r * 0.24, -r * 0.06),
              width: r * 0.95,
              height: r * 0.7,
            ),
            pi * 1.08,
            pi * 0.38,
            false,
            garis(_kilau(w), tg * 1.1),
          );
        }
      case BentukMakanan.ayamBakar:
        gambar(BentukMakanan.ayam, k, r, acak, warna: w);
        // Garis bakaran gosong di daging (selalu: ciri utamanya).
        c
          ..save()
          ..clipPath(
            Path()..addOval(
              Rect.fromCenter(
                center: Offset(-r * 0.22, 0),
                width: r * 1.5,
                height: r * 1.2,
              ),
            ),
          );
        for (final x in [-0.62, -0.26, 0.1]) {
          c.drawLine(
            Offset(r * (x - 0.16), -r * 0.62),
            Offset(r * (x + 0.16), r * 0.62),
            garis(_W.gosong, r * 0.1),
          );
        }
        c
          ..restore()
          ..drawOval(
            Rect.fromCenter(
              center: Offset(-r * 0.22, 0),
              width: r * 1.5,
              height: r * 1.2,
            ),
            garis(_tinta, tg),
          );
      case BentukMakanan.bakwan:
        _bakwan(k, r, w, acak);
      case BentukMakanan.butirJagung:
        _butirJagung(k, r, w, acak);
      case BentukMakanan.rotiBakar:
        for (final (dx, dy, putar) in const [
          (-0.2, -0.14, -0.22),
          (0.2, 0.14, 0.2),
        ]) {
          _lembarRoti(Offset(r * dx, r * dy), putar, r, k.warnaTua, w, (dalam) {
            // Garis bekas panggangan.
            for (final t in [-0.32, 0.0, 0.32]) {
              c.drawLine(
                Offset(r * (t - 0.25), dalam.top),
                Offset(r * (t + 0.25), dalam.bottom),
                garis(Color.lerp(k.warnaTua, _tinta, 0.2)!, r * 0.08),
              );
            }
          });
        }
      case BentukMakanan.rotiLapis:
        _lembarRoti(Offset(-r * 0.12, r * 0.1), -0.3, r, k.warnaTua, w, null);
        // Isi: telur dadar dan keju yang menyembul dari tepi roti.
        kontur(
          _bergelombang(
            r * 0.96,
            r * 0.9,
            10,
            0.1,
            acak,
            o: Offset(r * 0.05, 0),
          ),
          _W.dadar,
        );
        c
          ..save()
          ..rotate(0.78);
        kontur(
          Path()..addRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(
                center: Offset.zero,
                width: r * 1.4,
                height: r * 1.4,
              ),
              Radius.circular(r * 0.06),
            ),
          ),
          _W.keju,
        );
        c.restore();
        _lembarRoti(Offset(r * 0.08, -r * 0.06), 0.1, r, k.warnaTua, w, null);
      case BentukMakanan.dadarBulat:
        _dadarBulat(k, r, w, acak);
      case BentukMakanan.dadarLipat:
        _dadarLipat(k, r, w, acak);
      case BentukMakanan.dadarPotong:
        _dadarPotong(k, r, w, acak);
      case BentukMakanan.fuyunghai:
        _fuyunghai(k, r, w, acak);
      case BentukMakanan.sayurPecel:
        _sayurPecel(r, acak);
      case BentukMakanan.nasiGoreng:
        _nasiGoreng(k, r, w, acak);
    }
  }

  void _nasiGoreng(Komponen k, double r, Color w, Random acak) {
    // Siluet sama dengan gundukan nasi putih.
    gabung([
      (Offset.zero, r * 0.8),
      for (var i = 0; i < 10; i++)
        (
          Offset(cos(i * pi / 5), sin(i * pi / 5)) * r * 0.7,
          r * (0.26 + acak.nextDouble() * 0.06),
        ),
    ], w);
    if (!detail) return;
    // Butir nasi: lonjong kecil lebih terang, bertepi warna tua.
    final butir = isi(Color.lerp(w, _W.nasi, 0.6)!);
    final tepi = garis(Color.lerp(w, k.warnaTua, 0.6)!, tg * 0.5);
    for (var i = 0; i < 56; i++) {
      final o = _acakDalam(acak, r * 0.88, r * 0.88);
      final lonjong = Rect.fromCenter(
        center: Offset.zero,
        width: r * 0.15,
        height: r * 0.065,
      );
      c
        ..save()
        ..translate(o.dx, o.dy)
        ..rotate(acak.nextDouble() * pi)
        ..drawOval(lonjong, butir)
        ..drawOval(lonjong, tepi)
        ..restore();
    }
  }

  void _dadarBulat(Komponen k, double r, Color w, Random acak) {
    kontur(_bergelombang(r, r * 0.97, 14, 0.04, acak), k.warnaTua);
    c.drawPath(_bergelombang(r * 0.8, r * 0.77, 12, 0.05, acak), isi(w));
    // Bercak kecokelatan bekas wajan.
    final bercak = isi(Color.lerp(w, k.warnaTua, 0.55)!);
    for (var i = 0; i < (detail ? 6 : 3); i++) {
      c.drawPath(
        _bergelombang(
          r * 0.12,
          r * 0.08,
          5,
          0.25,
          acak,
          o: _acakDalam(acak, r * 0.55, r * 0.55),
        ),
        bercak,
      );
    }
  }

  /// Sayur omelet: 0 = wortel, 1 = daun bawang, 2 = tomat.
  static const _sayurOmelet = [_W.wortel, _W.daun, _W.tomat];

  void _dadarLipat(Komponen k, double r, Color w, Random acak) {
    // Setengah lingkaran: kubah di atas, sisi LURUS lipatan di bawah. Sayur
    // menyembul ≤ [tonjol] × jari-jari dari sisi lurus. Kotak pembatasnya
    // (termasuk sayur) berpusat di titik asal agar dadar tampak di tengah.
    const tonjol = 0.14, tinggi = 1.08;
    final rr = r * 0.97;
    final y0 = rr * (tinggi - tonjol) / 2;
    // Sayur pendek di sepanjang sisi lurus (digambar di bawah dadar).
    const n = 5;
    for (var i = 0; i < n; i++) {
      final x = rr * (-0.64 + i * 0.32 + (acak.nextDouble() - 0.5) * 0.08);
      final jenis = (i + 1) % 3;
      final warna = _sayurOmelet[jenis];
      switch (jenis) {
        case 0:
          // Batang wortel pendek, sedikit miring.
          final miring = (acak.nextDouble() - 0.5) * 0.9;
          final ujung = Offset(sin(miring), cos(miring)) * rr * 0.085;
          final o = Offset(x, y0);
          _gores(
            Path()
              ..moveTo(o.dx - ujung.dx, o.dy - ujung.dy)
              ..lineTo(o.dx + ujung.dx, o.dy + ujung.dy),
            warna,
            rr * 0.09,
          );
        case 1:
          // Irisan daun bawang: cincin hijau.
          final o = Offset(x, y0 + rr * 0.035);
          c
            ..drawCircle(o, rr * 0.09, isi(warna))
            ..drawCircle(o, rr * 0.09, garis(_tinta, tg * 0.8))
            ..drawCircle(o, rr * 0.035, isi(_W.daunMuda));
        default:
          // Dadu tomat.
          final tomat = RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset(x, y0 + rr * 0.035),
              width: rr * 0.18,
              height: rr * 0.17,
            ),
            Radius.circular(rr * 0.035),
          );
          c
            ..drawRRect(tomat, isi(warna))
            ..drawRRect(tomat, garis(_tinta, tg * 0.8));
      }
    }
    final dadar = Path()
      ..moveTo(-rr, y0)
      ..arcToPoint(Offset(rr, y0), radius: Radius.elliptical(rr, rr * tinggi))
      ..close();
    kontur(dadar, w);
    // Tepi lipatan sedikit kecokelatan, sejajar sisi lurus.
    c.drawLine(
      Offset(-rr * 0.84, y0 - rr * 0.08),
      Offset(rr * 0.84, y0 - rr * 0.08),
      garis(k.warnaTua, tg),
    );
    // Bintik sayur halus di permukaan dadar.
    final bintik = detail ? 12 : 5;
    for (var i = 0; i < bintik; i++) {
      final a = pi * (1.12 + 0.76 * (i + acak.nextDouble()) / bintik);
      final d = rr * (0.3 + acak.nextDouble() * 0.45);
      final o = Offset(cos(a) * d, y0 - rr * 0.12 + sin(a) * d * tinggi);
      final warna = _sayurOmelet[i % 3];
      final rad = rr * (detail ? 0.04 : 0.055);
      if (i % 3 == 0) {
        final arah = Offset.fromDirection(acak.nextDouble() * pi, rad * 1.1);
        c.drawLine(o - arah, o + arah, garis(warna, rad * 0.9));
      } else {
        c.drawCircle(o, rad * 0.75, isi(warna));
      }
    }
  }

  void _dadarPotong(Komponen k, double r, Color w, Random acak) {
    final awal = acak.nextDouble() * pi;
    const n = 4, sapu = 2 * pi / n;
    final rr = r * 0.9;
    for (var i = 0; i < n; i++) {
      final a0 = awal + i * sapu;
      final geser = Offset.fromDirection(a0 + sapu / 2, r * 0.08);
      kontur(
        Path()
          ..moveTo(geser.dx, geser.dy)
          ..arcTo(Rect.fromCircle(center: geser, radius: rr), a0, sapu, false)
          ..close(),
        w,
      );
      // Kornet terlihat di sisi potong yang tebal.
      for (final a in [a0 + 0.14, a0 + sapu - 0.14]) {
        for (final t in [0.4, 0.72]) {
          final o = geser + Offset.fromDirection(a, rr * t);
          c
            ..drawCircle(o, r * 0.075, isi(_W.kornet))
            ..drawCircle(o, r * 0.075, garis(_W.kornetTua, tg * 0.6));
        }
      }
      if (detail) {
        final o = geser + Offset.fromDirection(a0 + sapu / 2, rr * 0.6);
        c.drawCircle(o, r * 0.05, isi(_W.kornetTua));
      }
    }
  }

  void _fuyunghai(Komponen k, double r, Color w, Random acak) {
    // Telur tebal: permukaan yang sama digeser menjadi sisi bawah yang
    // kecokelatan, sehingga tebalnya terlihat. Tanpa sayur yang mencuat.
    final atas = _tidakRata(r * 0.93, r * 0.9, 10, 0.06, acak);
    final tebal = Offset(r * 0.06, r * 0.09);
    kontur(atas.shift(tebal), k.warnaTua);
    kontur(atas, w);
    // Tepi keemasan yang garing di sekeliling permukaan.
    c
      ..save()
      ..clipPath(atas)
      ..drawPath(atas, garis(Color.lerp(w, k.warnaTua, 0.55)!, r * 0.16))
      ..restore()
      ..drawPath(atas, garis(_tinta, tg));
    // Serpih kol & wortel di cincin tepi yang tidak tertutup saus.
    final serpih = detail ? 10 : 6;
    for (var i = 0; i < serpih; i++) {
      final a = (i + acak.nextDouble() * 0.6) * 2 * pi / serpih;
      final o = Offset.fromDirection(a, r * (0.74 + acak.nextDouble() * 0.06));
      final arah = Offset.fromDirection(a + pi / 2, r * 0.06);
      c.drawLine(
        o - arah,
        o + arah,
        garis(i.isEven ? _W.wortel : _W.daunPucatTua, r * 0.055),
      );
    }
  }

  void _sayurPecel(double r, Random acak) {
    // Enam kelompok berselang: bayam, tauge, kol. Pusatnya di cincin luar
    // agar tetap terlihat di sekeliling bumbu kacang.
    const bayam = Komponen(
      'bayam',
      BentukMakanan.daun,
      _W.daun,
      _W.daunTua,
      rasio: 0.62,
    );
    const kol = Komponen(
      'kol',
      BentukMakanan.daun,
      _W.daunPucat,
      _W.daunPucatTua,
      rasio: 0.9,
    );
    const tauge = Komponen('tauge', BentukMakanan.tauge, _W.tauge, _W.jagung);
    final awal = acak.nextDouble() * 2 * pi;
    void taruh(Offset o, double putar, void Function() lukis) {
      c
        ..save()
        ..translate(o.dx, o.dy)
        ..rotate(putar);
      lukis();
      c.restore();
    }

    // Hamparan bayam rebus (hijau tua) sebagai alas, agar cincin sayur
    // rapat tanpa celah piring.
    kontur(_tidakRata(r * 0.98, r * 0.96, 10, 0.06, acak), _W.daunTua);
    for (var j = 0; j < 6; j++) {
      final a = awal + j * pi / 3 + (acak.nextDouble() - 0.5) * 0.2;
      final pusat = Offset.fromDirection(a, r * 0.74);
      switch (j % 3) {
        case 0:
          // Bayam: tiga daun hijau mengipas ke luar.
          for (final s in const [-0.6, 0.6, 0.0]) {
            taruh(
              pusat + Offset.fromDirection(a + s * 1.2, r * 0.12),
              a + s * 0.8,
              () => gambar(BentukMakanan.daun, bayam, r * 0.34, acak),
            );
          }
        case 1:
          // Tauge: batang putih berkepala kuning, bergerombol.
          for (var i = 0; i < 7; i++) {
            taruh(
              pusat + _acakDalam(acak, r * 0.18, r * 0.16),
              a + pi / 2 + (acak.nextDouble() - 0.5) * 1.4,
              () => gambar(BentukMakanan.tauge, tauge, r * 0.25, acak),
            );
          }
        default:
          // Kol: lembar hijau pucat lebar.
          for (final s in const [-0.5, 0.5, 0.0]) {
            taruh(
              pusat + Offset.fromDirection(a + pi / 2, r * s * 0.3),
              a + s * 0.7,
              () => gambar(BentukMakanan.daun, kol, r * 0.27, acak),
            );
          }
      }
    }
  }

  /// Satu lembar roti tawar di [o] diputar [putar]: kulit [kulit] dan isi
  /// [isiRoti]; [atas] menggambar di atas isi (sudah dipotong ke isi).
  void _lembarRoti(
    Offset o,
    double putar,
    double r,
    Color kulit,
    Color isiRoti,
    void Function(Rect dalam)? atas,
  ) {
    c
      ..save()
      ..translate(o.dx, o.dy)
      ..rotate(putar);
    final lembar = RRect.fromRectAndCorners(
      Rect.fromCenter(center: Offset.zero, width: r * 1.34, height: r * 1.34),
      topLeft: Radius.circular(r * 0.42),
      topRight: Radius.circular(r * 0.42),
      bottomLeft: Radius.circular(r * 0.14),
      bottomRight: Radius.circular(r * 0.14),
    );
    kontur(Path()..addRRect(lembar), kulit);
    final dalam = lembar.deflate(r * 0.12);
    c.drawRRect(dalam, isi(isiRoti));
    if (atas != null) {
      c
        ..save()
        ..clipRRect(dalam);
      atas(dalam.outerRect);
      c.restore();
    }
    c.restore();
  }

  void _bakwan(Komponen k, double r, Color w, Random acak) {
    // Gumpalan pipih bertepi bergelombang ACAK (bukan duri radial); ukuran
    // dan lekuknya berbeda tiap potong karena benihnya berbeda.
    final rx = r * (0.86 + acak.nextDouble() * 0.1);
    final ry = r * (0.7 + acak.nextDouble() * 0.12);
    final adonan = _tidakRata(rx, ry, 13, 0.15, acak);
    kontur(adonan, w);
    // Kerak garing kecokelatan di beberapa tempat.
    c
      ..save()
      ..clipPath(adonan);
    for (var i = 0; i < 3; i++) {
      c.drawPath(
        _tidakRata(
          r * 0.24,
          r * 0.18,
          6,
          0.25,
          acak,
          o: _acakDalam(acak, rx * 0.75, ry * 0.75),
        ),
        isi(Color.lerp(w, k.warnaTua, 0.5)!),
      );
    }
    c
      ..restore()
      ..drawPath(adonan, garis(_tinta, tg));
    // Beberapa helai pendek serutan wortel & kol, arah acak; bertepi warna
    // sendiri (bukan tinta) agar tidak tampak seperti coretan.
    for (var i = 0; i < (detail ? 6 : 4); i++) {
      final o = _acakDalam(acak, rx * 0.55, ry * 0.5);
      final d = Offset.fromDirection(
        acak.nextDouble() * 2 * pi,
        r * (0.13 + acak.nextDouble() * 0.06),
      );
      final belok = Offset(-d.dy, d.dx) * (acak.nextDouble() - 0.5) * 0.8;
      final helai = Path()
        ..moveTo(o.dx - d.dx, o.dy - d.dy)
        ..quadraticBezierTo(
          o.dx + belok.dx,
          o.dy + belok.dy,
          o.dx + d.dx,
          o.dy + d.dy,
        );
      final (isiHelai, tepiHelai) = i.isEven
          ? (_W.wortel, _W.wortelTua)
          : (_W.daunPucat, _W.daunPucatTua);
      c
        ..drawPath(helai, garis(tepiHelai, r * 0.09 + tg))
        ..drawPath(helai, garis(isiHelai, r * 0.09));
    }
    if (detail) {
      for (var i = 0; i < 6; i++) {
        c.drawCircle(
          _acakDalam(acak, rx * 0.7, ry * 0.7),
          r * 0.04,
          isi(k.warnaTua),
        );
      }
    }
  }

  void _butirJagung(Komponen k, double r, Color w, Random acak) {
    for (var i = 0; i < 6; i++) {
      final o = i == 0
          ? Offset.zero
          : Offset.fromDirection(
              i * 2 * pi / 5 + acak.nextDouble() * 0.5,
              r * (0.48 + acak.nextDouble() * 0.18),
            );
      final butir = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: r * 0.52, height: r * 0.46),
        Radius.circular(r * 0.13),
      );
      c
        ..save()
        ..translate(o.dx, o.dy)
        ..rotate(acak.nextDouble() * pi)
        ..drawRRect(butir, isi(w))
        ..drawRRect(
          butir,
          garis(Color.lerp(k.warnaTua, _tinta, 0.45)!, tg * 0.75),
        );
      if (detail) {
        c.drawCircle(
          Offset(-r * 0.08, -r * 0.06),
          r * 0.05,
          isi(_W.telurPutih),
        );
      }
      c.restore();
    }
  }

  void _tahuGoreng(
    Komponen k,
    double r,
    Color w,
    Random acak, {
    required bool dipotong,
  }) {
    // Kubus: sisi samping lebih gelap (warnaTua), muka atas di kiri atas.
    final luar = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset.zero, width: r * 1.6, height: r * 1.6),
      Radius.circular(r * 0.24),
    );
    kontur(Path()..addRRect(luar), k.warnaTua);
    final muka = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(-r * 0.1, -r * 0.1),
        width: r * 1.3,
        height: r * 1.3,
      ),
      Radius.circular(r * 0.18),
    );
    if (dipotong) {
      // Dipotong LURUS: muka potong persegi putih, berbingkai kulit tipis.
      c
        ..drawRRect(muka, isi(w))
        ..drawRRect(muka.deflate(r * 0.1), isi(_W.tahu))
        ..drawRRect(
          muka.deflate(r * 0.1),
          garis(Color.lerp(w, _tinta, 0.35)!, tg * 0.7),
        );
      if (detail) {
        for (var i = 0; i < 5; i++) {
          c.drawCircle(
            Offset(-r * 0.1, -r * 0.1) + _acakDalam(acak, r * 0.42, r * 0.42),
            r * 0.035,
            isi(_W.tahuTua),
          );
        }
      }
    } else {
      // Utuh: kulit goreng keemasan; gelembung kecil saat detail.
      c.drawRRect(muka, isi(w));
      if (detail) {
        for (var i = 0; i < 6; i++) {
          c.drawCircle(
            Offset(-r * 0.1, -r * 0.1) + _acakDalam(acak, r * 0.48, r * 0.48),
            r * 0.045,
            isi(Color.lerp(w, k.warnaTua, 0.6)!),
          );
        }
      }
    }
  }

  void _ikanTeri(Komponen k, double r, Color w) {
    kontur(
      Path()
        ..moveTo(-r * 0.6, 0)
        ..lineTo(-r, -r * 0.32)
        ..lineTo(-r * 0.84, 0)
        ..lineTo(-r, r * 0.32)
        ..close(),
      k.warnaTua,
    );
    kontur(
      Path()
        ..moveTo(-r * 0.7, 0)
        ..quadraticBezierTo(-r * 0.1, -r * 0.38, r * 0.92, -r * 0.05)
        ..quadraticBezierTo(r, 0, r * 0.92, r * 0.05)
        ..quadraticBezierTo(-r * 0.1, r * 0.32, -r * 0.7, 0)
        ..close(),
      w,
    );
    // Garis perak di sisi badan.
    c.drawLine(
      Offset(-r * 0.45, r * 0.02),
      Offset(r * 0.6, -r * 0.02),
      garis(k.warnaTua, tg * 0.7),
    );
    if (detail) {
      c.drawCircle(Offset(r * 0.62, -r * 0.1), r * 0.07, isi(_tinta));
    }
  }

  void _ubiGoreng(Komponen k, double r, Color w, Random acak) {
    kontur(_bergelombang(r * 0.96, r * 0.8, 12, 0.08, acak), w);
    final daging = Rect.fromCenter(
      center: Offset(r * 0.04, r * 0.02),
      width: r * 1.3,
      height: r * 1.0,
    );
    c
      ..drawOval(daging, isi(k.warnaTua))
      ..drawOval(daging, garis(Color.lerp(k.warnaTua, _tinta, 0.35)!, tg * 0.7))
      // Kulit ungu di sebagian tepi daging.
      ..drawArc(
        daging,
        pi * 0.12,
        pi * 0.62,
        false,
        garis(_W.ubiKulit, r * 0.13),
      )
      // Tepung menutup sebagian daging.
      ..drawPath(
        _bergelombang(
          r * 0.36,
          r * 0.24,
          6,
          0.2,
          acak,
          o: Offset(-r * 0.38, -r * 0.2),
        ),
        isi(w),
      );
    if (detail) {
      for (var i = 0; i < 5; i++) {
        final o = _acakDalam(acak, r * 0.85, r * 0.7);
        if ((o.dx / (r * 0.65)) * (o.dx / (r * 0.65)) +
                (o.dy / (r * 0.5)) * (o.dy / (r * 0.5)) >
            1) {
          c.drawCircle(o, r * 0.045, isi(_W.gorenganTua));
        }
      }
    }
  }

  // -------------------------------------------------------------------------
  // Bentuk olahan (sampul khusus)
  // -------------------------------------------------------------------------

  /// Garis tebal bertepi tinta (helai, serat, batang).
  void _gores(Path jalur, Color warna, double tebal) => c
    ..drawPath(jalur, garis(_tinta, tebal + tg * 1.6))
    ..drawPath(jalur, garis(warna, tebal));

  /// Kurva tertutup bergelombang di sekitar elips [rx] × [ry] berpusat [o]:
  /// [n] titik dengan jari-jari berselang-seling ± [amp] (plus acak),
  /// disambung kurva halus.
  Path _bergelombang(
    double rx,
    double ry,
    int n,
    double amp,
    Random acak, {
    Offset o = Offset.zero,
  }) {
    final titik = <Offset>[];
    for (var i = 0; i < n; i++) {
      final a = i * 2 * pi / n;
      final f =
          1 + amp * ((i.isEven ? 0.6 : -0.6) + (acak.nextDouble() - 0.5) * 0.8);
      titik.add(o + Offset(cos(a) * rx * f, sin(a) * ry * f));
    }
    return _kurvaTertutup(titik);
  }

  /// Kurva tertutup halus melalui titik tengah antar [titik] berurutan
  /// (tiap titik menjadi titik kendali).
  static Path _kurvaTertutup(List<Offset> titik) {
    final n = titik.length;
    Offset tengah(int i) => (titik[i % n] + titik[(i + 1) % n]) / 2;
    final awal = tengah(n - 1);
    final j = Path()..moveTo(awal.dx, awal.dy);
    for (var i = 0; i < n; i++) {
      final t = tengah(i);
      j.quadraticBezierTo(titik[i].dx, titik[i].dy, t.dx, t.dy);
    }
    return j..close();
  }

  /// Seperti [_bergelombang], tetapi lekuknya ACAK (tidak berselang-seling
  /// teratur) dan sudut titiknya sedikit bergeser: tepi gumpalan alami.
  Path _tidakRata(
    double rx,
    double ry,
    int n,
    double amp,
    Random acak, {
    Offset o = Offset.zero,
  }) {
    final awal = acak.nextDouble() * 2 * pi;
    final titik = <Offset>[];
    for (var i = 0; i < n; i++) {
      final a = awal + (i + (acak.nextDouble() - 0.5) * 0.5) * 2 * pi / n;
      final f = 1 + amp * (acak.nextDouble() * 2 - 1);
      titik.add(o + Offset(cos(a) * rx * f, sin(a) * ry * f));
    }
    return _kurvaTertutup(titik);
  }

  /// Titik acak (sebaran merata) di dalam elips [rx] × [ry].
  Offset _acakDalam(Random acak, double rx, double ry) {
    final a = acak.nextDouble() * 2 * pi, d = sqrt(acak.nextDouble());
    return Offset(cos(a) * rx * d, sin(a) * ry * d);
  }

  /// Warna kilau: [w] dicampur putih piring.
  static Color _kilau(Color w) => Color.lerp(w, _W.piring, 0.45)!;

  void _batang(Komponen k, double r, Color w) {
    final tebal = max(r * 2 * k.rasio, tg * 2.5);
    kontur(
      Path()..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: r * 2, height: tebal),
          Radius.circular(tebal * 0.28),
        ),
      ),
      w,
    );
    if (detail && tebal > tg * 3) {
      c.drawLine(
        Offset(-r * 0.55, -tebal * 0.14),
        Offset(r * 0.35, -tebal * 0.14),
        garis(_kilau(w), tg * 0.7),
      );
    }
  }

  void _lembarTepung(Komponen k, double r, Color w, Random acak) {
    final tepi = _bergelombang(r, r * 0.8, 14, 0.07, acak);
    c
      ..drawPath(tepi, isi(w))
      ..save()
      ..clipPath(tepi);
    // Tempe mengintip di bawah lapisan tepung tipis.
    final tempe = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset.zero, width: r * 1.32, height: r * 0.84),
      Radius.circular(r * 0.12),
    );
    c
      ..drawRRect(tempe, isi(k.warnaTua))
      ..drawRRect(
        tempe,
        garis(Color.lerp(k.warnaTua, _tinta, 0.35)!, tg * 0.7),
      );
    for (final (x, y) in const [(-0.4, -0.16), (0.18, 0.18), (0.44, -0.2)]) {
      c.drawCircle(Offset(r * x, r * y), r * 0.075, isi(_W.tempeBintik));
    }
    // Tepung menutup sebagian tempe.
    for (final (x, y, rx, ry) in const [
      (-0.5, 0.3, 0.26, 0.2),
      (0.42, 0.34, 0.24, 0.18),
      (0.05, -0.4, 0.3, 0.16),
    ]) {
      c.drawPath(
        _bergelombang(r * rx, r * ry, 7, 0.16, acak, o: Offset(r * x, r * y)),
        isi(w),
      );
    }
    c
      ..restore()
      ..drawPath(tepi, garis(_tinta, tg));
    // Irisan daun bawang di adonan.
    for (var i = 0; i < (detail ? 6 : 3); i++) {
      final o = _acakDalam(acak, r * 0.72, r * 0.52);
      c
        ..drawCircle(o, r * 0.085, isi(_W.daun))
        ..drawCircle(o, r * 0.085, garis(_W.daunTua, tg * 0.6));
    }
  }

  void _perkedel(Komponen k, double r, Color w, Random acak) {
    kontur(_bergelombang(r * 0.96, r * 0.9, 10, 0.05, acak), k.warnaTua);
    c.drawPath(_bergelombang(r * 0.74, r * 0.68, 9, 0.06, acak), isi(w));
    for (var i = 0; i < (detail ? 6 : 3); i++) {
      final o = _acakDalam(acak, r * 0.55, r * 0.5);
      c.drawCircle(o, r * (detail ? 0.065 : 0.09), isi(_W.daun));
    }
    if (detail) {
      for (var i = 0; i < 6; i++) {
        c.drawCircle(
          _acakDalam(acak, r * 0.6, r * 0.55),
          r * 0.04,
          isi(k.warnaTua),
        );
      }
    }
  }

  void _suwir(Komponen k, double r, Color w, Random acak) {
    // Satu gundukan: alas bertepi tak rata, helai serat di atasnya.
    kontur(
      _tidakRata(r * 0.82, r * 0.72, 9, 0.12, acak),
      Color.lerp(w, k.warnaTua, 0.3)!,
    );
    final arah = (acak.nextDouble() - 0.5) * 0.6;
    final helai = <Path>[];
    for (var i = 0; i < 11; i++) {
      final o = _acakDalam(acak, r * 0.42, r * 0.34);
      final a = arah + (acak.nextDouble() - 0.5) * 0.9;
      final p = r * (0.3 + acak.nextDouble() * 0.2);
      final ujung = Offset(cos(a), sin(a)) * p;
      final belok =
          Offset(-sin(a), cos(a)) * r * (acak.nextDouble() - 0.5) * 0.4;
      helai.add(
        Path()
          ..moveTo(o.dx - ujung.dx, o.dy - ujung.dy)
          ..quadraticBezierTo(
            o.dx + belok.dx,
            o.dy + belok.dy,
            o.dx + ujung.dx,
            o.dy + ujung.dy,
          ),
      );
    }
    final tebal = r * 0.17;
    for (final h in helai) {
      c.drawPath(h, garis(_tinta, tebal + tg * 1.6));
    }
    for (final h in helai) {
      c.drawPath(h, garis(w, tebal));
    }
    // Serat: garis tipis di sebagian helai.
    for (final h in helai.take(detail ? 9 : 4)) {
      c.drawPath(h, garis(k.warnaTua, tg * 0.6));
    }
  }

  void _orakArik(Komponen k, double r, Color w, Random acak) {
    for (var i = 0; i < 4; i++) {
      final o = i == 0 ? Offset.zero : _acakDalam(acak, r * 0.5, r * 0.5);
      final rr = r * (i == 0 ? 0.55 : 0.32 + acak.nextDouble() * 0.12);
      kontur(
        _bergelombang(
          rr,
          rr * (0.75 + acak.nextDouble() * 0.25),
          7,
          0.22,
          acak,
          o: o,
        ),
        w,
      );
      // Sisa putih telur.
      if (i < 2) {
        c.drawPath(
          _bergelombang(
            rr * 0.36,
            rr * 0.26,
            5,
            0.2,
            acak,
            o: o + Offset(rr * 0.15, -rr * 0.1),
          ),
          isi(_W.telurPutih),
        );
      }
    }
    if (detail) {
      for (var i = 0; i < 5; i++) {
        c.drawCircle(
          _acakDalam(acak, r * 0.6, r * 0.6),
          r * 0.045,
          isi(k.warnaTua),
        );
      }
    }
  }

  void _udangTepung(Komponen k, double r, Color w, Random acak) {
    const awal = 0.7, sapu = 3.7;
    final rb = r * 0.5, tebal = r * 0.5;
    final ujung = Offset.fromDirection(awal + sapu, rb);
    const arah = awal + sapu + pi / 2;
    kontur(
      Path()
        ..moveTo(ujung.dx, ujung.dy)
        ..lineTo(
          ujung.dx + cos(arah - 0.55) * r * 0.62,
          ujung.dy + sin(arah - 0.55) * r * 0.62,
        )
        ..lineTo(
          ujung.dx + cos(arah) * r * 0.42,
          ujung.dy + sin(arah) * r * 0.42,
        )
        ..lineTo(
          ujung.dx + cos(arah + 0.55) * r * 0.62,
          ujung.dy + sin(arah + 0.55) * r * 0.62,
        )
        ..close(),
      _W.udangTua,
    );
    final busur = Rect.fromCircle(center: Offset.zero, radius: rb);
    final benjol = [
      for (var i = 0; i <= 8; i++)
        for (final s in [-1.0, 1.0])
          Offset.fromDirection(awal + sapu * i / 8, rb + s * tebal * 0.5),
    ];
    final rbj = r * 0.1;
    c.drawArc(busur, awal, sapu, false, garis(_tinta, tebal + tg * 2));
    for (final o in benjol) {
      c.drawCircle(o, rbj + tg, isi(_tinta));
    }
    c.drawArc(busur, awal, sapu, false, garis(w, tebal));
    for (final o in benjol) {
      c.drawCircle(o, rbj, isi(w));
    }
    if (detail) {
      for (var i = 0; i < 7; i++) {
        final a = awal + acak.nextDouble() * sapu;
        final d = rb + (acak.nextDouble() - 0.5) * tebal * 0.6;
        c.drawCircle(Offset.fromDirection(a, d), r * 0.045, isi(k.warnaTua));
      }
    }
  }

  void _ayamTepung(Komponen k, double r, Color w, Random acak) {
    final a = Offset(r * 0.3, 0), b = Offset(r * 0.86, 0);
    c
      ..drawLine(a, b, garis(_tinta, r * 0.26 + tg * 2))
      ..drawCircle(b, r * 0.17 + tg, isi(_tinta))
      ..drawLine(a, b, garis(_W.tulang, r * 0.26))
      ..drawCircle(b, r * 0.17, isi(_W.tulang));
    final pusat = Offset(-r * 0.18, 0);
    kontur(_bergelombang(r * 0.8, r * 0.7, 16, 0.12, acak, o: pusat), w);
    // Kerak tepung: gumpil gelap, lebih banyak saat detail.
    for (var i = 0; i < (detail ? 7 : 3); i++) {
      final o = pusat + _acakDalam(acak, r * 0.48, r * 0.36);
      c.drawPath(
        _bergelombang(r * 0.12, r * 0.09, 5, 0.25, acak, o: o),
        isi(k.warnaTua),
      );
    }
  }

  void _pisangGoreng(Komponen k, double r, Color w, Random acak) {
    final a = Offset(-r * 0.84, -r * 0.1);
    final kendali = Offset(0, r * 0.34);
    final b = Offset(r * 0.84, -r * 0.1);
    Offset titik(double t) =>
        a * ((1 - t) * (1 - t)) + kendali * (2 * (1 - t) * t) + b * (t * t);
    Offset normal(double t) {
      final d = (kendali - a) * (2 * (1 - t)) + (b - kendali) * (2 * t);
      return Offset(-d.dy, d.dx) / d.distance;
    }

    final jalur = Path()
      ..moveTo(a.dx, a.dy)
      ..quadraticBezierTo(kendali.dx, kendali.dy, b.dx, b.dy);
    final tebal = r * 0.52;
    final benjol = [
      for (var i = 1; i < 8; i++)
        for (final s in [-1.0, 1.0])
          titik(i / 8) + normal(i / 8) * (s * tebal * 0.5),
    ];
    final rbj = r * 0.09;
    c.drawPath(jalur, garis(_tinta, tebal + tg * 2));
    for (final o in benjol) {
      c.drawCircle(o, rbj + tg, isi(_tinta));
    }
    c.drawPath(jalur, garis(w, tebal));
    for (final o in benjol) {
      c.drawCircle(o, rbj, isi(w));
    }
    // Daging pisang mengintip memanjang di tengah.
    final pisang = Path()..moveTo(titik(0.16).dx, titik(0.16).dy);
    for (var t = 0.22; t <= 0.85; t += 0.06) {
      pisang.lineTo(titik(t).dx, titik(t).dy);
    }
    c.drawPath(pisang, garis(_W.pisang, r * 0.14));
    if (detail) {
      for (var i = 0; i < 6; i++) {
        final t = 0.1 + acak.nextDouble() * 0.8;
        c.drawCircle(
          titik(t) + normal(t) * ((acak.nextBool() ? 1 : -1) * tebal * 0.3),
          r * 0.04,
          isi(k.warnaTua),
        );
      }
    }
  }

  void _gorenganJagung(Komponen k, double r, Color w, Random acak) {
    kontur(_bergelombang(r * 0.9, r * 0.82, 11, 0.14, acak), w);
    for (var i = 0; i < (detail ? 7 : 4); i++) {
      final sudut = acak.nextDouble() * 2 * pi;
      final jauh = i < 3 ? 0.78 : 0.35;
      final o = Offset(cos(sudut) * r * jauh, sin(sudut) * r * jauh * 0.9);
      final butir = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: r * 0.3, height: r * 0.26),
        Radius.circular(r * 0.09),
      );
      c
        ..save()
        ..translate(o.dx, o.dy)
        ..rotate(sudut)
        ..drawRRect(butir, isi(_W.jagung))
        ..drawRRect(butir, garis(_tinta, tg * 0.7))
        ..restore();
    }
  }

  void _irisanMiring(Komponen k, double r, Color w) {
    final luar = Rect.fromCenter(
      center: Offset.zero,
      width: r * 2,
      height: r * 2 * k.rasio,
    );
    kontur(Path()..addOval(luar), k.warnaTua);
    c.drawOval(luar.deflate(min(r * 0.16, luar.height * 0.2)), isi(w));
    if (detail && luar.height > tg * 6) {
      for (final x in [-0.35, 0.3]) {
        c.drawCircle(Offset(r * x, 0), luar.height * 0.08, isi(k.warnaTua));
      }
    }
  }

  void _batangKangkung(Komponen k, double r, Color w) {
    final tebal = r * 0.2;
    final daun = Path()
      ..moveTo(r * -0.05, 0)
      ..quadraticBezierTo(r * 0.5, -r * 0.44, r, -r * 0.06)
      ..quadraticBezierTo(r * 0.5, r * 0.26, -r * 0.05, 0)
      ..close();
    kontur(daun, k.warnaTua);
    if (detail) {
      c.drawLine(
        Offset(r * 0.14, -r * 0.02),
        Offset(r * 0.84, -r * 0.06),
        garis(Color.lerp(k.warnaTua, _tinta, 0.3)!, tg * 0.6),
      );
    }
    _gores(
      Path()
        ..moveTo(-r * 0.9, 0)
        ..lineTo(r * 0.12, 0),
      w,
      tebal,
    );
    // Ujung potong berongga.
    c.drawCircle(
      Offset(-r * 0.9, 0),
      tebal * 0.26,
      isi(Color.lerp(w, _tinta, 0.6)!),
    );
  }

  void _seratTelur(Komponen k, double r, Color w, Random acak) {
    final tebal = r * 0.18;
    final serat = <Path>[];
    for (var j = 0; j < 3; j++) {
      final y = (j - 1) * r * 0.36 + (acak.nextDouble() - 0.5) * r * 0.15;
      final x0 = -r * (0.6 + acak.nextDouble() * 0.3);
      final x1 = r * (0.6 + acak.nextDouble() * 0.3);
      final p = Path()..moveTo(x0, y);
      const n = 4;
      for (var i = 1; i <= n; i++) {
        final x = x0 + (x1 - x0) * i / n;
        p.quadraticBezierTo(
          x - (x1 - x0) / n / 2,
          y + (i.isOdd ? -1 : 1) * r * 0.2,
          x,
          y + (acak.nextDouble() - 0.5) * r * 0.1,
        );
      }
      serat.add(p);
    }
    for (final p in serat) {
      c.drawPath(p, garis(_tinta, tebal + tg * 0.8));
    }
    for (final p in serat) {
      c.drawPath(p, garis(w, tebal));
    }
  }

  void _taburan(Komponen k, double r, Color w, Random acak) {
    final besar = detail ? 1.0 : 1.35;
    final helai = k.rasio <= 0.3;
    for (var i = 0; i < (detail ? 16 : 8); i++) {
      final o = _acakDalam(acak, r, r);
      if (helai) {
        final d = Offset.fromDirection(
          acak.nextDouble() * pi,
          r * 0.09 * besar,
        );
        final tebal = r * 0.075 * besar;
        c
          ..drawLine(o - d, o + d, garis(k.warnaTua, tebal + tg * 0.7))
          ..drawLine(o - d, o + d, garis(w, tebal));
      } else {
        final rad = r * 0.065 * besar;
        c
          ..drawCircle(o, rad + tg * 0.45, isi(k.warnaTua))
          ..drawCircle(o - Offset(rad, rad) * 0.2, rad * 0.65, isi(w));
      }
    }
  }

  void _kerupuk(Komponen k, double r, Color w, Random acak) {
    kontur(_bergelombang(r, r * 0.96, 18, 0.06, acak), w);
    c.drawPath(
      _bergelombang(r * 0.62, r * 0.58, 12, 0.08, acak),
      garis(k.warnaTua, tg * 0.7),
    );
    if (detail) {
      for (var i = 0; i < 6; i++) {
        c.drawCircle(
          _acakDalam(acak, r * 0.75, r * 0.72),
          r * 0.06,
          garis(k.warnaTua, tg * 0.5),
        );
      }
    }
  }

  void _cakwe(Komponen k, double r, Color w) {
    final h = r * 0.46;
    for (final dy in [-h * 0.48, h * 0.48]) {
      kontur(
        Path()..addRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset(0, dy), width: r * 2, height: h),
            Radius.circular(h / 2),
          ),
        ),
        w,
      );
    }
    // Sisi potong yang lebih terang di satu ujung.
    for (final dy in [-h * 0.48, h * 0.48]) {
      c.drawOval(
        Rect.fromCenter(
          center: Offset(r * 0.76, dy),
          width: h * 0.5,
          height: h * 0.62,
        ),
        isi(Color.lerp(w, _W.roti, 0.6)!),
      );
    }
    if (detail) {
      for (final dy in [-h * 0.48, h * 0.48]) {
        c.drawLine(
          Offset(-r * 0.62, dy + h * 0.12),
          Offset(r * 0.38, dy + h * 0.12),
          garis(k.warnaTua, tg * 0.6),
        );
      }
    }
  }

  void _mieGoreng(Komponen k, double r, Color w, Random acak) {
    // Mie: helai TEBAL keriting jarang. Bihun (rasio < 0,4): helai TIPIS
    // rapat yang hampir lurus. Sela helai berwarna warnaTua.
    final dasar = _bergelombang(r, r * 0.94, 13, 0.06, acak);
    final tipis = k.rasio < 0.4;
    c
      ..drawPath(dasar, isi(k.warnaTua))
      ..save()
      ..clipPath(dasar);
    final tebal = r * (tipis ? 0.042 : 0.12);
    final amp = r * (tipis ? 0.025 : 0.07);
    final gelombang = r * (tipis ? 0.5 : 0.34);
    final tepiHelai = garis(
      Color.lerp(k.warnaTua, _tinta, tipis ? 0.15 : 0.45)!,
      tebal + tg * (tipis ? 0.5 : 0.9),
    );
    final n = tipis ? 34 : 11;
    for (var i = 0; i < n; i++) {
      // Garis menyilang tumpukan, diberi gelombang sinus.
      final arah = (i * 0.618 + acak.nextDouble() * 0.3) * pi;
      final sepanjang = Offset(cos(arah), sin(arah));
      final normal = Offset(-sepanjang.dy, sepanjang.dx);
      final geser = (acak.nextDouble() * 2 - 1) * r * 0.9;
      final fase = acak.nextDouble() * 2 * pi;
      Offset titik(double t) =>
          normal * geser +
          sepanjang * (t * r) +
          normal * (amp * sin(t * r / gelombang * 2 * pi + fase));
      final awal = titik(-1.1);
      final j = Path()..moveTo(awal.dx, awal.dy);
      for (var s = 1; s <= 55; s++) {
        final p = titik(-1.1 + s * 0.04);
        j.lineTo(p.dx, p.dy);
      }
      c
        ..drawPath(j, tepiHelai)
        ..drawPath(j, garis(w, tebal));
    }
    c
      ..restore()
      ..drawPath(dasar, garis(_tinta, tg));
  }
}
