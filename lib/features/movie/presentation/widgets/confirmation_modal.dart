import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cinemax_app/core/app_colors.dart';

class ConfirmationModal extends StatelessWidget {
  final String title;
  final String message;
  final String primaryButtonText;
  final VoidCallback onPrimaryPressed;
  final String secondaryButtonText;
  final VoidCallback onSecondaryPressed;
  final IconData icon;

  const ConfirmationModal({
    super.key,
    this.title = 'Are you sure ?',
    this.message = 'Ulamcorper imperdiet urria id non sed est semper. Rhoncus amet, enim purus gravida donec a liquet.',
    this.primaryButtonText = 'Log Out',
    required this.onPrimaryPressed,
    this.secondaryButtonText = 'Cancel',
    required this.onSecondaryPressed,
    this.icon = Icons.help_outline_rounded,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    String title = 'Are you sure ?',
    String message = 'Ulamcorper imperdiet urria id non sed est semper. Rhoncus amet, enim purus gravida donec a liquet.',
    String primaryButtonText = 'Log Out',
    required VoidCallback onPrimaryPressed,
    String secondaryButtonText = 'Cancel',
    required VoidCallback onSecondaryPressed,
  }) {
    return showDialog<T>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: ConfirmationModal(
          title: title,
          message: message,
          primaryButtonText: primaryButtonText,
          onPrimaryPressed: onPrimaryPressed,
          secondaryButtonText: secondaryButtonText,
          onSecondaryPressed: onSecondaryPressed,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            // Decorative Circular Badge Icon with Orange Ring & Blue Center & Sparkles
            Stack(
              alignment: Alignment.center,
              children: [
                // Outer subtle sparkles effect container
                Container(
                  width: 90,
                  height: 90,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                ),
                // Orange gradient ring
                Container(
                  width: 76,
                  height: 76,
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [AppColors.primary, Color(0xFFFF9E2C)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppColors.card,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: AppColors.accentCyan,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '?',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Decorative small dots/sparkles around
                Positioned(
                  top: 0,
                  right: 12,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 4,
                  left: 10,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.secondary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Heading Title
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            // Subtext paragraph
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            // Side by side pill action buttons
            Row(
              children: [
                // Primary Action Button (Outlined - e.g. Log Out)
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.secondary, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      onPressed: onPrimaryPressed,
                      child: Text(
                        primaryButtonText,
                        style: const TextStyle(
                          color: AppColors.secondary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Secondary Action Button (Solid Teal - e.g. Cancel)
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      onPressed: onSecondaryPressed,
                      child: Text(
                        secondaryButtonText,
                        style: const TextStyle(
                          color: AppColors.backgroundDark,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
