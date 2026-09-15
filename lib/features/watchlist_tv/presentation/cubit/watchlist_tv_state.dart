import 'package:cinemax_app/core/models/tmdb_media_item.dart';

abstract class WatchlistTVState { const WatchlistTVState(); }
class WatchlistTVInitial extends WatchlistTVState { const WatchlistTVInitial(); }
class WatchlistTVLoading extends WatchlistTVState { const WatchlistTVLoading(); }

class WatchlistTVSuccess extends WatchlistTVState {
  final List<TmdbMediaItem> items;
  final Set<int> watchlistTVIds;
  final int currentPage;
  final int totalPages;
  final bool isFetchingMore;
  const WatchlistTVSuccess({required this.items, required this.watchlistTVIds, required this.currentPage, required this.totalPages, this.isFetchingMore = false});
  bool get hasMore => currentPage < totalPages;
}

class WatchlistTVError extends WatchlistTVState {
  final String message;
  const WatchlistTVError(this.message);
}
