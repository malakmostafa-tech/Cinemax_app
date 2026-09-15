import 'package:cinemax_app/core/models/tmdb_media_item.dart';

abstract class WatchlistCombinedState { const WatchlistCombinedState(); }
class WatchlistCombinedInitial extends WatchlistCombinedState { const WatchlistCombinedInitial(); }
class WatchlistCombinedLoading extends WatchlistCombinedState { const WatchlistCombinedLoading(); }

class WatchlistCombinedSuccess extends WatchlistCombinedState {
  final List<TmdbMediaItem> items;
  final int currentPage;
  final int totalPages;
  final bool isFetchingMore;
  const WatchlistCombinedSuccess({required this.items, required this.currentPage, required this.totalPages, this.isFetchingMore = false});
  bool get hasMore => currentPage < totalPages;
}

class WatchlistCombinedError extends WatchlistCombinedState {
  final String message;
  const WatchlistCombinedError(this.message);
}
