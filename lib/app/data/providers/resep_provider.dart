import 'dart:convert';

import 'package:get/get.dart';

import '../models/katalog_model.dart';
import 'api_config.dart';

/// Mengubah isi respons menjadi [Katalog]. raw.githubusercontent.com
/// mengirim `text/plain`, sehingga body bisa berupa String JSON.
Katalog dekodeKatalog(dynamic data) {
  final isi = data is String ? jsonDecode(data) : data;
  return Katalog.fromJson(Map<String, dynamic>.from(isi as Map));
}

/// Satu-satunya akses jaringan aplikasi (GetConnect, tanpa http/dio).
class ResepProvider extends GetConnect {
  static final Uri _url = Uri.parse(ApiConfig.urlKatalog);

  @override
  void onInit() {
    httpClient.baseUrl = _url.origin;
    httpClient.timeout = ApiConfig.timeout;
    httpClient.defaultDecoder = dekodeKatalog;
    httpClient.addRequestModifier<dynamic>((request) {
      request.headers['Accept'] = 'application/json';
      return request;
    });
  }

  Future<Response<Katalog>> ambilKatalog() => get<Katalog>(_url.path);
}
