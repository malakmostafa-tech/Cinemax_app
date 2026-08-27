import 'package:cinemax_app/features/auth/domain/entities/user_entity.dart';

abstract class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final UserEntity user;
  const AuthAuthenticated(this.user);
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthSuccess extends AuthState {
  final String message;
  final UserEntity user;
  const AuthSuccess({required this.message, required this.user});
}

class PasswordResetEmailSent extends AuthState {
  final String email;
  const PasswordResetEmailSent(this.email);
}

class PasswordUpdatedSuccess extends AuthState {
  const PasswordUpdatedSuccess();
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
}
