import 'package:firebase_auth/firebase_auth.dart';
import 'package:cinemax_app/features/auth/data/data_sources/auth_remote_data_source.dart';
import 'package:cinemax_app/features/auth/domain/entities/user_entity.dart';
import 'package:cinemax_app/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<UserEntity> signUpWithEmailAndPassword({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      final userModel = await remoteDataSource.signUpWithEmailAndPassword(
        fullName: fullName,
        email: email,
        password: password,
      );
      return userModel.toEntity();
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<UserEntity> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userModel = await remoteDataSource.loginWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userModel.toEntity();
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await remoteDataSource.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<void> updatePassword({required String newPassword}) async {
    try {
      await remoteDataSource.updatePassword(newPassword: newPassword);
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await remoteDataSource.signOut();
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  UserEntity? getCurrentUser() {
    final userModel = remoteDataSource.getCurrentUser();
    return userModel?.toEntity();
  }

  @override
  Stream<UserEntity?> get authStateChanges {
    return remoteDataSource.authStateChanges.map((userModel) => userModel?.toEntity());
  }

  Exception _mapFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return Exception('This email address is already registered. Please login instead.');
      case 'invalid-email':
        return Exception('The email address entered is invalid.');
      case 'weak-password':
        return Exception('The password is too weak. Please use at least 6 characters.');
      case 'user-not-found':
        return Exception('No user account found with this email.');
      case 'wrong-password':
        return Exception('Incorrect password. Please try again.');
      case 'invalid-credential':
        return Exception('Invalid login credentials. Check your email and password.');
      case 'network-request-failed':
        return Exception('Network connection error. Please check your internet connection.');
      case 'too-many-requests':
        return Exception('Too many failed attempts. Please try again later.');
      case 'requires-recent-login':
        return Exception('Please re-authenticate before performing this operation.');
      default:
        return Exception(e.message ?? 'An unexpected authentication error occurred.');
    }
  }
}
