import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cinemax_app/core/app_colors.dart';
import 'package:cinemax_app/core/models/tmdb_media_item.dart';
import 'package:cinemax_app/features/tmdb_account/presentation/cubit/tmdb_account_cubit.dart';
import 'package:cinemax_app/features/tmdb_account/presentation/cubit/tmdb_account_state.dart';
import 'package:cinemax_app/features/watchlist_combined/presentation/cubit/watchlist_combined_cubit.dart';
import 'package:cinemax_app/features/watchlist_combined/presentation/cubit/watchlist_combined_state.dart';
import 'package:cinemax_app/features/watchlist_movies/presentation/cubit/watchlist_movies_cubit.dart';
import 'package:cinemax_app/features/watchlist_movies/presentation/cubit/watchlist_movies_state.dart';
import 'package:cinemax_app/features/watchlist_tv/presentation/cubit/watchlist_tv_cubit.dart';
import 'package:cinemax_app/features/watchlist_tv/presentation/cubit/watchlist_tv_state.dart';
import 'package:cinemax_app/features/movie/presentation/widgets/custom_status_bar.dart';

class TmdbWatchlistScreen extends StatefulWidget {
  final VoidCallback onBack;

  const TmdbWatchlistScreen({super.key, required this.onBack});

  @override
  State<TmdbWatchlistScreen> createState() => _TmdbWatchlistScreenState();
}

class _TmdbWatchlistScreenState extends State<TmdbWatchlistScreen> with SingleTickerProviderStateMixin {
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
      context.read<WatchlistCombinedCubit>().loadWatchlist(id);
      context.read<WatchlistMoviesCubit>().loadWatchlistMovies(id);
      context.read<WatchlistTVCubit>().loadWatchlistTV(id);
    }

    _moviesScroll.addListener(() {
      final accountState = context.read<TmdbAccountCubit>().state;
      if (accountState is TmdbAccountAuthenticated &&
          _moviesScroll.position.pixels >= _moviesScroll.position.maxScrollExtent - 200) {
        context.read<WatchlistMoviesCubit>().fetchNextPage(accountState.accountId);
      }
    });
    _tvScroll.addListener(() {
      final accountState = context.read<TmdbAccountCubit>().state;
      if (accountState is TmdbAccountAuthenticated &&
          _tvScroll.position.pixels >= _tvScroll.position.maxScrollExtent - 200) {
        context.read<WatchlistTVCubit>().fetchNextPage(accountState.accountId);
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
                      const Expanded(
                        child: Text(
                          'Watchlist',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                if (accountState is! TmdbAccountAuthenticated)
                  Expanded(child: _buildNotLoggedIn(context, accountState))
                else ...[
                  // Tab Bar
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      labelColor: AppColors.backgroundDark,
                      unselectedLabelColor: AppColors.textSecondary,
                      labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      tabs: const [
                        Tab(text: 'All'),
                        Tab(text: 'Movies'),
                        Tab(text: 'TV'),
                      ],
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
    return BlocBuilder<WatchlistCombinedCubit, WatchlistCombinedState>(
      builder: (context, state) {
        if (state is WatchlistCombinedLoading) return const Center(child: CircularProgressIndicator(color: AppColors.secondary));
        if (state is WatchlistCombinedError) return _buildError(context, state.message, () => context.read<WatchlistCombinedCubit>().loadWatchlist(accountId));
        if (state is WatchlistCombinedSuccess) {
          if (state.items.isEmpty) return _buildEmpty();
          return RefreshIndicator(
            color: AppColors.secondary,
            backgroundColor: AppColors.card,
            onRefresh: () => context.read<WatchlistCombinedCubit>().loadWatchlist(accountId, isRefresh: true),
            child: _buildList(state.items, null, state.isFetchingMore, _allScroll),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildMoviesTab(int accountId) {
    return BlocBuilder<WatchlistMoviesCubit, WatchlistMoviesState>(
      builder: (context, state) {
        if (state is WatchlistMoviesLoading) return const Center(child: CircularProgressIndicator(color: AppColors.secondary));
        if (state is WatchlistMoviesError) return _buildError(context, state.message, () => context.read<WatchlistMoviesCubit>().loadWatchlistMovies(accountId));
        if (state is WatchlistMoviesSuccess) {
          if (state.items.isEmpty) return _buildEmpty();
          return RefreshIndicator(
            color: AppColors.secondary,
            backgroundColor: AppColors.card,
            onRefresh: () => context.read<WatchlistMoviesCubit>().loadWatchlistMovies(accountId, isRefresh: true),
            child: _buildList(state.items, (item) {
              context.read<WatchlistMoviesCubit>().toggleWatchlist(accountId: accountId, movie: item);
            }, state.isFetchingMore, _moviesScroll),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildTVTab(int accountId) {
    return BlocBuilder<WatchlistTVCubit, WatchlistTVState>(
      builder: (context, state) {
        if (state is WatchlistTVLoading) return const Center(child: CircularProgressIndicator(color: AppColors.secondary));
        if (state is WatchlistTVError) return _buildError(context, state.message, () => context.read<WatchlistTVCubit>().loadWatchlistTV(accountId));
        if (state is WatchlistTVSuccess) {
          if (state.items.isEmpty) return _buildEmpty();
          return RefreshIndicator(
            color: AppColors.secondary,
            backgroundColor: AppColors.card,
            onRefresh: () => context.read<WatchlistTVCubit>().loadWatchlistTV(accountId, isRefresh: true),
            child: _buildList(state.items, (item) {
              context.read<WatchlistTVCubit>().toggleWatchlist(accountId: accountId, show: item);
            }, state.isFetchingMore, _tvScroll),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildList(List<TmdbMediaItem> items, Function(TmdbMediaItem)? onRemove, bool isFetchingMore, ScrollController controller) {
    return ListView.builder(
      controller: controller,
      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: items.length + (isFetchingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == items.length) {
          return const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator(color: AppColors.secondary)));
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
                  width: 70,
                  height: 95,
                  fit: BoxFit.cover,
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
                    if (item.releaseDate.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(item.releaseDate.length >= 4 ? item.releaseDate.substring(0, 4) : item.releaseDate, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    ],
                  ],
                ),
              ),
              if (onRemove != null)
                IconButton(
                  icon: const Icon(Icons.bookmark_remove_outlined, color: AppColors.secondary, size: 24),
                  onPressed: () => onRemove(item),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100, height: 100,
            decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.secondary.withValues(alpha: 0.15)),
            child: const Icon(Icons.bookmark_outline_rounded, color: AppColors.secondary, size: 48),
          ),
          const SizedBox(height: 20),
          const Text('There Is No Movie Yet!', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
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
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
              onPressed: onRetry,
              child: const Text('Retry', style: TextStyle(color: AppColors.backgroundDark, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotLoggedIn(BuildContext context, TmdbAccountState state) {
    if (state is TmdbAccountLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.secondary));
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline_rounded, color: AppColors.textSecondary, size: 56),
            const SizedBox(height: 20),
            const Text('Please Log In With TMDB', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Set your TMDB_READ_ACCESS_TOKEN to see your watchlist.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
              onPressed: () => context.read<TmdbAccountCubit>().loadAccount(),
              child: const Text('Retry Login', style: TextStyle(color: AppColors.backgroundDark, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
