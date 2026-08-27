import 'package:cinemax_app/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> signUpWithEmailAndPassword({
    required String fullName,
    required String email,
    required String password,
  });

  Future<UserEntity> loginWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<void> sendPasswordResetEmail({
    required String email,
  });

  Future<void> updatePassword({
    required String newPassword,
  });

  Future<void> signOut();

  UserEntity? getCurrentUser();

  Stream<UserEntity?> get authStateChanges;
}
