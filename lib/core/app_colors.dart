import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Background & Surface
  static const Color background = Color(0xFF1F1D2B);
  static const Color backgroundDark = Color(0xFF171725);
  static const Color surface = Color(0xFF252836);
  static const Color card = Color(0xFF252836);
  static const Color cardLight = Color(0xFF2B2D3A);
  static const Color searchBarBg = Color(0xFF252836);

  // Accents
  static const Color primary = Color(0xFFFF7A00); // Orange (Play CTA, New badge, Stars)
  static const Color secondary = Color(0xFF2ED9C3); // Cyan/Teal (Active Tab, Trending badge)
  static const Color accentCyan = Color(0xFF12CDD9);

  // Status & Badges
  static const Color badgeNew = Color(0xFFFF7A00);
  static const Color badgeTrending = Color(0xFF2ED9C3);
  static const Color badgePremium = Color(0xFFFF7A00);
  static const Color badgeFree = Color(0xFF2ED9C3);
  static const Color heartActive = Color(0xFFFF3B30);

  static const Color success = Color(0xFF2ED47A);
  static const Color error = Color(0xFFFF5A6E);
  static const Color googleFill = Color(0xFFFFFFFF);
  static const Color facebookFill = Color(0xFF1877F2);

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF92929D);
  static const Color textTertiary = Color(0xFF696974);

  // Borders & Dividers
  static const Color border = Color(0xFF323647);
  static const Color divider = Color(0xFF252836);

  // Social Colors
  static const Color facebook = Color(0xFF1877F2);
  static const Color instagram = Color(0xFFE4405F);
  static const Color whatsapp = Color(0xFF25D366);
  static const Color telegram = Color(0xFF0088CC);
  static const Color messenger = Color(0xFF0084FF);

  // Legacy Aliases for Complete Backwards Compatibility
  static const Color backgroundColor = background;
  static const Color primaryColor = primary;
  static const Color secondaryColor = secondary;
  static const Color primaryTextColor = textPrimary;
  static const Color secondaryTextColor = textSecondary;
  static const Color tertiaryTextColor = textTertiary;
  static const Color errorColor = error;
  static const Color boxColor = surface;
  static const Color headerButtonColor = cardLight;
  static const Color whiteGreyColor = Color(0xFFE2E8F0);
}
