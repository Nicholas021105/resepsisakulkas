import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import 'app/bindings/initial_binding.dart';
import 'app/routes/app_pages.dart';
import 'app/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await initializeDateFormatting('id_ID');
  Intl.defaultLocale = 'id_ID';
  runApp(const ResepSisaKulkasApp());
}

class ResepSisaKulkasApp extends StatelessWidget {
  const ResepSisaKulkasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'ResepSisaKulkas',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.terang,
      locale: const Locale('id', 'ID'),
      initialBinding: InitialBinding(),
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
      defaultTransition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 280),
    );
  }
}
