import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prueba_maps/app/presentation/controllers/auth_controllers.dart';
import 'package:prueba_maps/app/presentation/pages/register_page.dart';

class LoginPage extends StatelessWidget {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Iniciar sesión')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: EdgeInsets.only(
              top: 24,
              left: 16,
              right: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Center(
                  child: SizedBox(
                    width: constraints.maxWidth > 600
                        ? 400
                        : constraints.maxWidth * 0.9,
                    child: Obx(() {
                      final controller = Get.find<AuthController>();

                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/img/logo.png',
                            width: 400,
                            height: 400,
                          ),
                          TextField(
                            controller: emailCtrl,
                            decoration: const InputDecoration(
                              hintText: 'Correo electrónico',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: passCtrl,
                            obscureText: true,
                            decoration: const InputDecoration(
                              hintText: 'Contraseña',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF1365B3),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onPressed: controller.isLoading.value
                                  ? null
                                  : () => controller.loginWithEmail(
                                      emailCtrl.text,
                                      passCtrl.text,
                                    ),
                              child: const Text(
                                'Iniciar sesión',
                                style: TextStyle(color: Color(0xFFD9D9D9)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () => Get.to(() => RegisterPage()),
                            child: const Text(
                              '¿No tienes cuenta? Regístrate aquí',
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                                color: Color(0xFFfa7a2e),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
