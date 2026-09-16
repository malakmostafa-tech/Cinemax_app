import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cinemax_app/core/app_colors.dart';
import 'package:cinemax_app/features/movie/domain/entities/movie.dart';
import 'package:cinemax_app/features/movie/presentation/cubit/movie_cubit.dart';
import 'package:cinemax_app/features/movie/presentation/cubit/movie_state.dart';
import 'package:cinemax_app/features/movie/presentation/widgets/badge_widget.dart';

enum MovieCardVariant { vertical, horizontal }

class MovieCard extends StatelessWidget {
  final Movie movie;
  final MovieCardVariant variant;
  final VoidCallback? onTap;

  const MovieCard({
    super.key,
    required this.movie,
    this.variant = MovieCardVariant.vertical,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (variant == MovieCardVariant.horizontal) {
      return _buildHorizontalCard(context);
    }
    return _buildVerticalCard(context);
  }

  Widget _buildVerticalCard(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 140,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster with Rating Badge
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.network(
                    movie.posterUrl,
                    width: 140,
                    height: 180,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 140,
                      height: 180,
                      color: AppColors.cardLight,
                      child: const Icon(Icons.movie_rounded, color: AppColors.textSecondary, size: 40),
                    ),
                  ),
                ),
                // Rating Overlay top left
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.surface.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded, color: AppColors.primary, size: 13),
                        const SizedBox(width: 3),
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
                  ),
                ),
                // Favorite Button top right
                Positioned(
                  top: 8,
                  right: 8,
                  child: _FavoriteButton(movieId: movie.id),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              movie.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Flexible(
                  child: Text(
                    movie.genre.isNotEmpty ? '${movie.genre} • ' : '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ),
                if (movie.badgeText.isNotEmpty)
                  BadgeWidget(
                    text: movie.badgeText,
                    isOrange: movie.badge == MovieBadge.newRelease || movie.badge == MovieBadge.premium,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalCard(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // Poster thumbnail
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    movie.posterUrl,
                    width: 100,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 100,
                      height: 120,
                      color: AppColors.cardLight,
                      child: const Icon(Icons.movie_rounded, color: AppColors.textSecondary, size: 32),
                    ),
                  ),
                ),
                // Star Rating on Top Left of thumbnail
                Positioned(
                  top: 6,
                  left: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.surface.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded, color: AppColors.primary, size: 12),
                        const SizedBox(width: 2),
                        Text(
                          movie.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Favorite Button top right
                Positioned(
                  top: 6,
                  right: 6,
                  child: _FavoriteButton(movieId: movie.id),
                ),
              ],
            ),
            const SizedBox(width: 14),
            // Movie info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (movie.badgeText.isNotEmpty) ...[
                    BadgeWidget(
                      text: movie.badgeText,
                      isOrange: movie.badge == MovieBadge.newRelease || movie.badge == MovieBadge.premium,
                    ),
                    const SizedBox(height: 6),
                  ],
                  Text(
                    movie.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded, color: AppColors.textSecondary, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        movie.year > 0 ? '${movie.year}' : 'N/A',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded, color: AppColors.textSecondary, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        movie.duration != '0' ? movie.duration : 'N/A',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: 8),
                      BadgeWidget(
                        text: movie.ageRating,
                        isOrange: false,
                        isOutline: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.movie_outlined, color: AppColors.textSecondary, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        movie.genre.isNotEmpty ? '${movie.genre}  |  ${movie.type}' : movie.type,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoriteButton extends StatelessWidget {
  final String movieId;

  const _FavoriteButton({required this.movieId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MovieCubit, MovieState>(
      buildWhen: (previous, current) =>
          previous.wishlist.contains(movieId) !=
          current.wishlist.contains(movieId),
      builder: (context, state) {
        final isFavorite = state.wishlist.contains(movieId);
        return GestureDetector(
          onTap: () {
            context.read<MovieCubit>().toggleWishlist(movieId);
          },
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.85),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isFavorite
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              color: isFavorite ? AppColors.heartActive : Colors.white,
              size: 16,
            ),
          ),
        );
      },
    );
  }
}
