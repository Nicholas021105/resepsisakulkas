abstract class Routes {
  static const kulkas = '/kulkas';
  static const resep = '/resep';

  /// Route dinamis: id resep dibaca dari `Get.parameters['id']`.
  static const detailResep = '/resep/:id';
  static const favorit = '/favorit';
  static const pengaturan = '/pengaturan';

  static String keDetail(String id) => '/resep/$id';
}
