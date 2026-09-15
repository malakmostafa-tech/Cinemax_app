import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cinemax_app/core/app_colors.dart';
import 'package:cinemax_app/core/models/tmdb_media_item.dart';
import 'package:cinemax_app/features/tmdb_account/presentation/cubit/tmdb_account_cubit.dart';
import 'package:cinemax_app/features/tmdb_account/presentation/cubit/tmdb_account_state.dart';
import 'package:cinemax_app/features/favorites_combined/presentation/cubit/favorites_combined_cubit.dart';
import 'package:cinemax_app/features/favorites_combined/presentation/cubit/favorites_combined_state.dart';
import 'package:cinemax_app/features/favorite_movies/presentation/cubit/favorite_movies_cubit.dart';
import 'package:cinemax_app/features/favorite_movies/presentation/cubit/favorite_movies_state.dart';
import 'package:cinemax_app/features/favorite_tv/presentation/cubit/favorite_tv_cubit.dart';
import 'package:cinemax_app/features/favorite_tv/presentation/cubit/favorite_tv_state.dart';
import 'package:cinemax_app/features/movie/presentation/widgets/custom_status_bar.dart';

class TmdbFavoritesScreen extends StatefulWidget {
  final VoidCallback onBack;
  const TmdbFavoritesScreen({super.key, required this.onBack});

  @override
  State<TmdbFavoritesScreen> createState() => _TmdbFavoritesScreenState();
}

