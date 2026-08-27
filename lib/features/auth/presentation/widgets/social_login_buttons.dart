import 'package:flutter/material.dart';
import 'package:cinemax_app/core/app_colors.dart';

class SocialLoginButtons extends StatelessWidget {
  final VoidCallback? onGoogleTap;
  final VoidCallback? onFacebookTap;

  const SocialLoginButtons({
    super.key,
    this.onGoogleTap,
    this.onFacebookTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: const [
            Expanded(
              child: Divider(
                color: AppColors.border,
                thickness: 1,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Or Sign up with',
                style: TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Expanded(
              child: Divider(
                color: AppColors.border,
                thickness: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Google Button
            GestureDetector(
              onTap: onGoogleTap,
              child: Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: AppColors.googleFill,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    'G',
                    style: TextStyle(
                      color: Colors.red.shade600,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 0, width: 24),
            // Facebook Button
            GestureDetector(
              onTap: onFacebookTap,
              child: Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: AppColors.facebookFill,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    'f',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
