import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_storage/get_storage.dart';
import 'firebase_options.dart';
import 'app/core/theme/app_theme.dart';
import 'app/routes/app_pages.dart';

void main() async {
  await GetStorage.init();
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Aplikasi Kasir',
      debugShowCheckedModeBanner: false,

      // Pakai theme yang sudah kita definisikan
      theme: AppTheme.theme,

      // Halaman pertama = Login
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    );
  }
}
