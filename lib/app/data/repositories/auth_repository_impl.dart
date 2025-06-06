import 'package:firebase_auth/firebase_auth.dart';
import 'package:prueba_maps/app/data/datasources/auth_remote_datasource.dart';
import 'package:prueba_maps/app/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource _datasource;

  AuthRepositoryImpl({AuthRemoteDatasource? datasource})
    : _datasource = datasource ?? AuthRemoteDatasource();

  @override
  Stream<User?> authStateChanges() {
    return _datasource.authStateChanges();
  }

  @override
  User? getCurrentUser() {
    return _datasource.getCurrentUser();
  }

  @override
  Future<UserCredential> loginWithEmail(String email, String password) {
    return _datasource.loginWithEmail(email, password);
  }

  @override
  Future<void> logout() {
    return _datasource.logout();
  }

  @override
  Future<UserCredential> registerWithEmail(String email, String password) {
    return _datasource.registerWithEmail(email, password);
  }

  @override
  Future<UserCredential> signInWithGoogle() {
    return _datasource.signInWithGoogle();
  }
}
