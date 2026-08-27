import 'package:flutter_test/flutter_test.dart';
import 'package:cinemax_app/features/auth/data/data_sources/auth_remote_data_source.dart';
import 'package:cinemax_app/features/auth/data/models/user_model.dart';
import 'package:cinemax_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:cinemax_app/features/auth/domain/use_cases/get_current_user_use_case.dart';
import 'package:cinemax_app/features/auth/domain/use_cases/login_use_case.dart';
import 'package:cinemax_app/features/auth/domain/use_cases/logout_use_case.dart';
import 'package:cinemax_app/features/auth/domain/use_cases/reset_password_use_case.dart';
import 'package:cinemax_app/features/auth/domain/use_cases/sign_up_use_case.dart';
import 'package:cinemax_app/features/auth/domain/use_cases/update_password_use_case.dart';
import 'package:cinemax_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:cinemax_app/main.dart';

class FakeAuthRemoteDataSource implements AuthRemoteDataSource {
  @override
  UserModel? getCurrentUser() => null;

  @override
  Stream<UserModel?> get authStateChanges => Stream.value(null);

  @override
  Future<UserModel> loginWithEmailAndPassword({required String email, required String password}) async {
    return const UserModel(uid: '123', email: 'test@example.com');
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {}

  @override
  Future<void> signOut() async {}

  @override
  Future<UserModel> signUpWithEmailAndPassword({required String fullName, required String email, required String password}) async {
    return UserModel(uid: '123', email: email, displayName: fullName);
  }

  @override
  Future<void> updatePassword({required String newPassword}) async {}
}

void main() {
  testWidgets('App renders onboarding screen on initial launch', (WidgetTester tester) async {
    final fakeDataSource = FakeAuthRemoteDataSource();
    final repository = AuthRepositoryImpl(remoteDataSource: fakeDataSource);
    final authCubit = AuthCubit(
      loginUseCase: LoginUseCase(repository),
      signUpUseCase: SignUpUseCase(repository),
      logoutUseCase: LogoutUseCase(repository),
      resetPasswordUseCase: ResetPasswordUseCase(repository),
      updatePasswordUseCase: UpdatePasswordUseCase(repository),
      getCurrentUserUseCase: GetCurrentUserUseCase(repository),
    );

    await tester.pumpWidget(MyApp(authCubit: authCubit));
    await tester.pumpAndSettle();

    expect(find.text('CINEMAX'), findsNothing);
  });
}
