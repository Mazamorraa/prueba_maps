import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prueba_maps/app/presentation/controllers/auth_controllers.dart';

class RegisterPage extends StatelessWidget {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final userCtrl = TextEditingController();
  RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Registro')),
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
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/img/logo.png',
                            width: 300,
                            height: 300,
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
                                  : () => controller.registerWithEmail(
                                      emailCtrl.text,
                                      passCtrl.text,
                                    ),
                              child: const Text(
                                'Registrarse',
                                style: TextStyle(color: Color(0xFFD9D9D9)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
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
