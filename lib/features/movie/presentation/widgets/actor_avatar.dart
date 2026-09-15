import 'package:flutter/material.dart';
import 'package:cinemax_app/core/app_colors.dart';
import 'package:cinemax_app/features/movie/domain/entities/actor.dart';

class ActorAvatar extends StatelessWidget {
  final Actor actor;
  final bool isSelected;
  final VoidCallback? onTap;

  const ActorAvatar({
    super.key,
    required this.actor,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: isSelected
                    ? Border.all(color: AppColors.secondary, width: 2)
                    : Border.all(color: Colors.transparent, width: 2),
              ),
              child: CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.cardLight,
                backgroundImage: NetworkImage(actor.photoUrl),
                onBackgroundImageError: (exception, stackTrace) {},
                child: actor.photoUrl.isEmpty
                    ? const Icon(Icons.person_rounded, color: AppColors.textSecondary)
                    : null,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              actor.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isSelected ? AppColors.secondary : AppColors.textSecondary,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
