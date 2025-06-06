import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_storage/get_storage.dart';
import 'package:prueba_maps/app/core/bindings/initial_binding.dart';
import 'package:prueba_maps/app/core/routes/app_pages.dart';
import 'package:prueba_maps/app/core/routes/app_routes.dart';
import 'package:prueba_maps/app/presentation/controllers/map_controller.dart';
import 'firebase_options.dart';
import 'package:get/get.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  Get.put(MapController());
  await GetStorage.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Mapa Interactivo',
      debugShowCheckedModeBanner: false,
      initialBinding: InitialBinding(),
      initialRoute: AppRoutes.login,
      getPages: AppPages.pages,
      theme: ThemeData.light().copyWith(
        inputDecorationTheme: InputDecorationTheme(
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFfa7a2e), width: 1.5),
          ),
          border: OutlineInputBorder(),
        ),
        scaffoldBackgroundColor: Colors.white,
        primaryColor: Color(0xFF1365B3),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF1365B3),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
    );
  }
}
