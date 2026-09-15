import 'package:cinemax_app/core/models/tmdb_media_item.dart';

abstract class WatchlistMoviesState { const WatchlistMoviesState(); }
class WatchlistMoviesInitial extends WatchlistMoviesState { const WatchlistMoviesInitial(); }
class WatchlistMoviesLoading extends WatchlistMoviesState { const WatchlistMoviesLoading(); }

class WatchlistMoviesSuccess extends WatchlistMoviesState {
  final List<TmdbMediaItem> items;
  final Set<int> watchlistMovieIds;
  final int currentPage;
  final int totalPages;
  final bool isFetchingMore;
  const WatchlistMoviesSuccess({required this.items, required this.watchlistMovieIds, required this.currentPage, required this.totalPages, this.isFetchingMore = false});
  bool get hasMore => currentPage < totalPages;
}

class WatchlistMoviesError extends WatchlistMoviesState {
  final String message;
  const WatchlistMoviesError(this.message);
}
