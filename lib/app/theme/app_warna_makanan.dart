import 'package:flutter/painting.dart';

/// Warna komponen makanan pada sampul resep (`SampulResep`) dan ikon bahan
/// (`IkonBahan`). Ilustrasi: sama di tema terang dan gelap, seperti magnet.
abstract class WarnaMakanan {
  // Telur.
  static const telurPutih = Color(0xFFFFFDF6);
  static const telurTepi = Color(0xFFD9CDB0);
  static const telurKuning = Color(0xFFF6BE2C);
  static const telurKuningTua = Color(0xFFD9961A);
  static const dadar = Color(0xFFF4CF55);
  static const dadarTua = Color(0xFFD9A32B);

  // Protein.
  static const tempe = Color(0xFFBA8653);
  static const tempeTua = Color(0xFF8A5B32);
  static const tempeBintik = Color(0xFFF1DDB5);
  static const tahu = Color(0xFFFFF5DA);
  static const tahuTua = Color(0xFFE5C987);
  static const ayam = Color(0xFFD49A4A);
  static const ayamTua = Color(0xFFA86D24);
  static const tulang = Color(0xFFFFF8EA);
  static const sosis = Color(0xFFC8553D);
  static const sosisTua = Color(0xFF9C3A27);
  static const udang = Color(0xFFF4936A);
  static const udangTua = Color(0xFFD9643C);
  static const teri = Color(0xFFC9D3D6);
  static const teriTua = Color(0xFF8FA0A6);
  static const kornet = Color(0xFFD98A7A);
  static const kornetTua = Color(0xFFB5604F);
  static const keju = Color(0xFFFFD766);
  static const kejuTua = Color(0xFFE0AE2F);
  static const kacang = Color(0xFFD9B27C);
  static const kacangTua = Color(0xFFB0854A);

  // Karbohidrat.
  static const nasi = Color(0xFFFFFDF6);
  static const nasiTua = Color(0xFFD8CDB6);
  static const mie = Color(0xFFF7D774);
  static const mieTua = Color(0xFFE0AE2F);
  static const bihun = Color(0xFFFBF3DC);
  static const bihunTua = Color(0xFFD6C494);
  static const roti = Color(0xFFF5E6BC);
  static const rotiKulit = Color(0xFFB67A22);
  static const gorengan = Color(0xFFE3A548);
  static const gorenganTua = Color(0xFFB67A22);
  static const pisang = Color(0xFFF6D860);
  static const pisangTua = Color(0xFFD4AE2E);
  static const ubi = Color(0xFFE88B3A);
  static const ubiKulit = Color(0xFF8E4C8A);

  // Sayur.
  static const daun = Color(0xFF5FAE6A);
  static const daunTua = Color(0xFF3C8348);
  static const daunGelap = Color(0xFF2F6E3B);
  static const daunMuda = Color(0xFF9BD08A);
  static const daunPucat = Color(0xFFD2E8B4);
  static const daunPucatTua = Color(0xFFA9CC84);
  static const wortel = Color(0xFFF28C28);
  static const wortelDalam = Color(0xFFF9B565);
  static const jagung = Color(0xFFF7CF3D);
  static const jagungTua = Color(0xFFD9A51C);
  static const tomat = Color(0xFFE2452F);
  static const tomatDalam = Color(0xFFF58A77);
  static const cabai = Color(0xFFD62828);
  static const kentang = Color(0xFFF3DC8C);
  static const kentangTua = Color(0xFFD4B95A);
  static const labu = Color(0xFFCFE8B0);
  static const labuTua = Color(0xFFA4CC7A);
  static const terong = Color(0xFF6B4A9B);
  static const terongTua = Color(0xFF4B2F78);
  static const timun = Color(0xFFDDF2BE);
  static const timunKulit = Color(0xFF4E9A52);
  static const tauge = Color(0xFFFBF6E6);
  static const jamur = Color(0xFFE9D8BC);
  static const jamurTua = Color(0xFFC2AA85);

  // Bumbu & siraman.
  static const bawangMerah = Color(0xFFB5426B);
  static const bawangMerahTua = Color(0xFF7E2148);
  static const bawangPutih = Color(0xFFF7EBCB);
  static const bawangPutihTua = Color(0xFFCDB98A);
  static const margarin = Color(0xFFF9DC72);
  static const margarinTua = Color(0xFFE2B93B);
  static const jeruk = Color(0xFFE2EE8A);
  static const jerukKulit = Color(0xFF7FB23A);
  static const meses = Color(0xFF5E3719);
  static const kecap = Color(0xFF4A2A14);
  static const sausTomat = Color(0xFFD9482F);
  static const sausTiram = Color(0xFF6B4A36);
  static const sausTiramBotol = Color(0xFF9A4E36);
  static const gulaMerah = Color(0xFF8A552F);
  static const susu = Color(0xFFFFFDF6);

