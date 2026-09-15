import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cinemax_app/core/models/tmdb_media_item.dart';
import 'package:cinemax_app/features/watchlist_movies/data/watchlist_movies_service.dart';
import 'package:cinemax_app/features/watchlist_movies/presentation/cubit/watchlist_movies_state.dart';

class WatchlistMoviesCubit extends Cubit<WatchlistMoviesState> {
  final WatchlistMoviesService _service;
  WatchlistMoviesCubit({WatchlistMoviesService? service}) : _service = service ?? WatchlistMoviesService(), super(const WatchlistMoviesInitial());

  Future<void> loadWatchlistMovies(int accountId, {bool isRefresh = false, String sortBy = 'created_at.desc'}) async {
    if (!isRefresh && state is WatchlistMoviesLoading) return;
    emit(const WatchlistMoviesLoading());
    try {
      final res = await _service.getWatchlistMovies(accountId, page: 1, sortBy: sortBy);
      final List<TmdbMediaItem> items = res['items'];
      emit(WatchlistMoviesSuccess(items: items, watchlistMovieIds: items.map((i) => i.id).toSet(), currentPage: 1, totalPages: res['total_pages'] as int));
    } catch (e) {
      emit(WatchlistMoviesError(e.toString()));
    }
  }

  Future<void> toggleWatchlist({required int accountId, required TmdbMediaItem movie}) async {
    final currentState = state;
    if (currentState is! WatchlistMoviesSuccess) return;

    final isCurrentlyWatchlisted = currentState.watchlistMovieIds.contains(movie.id);
    final updatedIds = Set<int>.from(currentState.watchlistMovieIds);
    final updatedItems = List<TmdbMediaItem>.from(currentState.items);

    if (isCurrentlyWatchlisted) {
      updatedIds.remove(movie.id);
      updatedItems.removeWhere((item) => item.id == movie.id);
    } else {
      updatedIds.add(movie.id);
      updatedItems.insert(0, movie);
    }

    emit(WatchlistMoviesSuccess(items: updatedItems, watchlistMovieIds: updatedIds, currentPage: currentState.currentPage, totalPages: currentState.totalPages));

    try {
      await _service.toggleWatchlistMovie(accountId: accountId, movieId: movie.id, isWatchlist: !isCurrentlyWatchlisted);
    } catch (_) {
      emit(currentState);
    }
  }

  Future<void> fetchNextPage(int accountId, {String sortBy = 'created_at.desc'}) async {
    final currentState = state;
    if (currentState is! WatchlistMoviesSuccess || !currentState.hasMore || currentState.isFetchingMore) return;
    emit(WatchlistMoviesSuccess(items: currentState.items, watchlistMovieIds: currentState.watchlistMovieIds, currentPage: currentState.currentPage, totalPages: currentState.totalPages, isFetchingMore: true));
    try {
      final res = await _service.getWatchlistMovies(accountId, page: currentState.currentPage + 1, sortBy: sortBy);
      final List<TmdbMediaItem> newItems = res['items'];
      emit(WatchlistMoviesSuccess(items: [...currentState.items, ...newItems], watchlistMovieIds: {...currentState.watchlistMovieIds, ...newItems.map((i) => i.id)}, currentPage: currentState.currentPage + 1, totalPages: res['total_pages'] as int, isFetchingMore: false));
    } catch (_) {
      emit(currentState);
    }
  }
}
