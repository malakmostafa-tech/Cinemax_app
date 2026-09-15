import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cinemax_app/core/app_colors.dart';
import 'package:cinemax_app/features/favorite_movies/presentation/cubit/favorite_movies_cubit.dart';
import 'package:cinemax_app/features/favorite_movies/presentation/cubit/favorite_movies_state.dart';

class FavoriteMoviesView extends StatefulWidget {
  final int accountId;

  const FavoriteMoviesView({
    super.key,
    required this.accountId,
  });

  @override
  State<FavoriteMoviesView> createState() => _FavoriteMoviesViewState();
}

class _FavoriteMoviesViewState extends State<FavoriteMoviesView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<FavoriteMoviesCubit>().loadFavoriteMovies(widget.accountId);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<FavoriteMoviesCubit>().fetchNextPage(widget.accountId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoriteMoviesCubit, FavoriteMoviesState>(
      builder: (context, state) {
        if (state is FavoriteMoviesLoading) {
          return const Center(child: CircularProgressIndicator(color: AppColors.secondary));
        }

        if (state is FavoriteMoviesError) {
          return _buildErrorState(context, state.message);
        }

        if (state is FavoriteMoviesSuccess) {
          if (state.items.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            color: AppColors.secondary,
            backgroundColor: AppColors.card,
            onRefresh: () => context.read<FavoriteMoviesCubit>().loadFavoriteMovies(widget.accountId, isRefresh: true),
            child: ListView.builder(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              itemCount: state.items.length + (state.isFetchingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == state.items.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator(color: AppColors.secondary)),
                  );
                }

                final item = state.items[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          item.displayImage,
                          width: 70,
                          height: 95,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 70,
                            height: 95,
                            color: AppColors.surface,
                            child: const Icon(Icons.movie_outlined, color: AppColors.textSecondary),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              maxLines: 2,
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
                                const Icon(Icons.star_rounded, color: AppColors.primary, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  item.voteAverage.toStringAsFixed(1),
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  item.releaseDate.length >= 4 ? item.releaseDate.substring(0, 4) : '2024',
                                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.favorite_rounded, color: AppColors.heartActive, size: 22),
                        onPressed: () {
                          context.read<FavoriteMoviesCubit>().toggleFavorite(
                                accountId: widget.accountId,
                                movie: item,
                              );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondary.withValues(alpha: 0.15),
              ),
              child: const Icon(Icons.favorite_outline_rounded, color: AppColors.secondary, size: 48),
            ),
            const SizedBox(height: 20),
            const Text(
              'There Is No Movie Yet!',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Find your favorite type here', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 48),
            const SizedBox(height: 14),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              onPressed: () => context.read<FavoriteMoviesCubit>().loadFavoriteMovies(widget.accountId),
              child: const Text('Retry', style: TextStyle(color: AppColors.backgroundDark, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
