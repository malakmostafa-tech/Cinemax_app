import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cinemax_app/core/app_colors.dart';
import 'package:cinemax_app/features/movie/presentation/cubit/movie_cubit.dart';
import 'package:cinemax_app/features/movie/presentation/cubit/movie_state.dart';
import 'package:cinemax_app/features/movie/presentation/widgets/custom_status_bar.dart';
import 'package:cinemax_app/features/movie/presentation/widgets/section_label.dart';

class LanguageScreen extends StatelessWidget {
  final VoidCallback onBack;

  const LanguageScreen({
    super.key,
    required this.onBack,
  });

  static const List<String> suggestedLanguages = [
    'English (UK)',
    'English',
    'Bahasa Indonesia',
  ];

  static const List<String> otherLanguages = [
    'Chinese',
    'Croatian',
    'Czech',
    'Danish',
    'Filipino',
    'Finnish',
    'French',
    'German',
    'Hindi',
    'Italian',
    'Japanese',
    'Korean',
    'Spanish',
    'Swedish',
    'Vietnamese',
  ];

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
                          'Language',
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
                const SizedBox(height: 16),
                // Scrollable List Body
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionLabel(
                          label: 'Suggested Languages',
                          padding: EdgeInsets.only(left: 4, bottom: 12),
                        ),
                        _buildLanguageGroup(
                          context: context,
                          languages: suggestedLanguages,
                          selectedLanguage: state.selectedLanguage,
                        ),
                        const SizedBox(height: 24),
                        const SectionLabel(
                          label: 'Other Languages',
                          padding: EdgeInsets.only(left: 4, bottom: 12),
                        ),
                        _buildLanguageGroup(
                          context: context,
                          languages: otherLanguages,
                          selectedLanguage: state.selectedLanguage,
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLanguageGroup({
    required BuildContext context,
    required List<String> languages,
    required String selectedLanguage,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: List.generate(languages.length, (index) {
          final lang = languages[index];
          final isSelected = lang.toLowerCase() == selectedLanguage.toLowerCase();
          final isLast = index == languages.length - 1;

          return Column(
            children: [
              InkWell(
                onTap: () {
                  context.read<MovieCubit>().selectLanguage(lang);
                },
                borderRadius: BorderRadius.vertical(
                  top: index == 0 ? const Radius.circular(16) : Radius.zero,
                  bottom: isLast ? const Radius.circular(16) : Radius.zero,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        lang,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                      if (isSelected)
                        const Icon(
                          Icons.check_rounded,
                          color: AppColors.accentCyan,
                          size: 22,
                        ),
                    ],
                  ),
                ),
              ),
              if (!isLast)
                const Divider(color: AppColors.border, height: 1, indent: 20, endIndent: 20),
            ],
          );
        }),
      ),
    );
  }
}
