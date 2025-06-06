import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';
import 'package:prueba_maps/app/core/routes/app_routes.dart';
import 'package:prueba_maps/app/presentation/pages/home_page.dart';
import 'package:prueba_maps/app/presentation/pages/login_page.dart';
import 'package:prueba_maps/app/presentation/pages/register_page.dart';
import 'package:prueba_maps/app/presentation/pages/splash_page.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.splash,
      page: () => SplashPage(),
      transition: Transition.fadeIn,
    ),
    GetPage(name: AppRoutes.login, page: () => LoginPage()),
    GetPage(name: AppRoutes.register, page: () => RegisterPage()),
    GetPage(name: AppRoutes.home, page: () => HomePage()),
  ];
}
