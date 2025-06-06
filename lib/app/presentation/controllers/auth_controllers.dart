import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prueba_maps/app/domain/repositories/auth_repository.dart';

class AuthController extends GetxController {
  final AuthRepository repository;

  AuthController({required this.repository});
  final Rxn<User> firebaseUser = Rxn<User>();
  final RxBool isLoading = false.obs;
  final RxString? errorMessage = RxString('');

  @override
  void onInit() {
    firebaseUser.value = repository.getCurrentUser();

    repository.authStateChanges().listen((User? user) {
      firebaseUser.value = user;
      if (user != null) {
        Get.offAllNamed('/home');
      } else {
        Get.offAllNamed('/login');
      }
    });

    super.onInit();
  }

  Future<void> registerWithEmail(String email, String password) async {
    try {
      isLoading.value = true;
      await repository.registerWithEmail(email, password);
    } on FirebaseAuthException catch (e) {
      String mensaje = _parseFirebaseError(e.code);
      showError(mensaje);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loginWithEmail(String email, String password) async {
    try {
      isLoading.value = true;
      await repository.loginWithEmail(email, password);
    } on FirebaseAuthException catch (e) {
      String mensaje = _parseFirebaseError(e.code);
      showError(mensaje);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;
      await repository.signInWithGoogle();
    } on FirebaseAuthException catch (e) {
      errorMessage?.value = e.message ?? 'Error al iniciar sesión con Google';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      isLoading.value = true;
      await repository.logout();
    } on FirebaseAuthException catch (e) {
      errorMessage?.value = e.message ?? 'Error al cerrar sesión';
    } finally {
      isLoading.value = false;
    }
  }

  void showError(String message) {
    Get.snackbar(
      'Error al inicio de sesión',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      colorText: const Color.fromARGB(255, 0, 0, 0),
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(12),
    );
  }

  String _parseFirebaseError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No existe un usuario con ese correo';
      case 'wrong-password':
        return 'Contraseña incorrecta';
      case 'invalid-email':
        return 'El correo no es válido';
      case 'channel-error':
        return 'Llene todos los campos';
      default:
        return 'Error desconocido: $code';
    }
  }
}
