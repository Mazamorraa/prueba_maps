import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:prueba_maps/app/data/datasources/auth_remote_datasource.dart';
import 'package:prueba_maps/app/data/repositories/auth_repository_impl.dart';
import 'package:prueba_maps/app/domain/repositories/auth_repository.dart';
import 'package:prueba_maps/app/presentation/controllers/auth_controllers.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    final auth = FirebaseAuth.instance;
    final datasource = AuthRemoteDatasource(auth: auth);

    final AuthRepository repository = AuthRepositoryImpl(
      datasource: datasource,
    );

    Get.put(AuthController(repository: repository), permanent: true);
  }
}
