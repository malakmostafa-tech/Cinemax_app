import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cinemax_app/firebase_options.dart';
import 'package:cinemax_app/core/app_colors.dart';
import 'package:cinemax_app/features/auth/data/data_sources/auth_remote_data_source.dart';
import 'package:cinemax_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:cinemax_app/features/auth/domain/use_cases/get_current_user_use_case.dart';
import 'package:cinemax_app/features/auth/domain/use_cases/login_use_case.dart';
import 'package:cinemax_app/features/auth/domain/use_cases/logout_use_case.dart';
import 'package:cinemax_app/features/auth/domain/use_cases/reset_password_use_case.dart';
import 'package:cinemax_app/features/auth/domain/use_cases/sign_up_use_case.dart';
import 'package:cinemax_app/features/auth/domain/use_cases/update_password_use_case.dart';
import 'package:cinemax_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:cinemax_app/features/auth/presentation/cubit/auth_state.dart';
import 'package:cinemax_app/features/home/presentation/pages/home_page.dart';
import 'package:cinemax_app/features/onboarding/presentation/pages/onboarding_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final remoteDataSource = AuthRemoteDataSourceImpl();
  final repository = AuthRepositoryImpl(remoteDataSource: remoteDataSource);

  final authCubit = AuthCubit(
    loginUseCase: LoginUseCase(repository),
    signUpUseCase: SignUpUseCase(repository),
    logoutUseCase: LogoutUseCase(repository),
    resetPasswordUseCase: ResetPasswordUseCase(repository),
    updatePasswordUseCase: UpdatePasswordUseCase(repository),
    getCurrentUserUseCase: GetCurrentUserUseCase(repository),
  );

  runApp(MyApp(authCubit: authCubit));
}

class MyApp extends StatelessWidget {
  final AuthCubit authCubit;

  const MyApp({super.key, required this.authCubit});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: authCubit,
      child: MaterialApp(
        title: 'CINEMAX',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: AppColors.background,
          primaryColor: AppColors.primary,
          colorScheme: const ColorScheme.dark(
            primary: AppColors.primary,
            surface: AppColors.surface,
          ),
        ),
        home: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            if (state is AuthAuthenticated) {
              return const HomePage();
            }
            return const OnboardingScreen();
          },
        ),
      ),
    );
  }
}
