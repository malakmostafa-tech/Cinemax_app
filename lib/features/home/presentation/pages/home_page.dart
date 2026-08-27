import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cinemax_app/core/app_colors.dart';
import 'package:cinemax_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:cinemax_app/features/auth/presentation/cubit/auth_state.dart';
import 'package:cinemax_app/features/auth/presentation/widgets/custom_primary_button.dart';
import 'package:cinemax_app/features/auth/presentation/pages/auth_choice_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'CINEMAX',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const AuthChoicePage()),
              (route) => false,
            );
          }
        },
        builder: (context, state) {
          String displayName = 'User';
          String email = '';

          if (state is AuthAuthenticated) {
            displayName = state.user.displayName ?? state.user.email.split('@').first;
            email = state.user.email;
          } else if (state is AuthSuccess) {
            displayName = state.user.displayName ?? state.user.email.split('@').first;
            email = state.user.email;
          }

          final isLoading = state is AuthLoading;

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 2),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.person_outline_rounded,
                        color: AppColors.primary,
                        size: 44,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Welcome back, $displayName!',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (email.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      email,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                  const SizedBox(height: 48),
                  CustomPrimaryButton(
                    text: 'Log Out',
                    isLoading: isLoading,
                    onTap: () {
                      context.read<AuthCubit>().logout();
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
