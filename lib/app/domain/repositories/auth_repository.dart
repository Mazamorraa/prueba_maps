import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRepository {
  Future<UserCredential> registerWithEmail(String email, String password);
  Future<UserCredential> loginWithEmail(String email, String password);
  Future<UserCredential> signInWithGoogle();
  Future<void> logout();
  User? getCurrentUser();
  Stream<User?> authStateChanges();
}
