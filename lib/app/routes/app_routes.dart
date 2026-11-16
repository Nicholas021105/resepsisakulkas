abstract class Routes {
  static const kulkas = '/kulkas';
  static const resep = '/resep';

  /// Route dinamis: id resep dibaca dari `Get.parameters['id']`.
  static const detailResep = '/resep/:id';
  static const favorit = '/favorit';
  static const belanja = '/belanja';
  static const pengaturan = '/pengaturan';

  /// Pengenalan singkat untuk pemasangan baru.
  static const onboarding = '/selamat-datang';

  /// Mode masak langkah demi langkah untuk satu resep.
  static const masak = '/resep/:id/masak';

  static String keDetail(String id) => '/resep/$id';

  static String keMasak(String id) => '/resep/$id/masak';
}