  // Khusus ikon bahan (IkonBahan): bahan mentah & kemasannya.
  static const wortelTua = Color(0xFFC8661A);
  static const ubiKulitTua = Color(0xFF64305F);
  static const gulaMerahTua = Color(0xFF5E3719);
  static const bawangAkar = Color(0xFFB79466);
  static const batangPucat = Color(0xFFF1F5DF);
  static const garam = Color(0xFFF8FAFA);
  static const garamTutup = Color(0xFFB4C1C4);
  static const merica = Color(0xFF4A4038);
  static const gulaPasir = Color(0xFFFFFFFF);
  static const gulaPasirTua = Color(0xFFD5E3DF);
  static const kaldu = Color(0xFFE4572E);
  static const kalduTua = Color(0xFFA93A1B);
  static const karung = Color(0xFFF2E8D5);
  static const karungTua = Color(0xFFC9B48E);
  static const kelapa = Color(0xFFFFFFFF);
  static const kelapaKulit = Color(0xFF8A5B32);
  static const air = Color(0xFF9ED6F2);
  static const airTua = Color(0xFF4FA3D1);
  static const toples = Color(0xFFE6F1EE);
  static const tutupToples = Color(0xFFD9482F);
  static const labelKrem = Color(0xFFF3E9D2);
  static const cangkang = Color(0xFF8C8277);
  static const susuLabel = Color(0xFF9CCBEA);

  // Olahan matang khusus sampul (sampul_khusus.dart).
  static const tempeKecap = Color(0xFF8A5530);
  static const tempeBalado = Color(0xFFA9532E);
  static const tepungMendoan = Color(0xFFF1DC9C);
  static const tahuGoreng = Color(0xFFDDA24B);
  static const tahuGorengTua = Color(0xFFAE7429);
  static const ayamSuwir = Color(0xFFEBCB97);
  static const ayamSuwirTua = Color(0xFFC29A61);
  static const cakwe = Color(0xFFD18A3D);
  static const cakweTua = Color(0xFF9C5D22);
  static const kerupuk = Color(0xFFF7EAC8);
  static const kerupukTua = Color(0xFFD8BE86);
  static const bawangGoreng = Color(0xFFC98A4B);
  static const bawangGorengTua = Color(0xFF8E5524);
  static const cabaiTua = Color(0xFF9E1B1B);
  static const sambalTua = Color(0xFF9E2B1E);
  static const ayamKecap = Color(0xFF7A4220);
  static const ayamBakar = Color(0xFF8E4D24);
  static const gosong = Color(0xFF3A2414);
  static const sosisDalam = Color(0xFFF2A68F);
  static const kuahKolak = Color(0xFFD7B184);
  static const kuahJagung = Color(0xFFF3E3A2);
  static const rotiTelur = Color(0xFFEDC35C);
  static const rotiBakar = Color(0xFFE6BA6E);
  static const pisangBakar = Color(0xFFE9BC4A);
  static const bumbuKacang = Color(0xFFC48A4E);
  static const dadarCokelat = Color(0xFFC88A35);

  // Kuah di mangkuk.
  static const kuahBening = Color(0xFFF3E6AE);
  static const kuahSantan = Color(0xFFF7EED6);
  static const kuahKecap = Color(0xFF9A6336);
  static const kuahMerah = Color(0xFFE2664A);
  static const kuahHijau = Color(0xFFDDEBB0);

  // Wadah.
  static const piring = Color(0xFFFFFFFF);
  static const piringBibir = Color(0xFFD5E3DF);
  static const batu = Color(0xFF7D8884);
  static const batuDalam = Color(0xFF5F6B67);
  static const ulekan = Color(0xFF99A39F);
  static const cup = Color(0xFFF4F8F7);
  static const cupBibir = Color(0xFFDCE8E5);
  static const daunPisang = Color(0xFF6DB56F);
  static const daunPisangTua = Color(0xFF3F8A4C);

  // Bentuk generik (bahan tanpa komponen khusus & tanpa kategori).
  static const generik = Color(0xFFD8CDB6);
  static const generikTua = Color(0xFFB0A286);
}
