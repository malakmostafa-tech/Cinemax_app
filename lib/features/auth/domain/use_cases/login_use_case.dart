import 'package:cinemax_app/features/auth/domain/entities/user_entity.dart';
import 'package:cinemax_app/features/auth/domain/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<UserEntity> execute({
    required String email,
    required String password,
  }) {
    return repository.loginWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
}
