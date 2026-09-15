import 'package:cinemax_app/core/models/tmdb_media_item.dart';

abstract class RatedTVState { const RatedTVState(); }
class RatedTVInitial extends RatedTVState { const RatedTVInitial(); }
class RatedTVLoading extends RatedTVState { const RatedTVLoading(); }

class RatedTVSuccess extends RatedTVState {
  final List<TmdbMediaItem> items;
  final int currentPage;
  final int totalPages;
  final bool isFetchingMore;
  const RatedTVSuccess({required this.items, required this.currentPage, required this.totalPages, this.isFetchingMore = false});
  bool get hasMore => currentPage < totalPages;
}

class RatedTVError extends RatedTVState {
  final String message;
  const RatedTVError(this.message);
}
