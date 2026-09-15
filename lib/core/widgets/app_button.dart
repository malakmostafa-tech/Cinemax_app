import 'package:flutter/material.dart';
import 'package:cinemax_app/core/app_colors.dart';

enum AppButtonVariant { primary, cyan, outline }

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final AppButtonVariant variant;
  final double height;
  final double borderRadius;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.variant = AppButtonVariant.primary,
    this.height = 52.0,
    this.borderRadius = 26.0,
  });

  @override
  Widget build(BuildContext context) {
    if (variant == AppButtonVariant.outline) {
      return SizedBox(
        height: height,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.accentCyan, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
          onPressed: onPressed,
          child: Text(
            text,
            style: const TextStyle(
              color: AppColors.accentCyan,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    final bgColor = variant == AppButtonVariant.primary
        ? AppColors.primary
        : AppColors.accentCyan;

    final textColor = variant == AppButtonVariant.primary
        ? Colors.white
        : AppColors.backgroundDark;

    return SizedBox(
      height: height,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, color: textColor, size: 22),
              const SizedBox(width: 8),
            ],
            Text(
              text,
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
