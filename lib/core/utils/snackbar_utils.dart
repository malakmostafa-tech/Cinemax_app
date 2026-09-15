import 'package:flutter/material.dart';
import 'package:cinemax_app/core/app_colors.dart';

void showAppSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: AppColors.surface,
    ),
  );
}
