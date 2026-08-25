// lib/core/theme/app_colors.dart
// Color palette extracted from the CINEMAX dark UI design.
// Private constructor holder — nothing is instantiable.

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ==================== Background & Surface ====================
  static const Color background = Color(0xFF14131F);
  static const Color surface = Color(0xFF1C1B29);
  static const Color surfaceElevated = Color(0xFF24232F);
  static const Color card = Color(0xFF1E1D2A);

  // ==================== Primary (Teal/Cyan) ====================
  static const Color primary = Color(0xFF17E5C3);
  static const Color primaryPressed = Color(0xFF12B89D);
  static const Color primaryLight = Color(0xFF6BF3DD);
  static const Color primarySoft = Color(0x2617E5C3); // tinted fill for badges

  // ==================== Text ====================
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFA6A5B8);
  static const Color textTertiary = Color(0xFF74738A);
  static const Color textDisabled = Color(0xFF4E4D5E);

  // ==================== Border / Divider ====================
  static const Color border = Color(0xFF2E2D3D);
  static const Color divider = Color(0xFF29283A);
  static const Color borderFocused = Color(0xFF17E5C3);
  static const Color borderError = Color(0xFFFF5A6E);

  // ==================== Status ====================
  static const Color success = Color(0xFF2ED47A);
  static const Color error = Color(0xFFFF5A6E);
  static const Color warning = Color(0xFFFFB020);
  static const Color info = Color(0xFF3E9CFF);

  // ==================== Social Buttons ====================
  static const Color googleFill = Color(0xFFFFFFFF);
  static const Color facebookFill = Color(0xFF1877F2);

  // ==================== Shimmer ====================
  static const Color shimmerBase = Color(0xFF232230);
  static const Color shimmerHighlight = Color(0xFF302F40);

  // ==================== Onboarding ====================
  static const Color onboardingDotActive = Color(0xFF17E5C3);
  static const Color onboardingDotInactive = Color(0xFF3A394A);

  // Gradient overlay applied on top of onboarding photos so the
  // white text/dots/button stay legible over any image.
  static const List<Color> posterScrim = [
    Color(0x00000000),
    Color(0xCC0A0912),
  ];
}
