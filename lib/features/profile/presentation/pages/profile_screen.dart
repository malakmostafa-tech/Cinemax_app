import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cinemax_app/core/app_colors.dart';
import 'package:cinemax_app/core/app_typography.dart';
import 'package:cinemax_app/core/utils/snackbar_utils.dart';
import 'package:cinemax_app/features/movie/presentation/cubit/movie_cubit.dart';
import 'package:cinemax_app/features/movie/presentation/cubit/movie_state.dart';
import 'package:cinemax_app/features/movie/presentation/widgets/confirmation_modal.dart';
import 'package:cinemax_app/features/movie/presentation/widgets/custom_status_bar.dart';
import 'package:cinemax_app/features/movie/presentation/widgets/section_label.dart';
import 'package:cinemax_app/features/movie/presentation/widgets/settings_row.dart';

class ProfileScreen extends StatelessWidget {
  final VoidCallback? onNavigateToEditProfile;
  final VoidCallback? onNavigateToNotifications;
  final VoidCallback? onNavigateToLanguage;
  final VoidCallback? onNavigateToPrivacyPolicy;

  const ProfileScreen({
    super.key,
    this.onNavigateToEditProfile,
    this.onNavigateToNotifications,
    this.onNavigateToLanguage,
    this.onNavigateToPrivacyPolicy,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MovieCubit, MovieState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CustomStatusBar(),
                  const SizedBox(height: 12),
                  // Header: centered "Profile" title
                  const Center(
                    child: Text('Profile', style: AppTypography.headerTitle),
                  ),
                  const SizedBox(height: 24),

                  // User Info Row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundImage: NetworkImage(state.userAvatarUrl),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(state.userName, style: AppTypography.greetingTitle),
                              const SizedBox(height: 2),
                              Text(state.userEmail, style: AppTypography.greetingSub),
                            ],
                          ),
                        ),
                        // Small Edit/Pencil Button
                        IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.edit_outlined,
                              color: AppColors.accentCyan,
                              size: 18,
                            ),
                          ),
                          onPressed: onNavigateToEditProfile,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // "Premium Member" Promo Card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, Color(0xFFFF9226)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.workspace_premium_rounded,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Premium Member',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Now movies streaming for you.',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Text(
                              'Download Now!',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // "Account" Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionLabel(label: 'Account'),
                        _buildSectionContainer([
                          SettingsRow(
                            icon: Icons.person_outline_rounded,
                            label: 'Member',
                            onTap: onNavigateToEditProfile,
                          ),
                          const Divider(color: AppColors.border, height: 1, indent: 64, endIndent: 16),
                          SettingsRow(
                            icon: Icons.lock_outline_rounded,
                            label: 'Change Password',
                            onTap: onNavigateToEditProfile,
                          ),
                        ]),
                      ],
                    ),
                  ),

                  // "General" Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionLabel(label: 'General'),
                        _buildSectionContainer([
                          SettingsRow(
                            icon: Icons.notifications_none_rounded,
                            label: 'Notification',
                            onTap: onNavigateToNotifications,
                          ),
                          const Divider(color: AppColors.border, height: 1, indent: 64, endIndent: 16),
                          SettingsRow(
                            icon: Icons.language_rounded,
                            label: 'Language',
                            valueText: state.selectedLanguage,
                            onTap: onNavigateToLanguage,
                          ),
                          const Divider(color: AppColors.border, height: 1, indent: 64, endIndent: 16),
                          SettingsRow(
                            icon: Icons.flag_outlined,
                            label: 'Country',
                            onTap: () => showAppSnackBar(context, 'Country selected: United States'),
                          ),
                          const Divider(color: AppColors.border, height: 1, indent: 64, endIndent: 16),
                          SettingsRow(
                            icon: Icons.delete_outline_rounded,
                            label: 'Clear Cache',
                            onTap: () => showAppSnackBar(context, 'App cache cleared successfully (24 MB)'),
                          ),
                        ]),
                      ],
                    ),
                  ),

                  // "More" Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionLabel(label: 'More'),
                        _buildSectionContainer([
                          SettingsRow(
                            icon: Icons.description_outlined,
                            label: 'Legal and Policies',
                            onTap: onNavigateToPrivacyPolicy,
                          ),
                          const Divider(color: AppColors.border, height: 1, indent: 64, endIndent: 16),
                          SettingsRow(
                            icon: Icons.help_outline_rounded,
                            label: 'Help & Feedback',
                            onTap: () => showAppSnackBar(context, 'Help & Feedback center'),
                          ),
                          const Divider(color: AppColors.border, height: 1, indent: 64, endIndent: 16),
                          SettingsRow(
                            icon: Icons.info_outline_rounded,
                            label: 'About Us',
                            onTap: () => showAppSnackBar(context, 'Cinemax Movie App v1.0.0'),
                          ),
                        ]),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // "Log Out" Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.accentCyan, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(26),
                          ),
                        ),
                        onPressed: () {
                          ConfirmationModal.show(
                            context: context,
                            title: 'Are you sure ?',
                            message: 'Ulamcorper imperdiet urria id non sed est semper. Rhoncus amet, enim purus gravida donec a liquet.',
                            primaryButtonText: 'Log Out',
                            onPrimaryPressed: () {
                              Navigator.pop(context);
                              showAppSnackBar(context, 'Logged out successfully');
                            },
                            secondaryButtonText: 'Cancel',
                            onSecondaryPressed: () {
                              Navigator.pop(context);
                            },
                          );
                        },
                        child: const Text(
                          'Log Out',
                          style: TextStyle(
                            color: AppColors.accentCyan,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionContainer(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.4)),
      ),
      child: Column(children: children),
    );
  }
}
