import 'package:cinemax_app/features/auth/domain/entities/user_entity.dart';
import 'package:cinemax_app/features/auth/domain/repositories/auth_repository.dart';

class SignUpUseCase {
  final AuthRepository repository;

  SignUpUseCase(this.repository);

  Future<UserEntity> execute({
    required String fullName,
    required String email,
    required String password,
  }) {
    return repository.signUpWithEmailAndPassword(
      fullName: fullName,
      email: email,
      password: password,
    );
  }
}
