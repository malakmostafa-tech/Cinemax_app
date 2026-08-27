import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cinemax_app/features/auth/domain/use_cases/get_current_user_use_case.dart';
import 'package:cinemax_app/features/auth/domain/use_cases/login_use_case.dart';
import 'package:cinemax_app/features/auth/domain/use_cases/logout_use_case.dart';
import 'package:cinemax_app/features/auth/domain/use_cases/reset_password_use_case.dart';
import 'package:cinemax_app/features/auth/domain/use_cases/sign_up_use_case.dart';
import 'package:cinemax_app/features/auth/domain/use_cases/update_password_use_case.dart';
import 'package:cinemax_app/features/auth/presentation/cubit/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase loginUseCase;
  final SignUpUseCase signUpUseCase;
  final LogoutUseCase logoutUseCase;
  final ResetPasswordUseCase resetPasswordUseCase;
  final UpdatePasswordUseCase updatePasswordUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;

  StreamSubscription? _authSubscription;

  AuthCubit({
    required this.loginUseCase,
    required this.signUpUseCase,
    required this.logoutUseCase,
    required this.resetPasswordUseCase,
    required this.updatePasswordUseCase,
    required this.getCurrentUserUseCase,
  }) : super(const AuthInitial()) {
    _listenToAuthState();
  }

  void _listenToAuthState() {
    _authSubscription = getCurrentUserUseCase.authStateChanges.listen((user) {
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(const AuthUnauthenticated());
      }
    });
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim();
    if (cleanEmail.isEmpty) {
      emit(const AuthError('Email address cannot be empty.'));
      return;
    }
    if (!_isValidEmail(cleanEmail)) {
      emit(const AuthError('Please enter a valid email address.'));
      return;
    }
    if (password.isEmpty) {
      emit(const AuthError('Password cannot be empty.'));
      return;
    }

    emit(const AuthLoading());
    try {
      final user = await loginUseCase.execute(
        email: cleanEmail,
        password: password,
      );
      emit(AuthSuccess(message: 'Login successful!', user: user));
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> signUp({
    required String fullName,
    required String email,
    required String password,
    required bool termsAccepted,
  }) async {
    final cleanName = fullName.trim();
    final cleanEmail = email.trim();

    if (cleanName.isEmpty) {
      emit(const AuthError('Full name cannot be empty.'));
      return;
    }
    if (cleanEmail.isEmpty) {
      emit(const AuthError('Email address cannot be empty.'));
      return;
    }
    if (!_isValidEmail(cleanEmail)) {
      emit(const AuthError('Please enter a valid email address.'));
      return;
    }
    if (password.isEmpty) {
      emit(const AuthError('Password cannot be empty.'));
      return;
    }
    if (password.length < 6) {
      emit(const AuthError('Password must be at least 6 characters.'));
      return;
    }
    if (!termsAccepted) {
      emit(const AuthError('You must agree to the Terms and Services & Privacy Policy.'));
      return;
    }

    emit(const AuthLoading());
    try {
      final user = await signUpUseCase.execute(
        fullName: cleanName,
        email: cleanEmail,
        password: password,
      );
      emit(AuthSuccess(message: 'Account created successfully!', user: user));
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> resetPassword({required String email}) async {
    final cleanEmail = email.trim();
    if (cleanEmail.isEmpty) {
      emit(const AuthError('Email address cannot be empty.'));
      return;
    }
    if (!_isValidEmail(cleanEmail)) {
      emit(const AuthError('Please enter a valid email address.'));
      return;
    }

    emit(const AuthLoading());
    try {
      await resetPasswordUseCase.execute(email: cleanEmail);
      emit(PasswordResetEmailSent(cleanEmail));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> updatePassword({
    required String newPassword,
    required String confirmPassword,
  }) async {
    if (newPassword.isEmpty) {
      emit(const AuthError('New password cannot be empty.'));
      return;
    }
    if (newPassword.length < 6) {
      emit(const AuthError('Password must be at least 6 characters.'));
      return;
    }
    if (newPassword != confirmPassword) {
      emit(const AuthError('Passwords do not match.'));
      return;
    }

    emit(const AuthLoading());
    try {
      await updatePasswordUseCase.execute(newPassword: newPassword);
      emit(const PasswordUpdatedSuccess());
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> logout() async {
    emit(const AuthLoading());
    try {
      await logoutUseCase.execute();
      emit(const AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
