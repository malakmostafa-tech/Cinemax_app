import 'package:flutter/material.dart';
import 'package:cinemax_app/core/app_colors.dart';

class BadgeWidget extends StatelessWidget {
  final String text;
  final bool isOrange;
  final bool isOutline;

  const BadgeWidget({
    super.key,
    required this.text,
    this.isOrange = true,
    this.isOutline = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isOrange ? AppColors.badgeNew : AppColors.badgeTrending;

    if (isOutline) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: color, width: 1),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