class _TmdbFavoritesScreenState extends State<TmdbFavoritesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _allScroll = ScrollController();
  final ScrollController _moviesScroll = ScrollController();
  final ScrollController _tvScroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    final accountState = context.read<TmdbAccountCubit>().state;
    if (accountState is TmdbAccountAuthenticated) {
      final id = accountState.accountId;
      context.read<FavoritesCombinedCubit>().loadFavorites(id);
      context.read<FavoriteMoviesCubit>().loadFavoriteMovies(id);
      context.read<FavoriteTVCubit>().loadFavoriteTV(id);
    }

    _moviesScroll.addListener(() {
      final accountState = context.read<TmdbAccountCubit>().state;
      if (accountState is TmdbAccountAuthenticated &&
          _moviesScroll.position.pixels >= _moviesScroll.position.maxScrollExtent - 200) {
        context.read<FavoriteMoviesCubit>().fetchNextPage(accountState.accountId);
      }
    });

    _tvScroll.addListener(() {
      final accountState = context.read<TmdbAccountCubit>().state;
      if (accountState is TmdbAccountAuthenticated &&
          _tvScroll.position.pixels >= _tvScroll.position.maxScrollExtent - 200) {
        context.read<FavoriteTVCubit>().fetchNextPage(accountState.accountId);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _allScroll.dispose();
    _moviesScroll.dispose();
    _tvScroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TmdbAccountCubit, TmdbAccountState>(
      builder: (context, accountState) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              children: [
                const CustomStatusBar(),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                        onPressed: widget.onBack,
                      ),
                      const Expanded(child: Text('My Favorites', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                if (accountState is! TmdbAccountAuthenticated)
                  Expanded(child: _buildNotLoggedIn(context, accountState))
                else ...[
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(24)),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(24)),
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      labelColor: Colors.white,
                      unselectedLabelColor: AppColors.textSecondary,
                      labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      tabs: const [Tab(text: 'All'), Tab(text: 'Movies'), Tab(text: 'TV')],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildCombinedTab(accountState.accountId),
                        _buildMoviesTab(accountState.accountId),
                        _buildTVTab(accountState.accountId),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCombinedTab(int accountId) {
    return BlocBuilder<FavoritesCombinedCubit, FavoritesCombinedState>(
      builder: (context, state) {
        if (state is FavoritesCombinedLoading) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        if (state is FavoritesCombinedError) return _buildError(context, state.message, () => context.read<FavoritesCombinedCubit>().loadFavorites(accountId));
        if (state is FavoritesCombinedSuccess) {
          if (state.items.isEmpty) return _buildEmpty(Icons.favorite_border_rounded, 'No Favorites Yet!');
          return RefreshIndicator(
            color: AppColors.primary,
            backgroundColor: AppColors.card,
            onRefresh: () => context.read<FavoritesCombinedCubit>().loadFavorites(accountId, isRefresh: true),
            child: _buildMediaList(state.items, null, state.isFetchingMore, _allScroll),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildMoviesTab(int accountId) {
    return BlocBuilder<FavoriteMoviesCubit, FavoriteMoviesState>(
      builder: (context, state) {
        if (state is FavoriteMoviesLoading) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        if (state is FavoriteMoviesError) return _buildError(context, state.message, () => context.read<FavoriteMoviesCubit>().loadFavoriteMovies(accountId));
        if (state is FavoriteMoviesSuccess) {
          if (state.items.isEmpty) return _buildEmpty(Icons.movie_outlined, 'No Favorite Movies!');
          return RefreshIndicator(
            color: AppColors.primary,
            backgroundColor: AppColors.card,
            onRefresh: () => context.read<FavoriteMoviesCubit>().loadFavoriteMovies(accountId, isRefresh: true),
            child: _buildMediaList(state.items, (item) {
              context.read<FavoriteMoviesCubit>().toggleFavorite(accountId: accountId, movie: item);
            }, state.isFetchingMore, _moviesScroll),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildTVTab(int accountId) {
    return BlocBuilder<FavoriteTVCubit, FavoriteTVState>(
      builder: (context, state) {
        if (state is FavoriteTVLoading) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        if (state is FavoriteTVError) return _buildError(context, state.message, () => context.read<FavoriteTVCubit>().loadFavoriteTV(accountId));
        if (state is FavoriteTVSuccess) {
          if (state.items.isEmpty) return _buildEmpty(Icons.tv_outlined, 'No Favorite Shows!');
          return RefreshIndicator(
            color: AppColors.primary,
            backgroundColor: AppColors.card,
            onRefresh: () => context.read<FavoriteTVCubit>().loadFavoriteTV(accountId, isRefresh: true),
            child: _buildMediaList(state.items, (item) {
              context.read<FavoriteTVCubit>().toggleFavorite(accountId: accountId, show: item);
            }, state.isFetchingMore, _tvScroll),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildMediaList(List<TmdbMediaItem> items, Function(TmdbMediaItem)? onToggle, bool isFetchingMore, ScrollController controller) {
    return ListView.builder(
      controller: controller,
      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: items.length + (isFetchingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == items.length) {
          return const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator(color: AppColors.primary)));
        }
        final item = items[index];
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
                  width: 70, height: 95, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(width: 70, height: 95, color: AppColors.surface, child: const Icon(Icons.movie_outlined, color: AppColors.textSecondary)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: AppColors.primary, size: 14),
                        const SizedBox(width: 4),
                        Text(item.voteAverage.toStringAsFixed(1), style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: item.mediaType == 'movie' ? AppColors.primary.withValues(alpha: 0.2) : AppColors.secondary.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(item.mediaType.toUpperCase(), style: TextStyle(color: item.mediaType == 'movie' ? AppColors.primary : AppColors.secondary, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (onToggle != null)
                IconButton(
                  icon: const Icon(Icons.favorite_rounded, color: AppColors.primary, size: 24),
                  onPressed: () => onToggle(item),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmpty(IconData icon, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(width: 100, height: 100, decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primary.withValues(alpha: 0.15)), child: Icon(icon, color: AppColors.primary, size: 48)),
          const SizedBox(height: 20),
          Text(message, style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Find your favorite type here', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, String message, VoidCallback onRetry) {
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
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
              onPressed: onRetry,
              child: const Text('Retry', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotLoggedIn(BuildContext context, TmdbAccountState state) {
    if (state is TmdbAccountLoading) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline_rounded, color: AppColors.textSecondary, size: 56),
            const SizedBox(height: 20),
            const Text('TMDB Login Required', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Set your TMDB_READ_ACCESS_TOKEN to view favorites.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
              onPressed: () => context.read<TmdbAccountCubit>().loadAccount(),
              child: const Text('Retry Login', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
