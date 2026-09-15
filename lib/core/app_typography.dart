import 'package:flutter/material.dart';
import 'package:cinemax_app/core/app_colors.dart';

class AppTypography {
  AppTypography._();

  static const TextStyle headerTitle = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 18,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.2,
  );

  static const TextStyle greetingTitle = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle greetingSub = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle sectionTitle = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle seeAll = TextStyle(
    color: AppColors.secondary,
    fontSize: 13,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle cardTitle = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 14,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle cardMeta = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 11,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle badgeText = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 10,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle starRating = TextStyle(
    color: AppColors.primary,
    fontSize: 12,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle body = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 13,
    height: 1.5,
  );
}
