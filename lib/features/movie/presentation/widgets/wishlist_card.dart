import 'package:flutter/material.dart';
import 'package:cinemax_app/core/app_colors.dart';
import 'package:cinemax_app/features/movie/domain/entities/movie.dart';

class WishlistCard extends StatelessWidget {
  final Movie movie;
  final VoidCallback onRemove;
  final VoidCallback? onTap;

  const WishlistCard({
    super.key,
    required this.movie,
    required this.onRemove,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // Video Thumbnail with Play overlay
            Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    movie.backdropUrl.isNotEmpty ? movie.backdropUrl : movie.posterUrl,
                    width: 110,
                    height: 75,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 110,
                      height: 75,
                      color: AppColors.cardLight,
                      child: const Icon(Icons.movie_rounded, color: AppColors.textSecondary, size: 28),
                    ),
                  ),
                ),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 20),
                ),
              ],
            ),
            const SizedBox(width: 14),
            // Movie info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.genre,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    movie.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        '${movie.type}  ',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                      const Icon(Icons.star_rounded, color: AppColors.primary, size: 13),
                      const SizedBox(width: 2),
                      Text(
                        movie.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Interactive Red Heart Icon button
            IconButton(
              icon: const Icon(Icons.favorite_rounded, color: AppColors.heartActive, size: 22),
              onPressed: onRemove,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }
}
