import 'package:cinemax_app/core/models/tmdb_media_item.dart';

abstract class FavoritesCombinedState {
  const FavoritesCombinedState();
}

class FavoritesCombinedInitial extends FavoritesCombinedState {
  const FavoritesCombinedInitial();
}

class FavoritesCombinedLoading extends FavoritesCombinedState {
  const FavoritesCombinedLoading();
}

class FavoritesCombinedSuccess extends FavoritesCombinedState {
  final List<TmdbMediaItem> items;
  final int currentPage;
  final int totalPages;
  final bool isFetchingMore;

  const FavoritesCombinedSuccess({
    required this.items,
    required this.currentPage,
    required this.totalPages,
    this.isFetchingMore = false,
  });

  bool get hasMore => currentPage < totalPages;
}

class FavoritesCombinedError extends FavoritesCombinedState {
  final String message;
  const FavoritesCombinedError(this.message);
}
