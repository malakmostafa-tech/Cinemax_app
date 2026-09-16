import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cinemax_app/core/app_colors.dart';
import 'package:cinemax_app/features/movie/domain/entities/movie.dart';
import 'package:cinemax_app/features/movie/presentation/cubit/movie_cubit.dart';
import 'package:cinemax_app/features/movie/presentation/cubit/movie_state.dart';
import 'package:cinemax_app/features/movie/presentation/widgets/custom_status_bar.dart';
import 'package:cinemax_app/features/movie/presentation/widgets/wishlist_card.dart';

class WishlistScreen extends StatelessWidget {
  final VoidCallback onBack;
  final Function(Movie) onSelectMovie;

  const WishlistScreen({
    super.key,
    required this.onBack,
    required this.onSelectMovie,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MovieCubit, MovieState>(
      builder: (context, state) {
        final allKnownMovies = [
          ...state.nowPlaying,
          ...state.popular,
          ...state.searchResults,
          ...state.categoryMovies,
        ];

        final seenIds = <String>{};
        final uniqueMovies = <Movie>[];
        for (final m in allKnownMovies) {
          if (seenIds.add(m.id)) {
            uniqueMovies.add(m);
          }
        }

        final wishlistedMovies = uniqueMovies
            .where((m) => state.wishlist.contains(m.id))
            .toList();

        final isEmpty = wishlistedMovies.isEmpty;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CustomStatusBar(),
                const SizedBox(height: 12),
                // Header Bar with Back button & Title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                        onPressed: onBack,
                      ),
                      const Expanded(
                        child: Text(
                          'Wishlist',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48), // Balance spacing
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Content Body (Switching between Populated and Empty state dynamically)
                Expanded(
                  child: isEmpty
                      ? _buildEmptyState(context)
                      : _buildPopulatedState(context, wishlistedMovies),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPopulatedState(BuildContext context, List<Movie> movies) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: movies.length,
      itemBuilder: (context, index) {
        final movie = movies[index];
        return WishlistCard(
          movie: movie,
          onRemove: () {
            context.read<MovieCubit>().toggleWishlist(movie.id);
          },
          onTap: () => onSelectMovie(movie),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Gift Box / Stars illustration with circular gradient background
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.secondary.withValues(alpha: 0.35),
                    AppColors.card.withValues(alpha: 0.1),
                  ],
                ),
              ),
              child: const Icon(
                Icons.card_giftcard_rounded,
                color: AppColors.secondary,
                size: 52,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'There Is No Movie Yet!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Find your favorite type here',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
