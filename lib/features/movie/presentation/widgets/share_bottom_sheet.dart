import 'package:flutter/material.dart';
import 'package:cinemax_app/core/app_colors.dart';

class ShareBottomSheet extends StatelessWidget {
  const ShareBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const ShareBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final socialApps = [
      {'name': 'Facebook', 'icon': Icons.facebook_rounded, 'color': AppColors.facebook},
      {'name': 'Instagram', 'icon': Icons.camera_alt_rounded, 'color': AppColors.instagram},
      {'name': 'Telegram', 'icon': Icons.send_rounded, 'color': AppColors.telegram},
      {'name': 'Messenger', 'icon': Icons.chat_bubble_rounded, 'color': AppColors.messenger},
    ];

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 24),
              const Text(
                'Share to',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary, size: 20),
                onPressed: () => Navigator.of(context).pop(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Social icons row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: socialApps.map((app) {
              return GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Sharing to ${app['name']}...'),
                      backgroundColor: AppColors.card,
                      duration: const Duration(seconds: 1),
                    ),
                  );
                  Navigator.of(context).pop();
                },
                child: Column(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: app['color'] as Color,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        app['icon'] as IconData,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
