import 'package:flutter/material.dart';
import 'package:cinemax_app/core/app_colors.dart';
import 'package:cinemax_app/features/movie/presentation/widgets/custom_status_bar.dart';

class SearchInitialScreen extends StatelessWidget {
  final TextEditingController searchController;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onCancel;

  const SearchInitialScreen({
    super.key,
    required this.searchController,
    required this.onSubmitted,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const CustomStatusBar(),
            const SizedBox(height: 12),
            // Search Bar Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.searchBarBg,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: searchController,
                              style: const TextStyle(color: Colors.white, fontSize: 13),
                              onSubmitted: onSubmitted,
                              decoration: const InputDecoration(
                                hintText: 'Type title, categories, years, etc',
                                hintStyle: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: onCancel,
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            // Centered illustration
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.secondary.withValues(alpha: 0.3),
                    AppColors.card.withValues(alpha: 0.1),
                  ],
                ),
              ),
              child: const Icon(
                Icons.search_rounded,
                color: AppColors.secondary,
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Search',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Find your movie by type title, categories, year, etc.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
