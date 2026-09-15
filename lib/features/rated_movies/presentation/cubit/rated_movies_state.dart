import 'package:cinemax_app/core/models/tmdb_media_item.dart';

abstract class RatedMoviesState { const RatedMoviesState(); }
class RatedMoviesInitial extends RatedMoviesState { const RatedMoviesInitial(); }
class RatedMoviesLoading extends RatedMoviesState { const RatedMoviesLoading(); }

class RatedMoviesSuccess extends RatedMoviesState {
  final List<TmdbMediaItem> items;
  final int currentPage;
  final int totalPages;
  final bool isFetchingMore;
  const RatedMoviesSuccess({required this.items, required this.currentPage, required this.totalPages, this.isFetchingMore = false});
  bool get hasMore => currentPage < totalPages;
}

class RatedMoviesError extends RatedMoviesState {
  final String message;
  const RatedMoviesError(this.message);
}
