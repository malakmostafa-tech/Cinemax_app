import 'package:cinemax_app/features/auth/domain/entities/user_entity.dart';
import 'package:cinemax_app/features/auth/domain/repositories/auth_repository.dart';

class GetCurrentUserUseCase {
  final AuthRepository repository;

  GetCurrentUserUseCase(this.repository);

  UserEntity? execute() {
    return repository.getCurrentUser();
  }

  Stream<UserEntity?> get authStateChanges => repository.authStateChanges;
}
