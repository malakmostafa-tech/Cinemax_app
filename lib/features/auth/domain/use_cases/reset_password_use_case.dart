import 'package:cinemax_app/features/auth/domain/repositories/auth_repository.dart';

class ResetPasswordUseCase {
  final AuthRepository repository;

  ResetPasswordUseCase(this.repository);

  Future<void> execute({required String email}) {
    return repository.sendPasswordResetEmail(email: email);
  }
}
