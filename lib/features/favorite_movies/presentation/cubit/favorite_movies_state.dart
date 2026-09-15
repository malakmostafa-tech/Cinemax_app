import 'package:cinemax_app/core/models/tmdb_media_item.dart';

abstract class FavoriteMoviesState {
  const FavoriteMoviesState();
}

class FavoriteMoviesInitial extends FavoriteMoviesState {
  const FavoriteMoviesInitial();
}

class FavoriteMoviesLoading extends FavoriteMoviesState {
  const FavoriteMoviesLoading();
}

class FavoriteMoviesSuccess extends FavoriteMoviesState {
  final List<TmdbMediaItem> items;
  final Set<int> favoriteMovieIds;
  final int currentPage;
  final int totalPages;
  final bool isFetchingMore;

  const FavoriteMoviesSuccess({
    required this.items,
    required this.favoriteMovieIds,
    required this.currentPage,
    required this.totalPages,
    this.isFetchingMore = false,
  });

  bool get hasMore => currentPage < totalPages;
}

class FavoriteMoviesError extends FavoriteMoviesState {
  final String message;
  const FavoriteMoviesError(this.message);
}
