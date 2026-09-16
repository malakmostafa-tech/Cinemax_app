import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cinemax_app/core/app_colors.dart';
import 'package:cinemax_app/features/movie/presentation/cubit/movie_cubit.dart';
import 'package:cinemax_app/features/movie/presentation/cubit/movie_state.dart';
import 'package:cinemax_app/features/movie/presentation/widgets/custom_status_bar.dart';
import 'package:cinemax_app/features/movie/presentation/widgets/section_label.dart';

class NotificationsScreen extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback? onNavigateToExceptions;

  const NotificationsScreen({
    super.key,
    required this.onBack,
    this.onNavigateToExceptions,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MovieCubit, MovieState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CustomStatusBar(),
                const SizedBox(height: 12),
                // Header Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left_rounded, color: Colors.white, size: 28),
                        onPressed: onBack,
                      ),
                      const Expanded(
                        child: Text(
                          'Notification',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48), // Spacing balance
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Body Content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionLabel(
                        label: 'Messages Notification',
                        padding: EdgeInsets.only(left: 4, bottom: 12),
                      ),
                      // Rounded card container for settings rows
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border.withValues(alpha: 0.4)),
                        ),
                        child: Column(
                          children: [
                            // "Show Notifications" Row with Toggle Switch
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Show Notifications',
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Switch(
                                    value: state.showNotifications,
                                    activeTrackColor: AppColors.accentCyan,
                                    activeThumbColor: Colors.white,
                                    inactiveThumbColor: AppColors.textSecondary,
                                    inactiveTrackColor: AppColors.surface,
                                    onChanged: (val) {
                                      context.read<MovieCubit>().toggleNotifications(val);
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const Divider(color: AppColors.border, height: 1, indent: 16, endIndent: 16),
                            // "Exceptions" Row
                            InkWell(
                              onTap: onNavigateToExceptions ??
                                  () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Notification exceptions list'),
                                        backgroundColor: AppColors.surface,
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  },
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(16),
                                bottomRight: Radius.circular(16),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: const [
                                    Text(
                                      'Exceptions',
                                      style: TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Icon(
                                      Icons.chevron_right_rounded,
                                      color: AppColors.textSecondary,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
