import 'package:flutter/material.dart';
import 'package:cinemax_app/core/app_colors.dart';

class SectionLabel extends StatelessWidget {
  final String label;
  final EdgeInsetsGeometry padding;

  const SectionLabel({
    super.key,
    required this.label,
    this.padding = const EdgeInsets.only(left: 4, bottom: 12, top: 20),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
