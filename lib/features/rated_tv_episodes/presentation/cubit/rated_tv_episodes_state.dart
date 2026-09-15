import 'package:cinemax_app/core/models/tmdb_media_item.dart';

abstract class RatedTVEpisodesState { const RatedTVEpisodesState(); }
class RatedTVEpisodesInitial extends RatedTVEpisodesState { const RatedTVEpisodesInitial(); }
class RatedTVEpisodesLoading extends RatedTVEpisodesState { const RatedTVEpisodesLoading(); }

class RatedTVEpisodesSuccess extends RatedTVEpisodesState {
  final List<TmdbMediaItem> items;
  final int currentPage;
  final int totalPages;
  final bool isFetchingMore;
  const RatedTVEpisodesSuccess({required this.items, required this.currentPage, required this.totalPages, this.isFetchingMore = false});
  bool get hasMore => currentPage < totalPages;
}

class RatedTVEpisodesError extends RatedTVEpisodesState {
  final String message;
  const RatedTVEpisodesError(this.message);
}
