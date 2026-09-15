import 'package:cinemax_app/core/models/tmdb_media_item.dart';

abstract class FavoriteTVState { const FavoriteTVState(); }
class FavoriteTVInitial extends FavoriteTVState { const FavoriteTVInitial(); }
class FavoriteTVLoading extends FavoriteTVState { const FavoriteTVLoading(); }

class FavoriteTVSuccess extends FavoriteTVState {
  final List<TmdbMediaItem> items;
  final Set<int> favoriteTVIds;
  final int currentPage;
  final int totalPages;
  final bool isFetchingMore;

  const FavoriteTVSuccess({
    required this.items,
    required this.favoriteTVIds,
    required this.currentPage,
    required this.totalPages,
    this.isFetchingMore = false,
  });

  bool get hasMore => currentPage < totalPages;
}

class FavoriteTVError extends FavoriteTVState {
  final String message;
  const FavoriteTVError(this.message);
}
