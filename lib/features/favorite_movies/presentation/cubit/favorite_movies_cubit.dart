import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cinemax_app/core/models/tmdb_media_item.dart';
import 'package:cinemax_app/features/favorite_movies/data/favorite_movies_service.dart';
import 'package:cinemax_app/features/favorite_movies/presentation/cubit/favorite_movies_state.dart';

class FavoriteMoviesCubit extends Cubit<FavoriteMoviesState> {
  final FavoriteMoviesService _service;

  FavoriteMoviesCubit({FavoriteMoviesService? service})
      : _service = service ?? FavoriteMoviesService(),
        super(const FavoriteMoviesInitial());

  Future<void> loadFavoriteMovies(int accountId, {bool isRefresh = false, String sortBy = 'created_at.desc'}) async {
    if (!isRefresh && state is FavoriteMoviesLoading) return;
    emit(const FavoriteMoviesLoading());

    try {
      final res = await _service.getFavoriteMovies(accountId, page: 1, sortBy: sortBy);
      final List<TmdbMediaItem> items = res['items'];
      final ids = items.map((i) => i.id).toSet();

      emit(FavoriteMoviesSuccess(
        items: items,
        favoriteMovieIds: ids,
        currentPage: 1,
        totalPages: res['total_pages'] as int,
      ));
    } catch (e) {
      emit(FavoriteMoviesError(e.toString()));
    }
  }

  Future<void> toggleFavorite({required int accountId, required TmdbMediaItem movie}) async {
    final currentState = state;
    if (currentState is! FavoriteMoviesSuccess) return;

    final isCurrentlyFav = currentState.favoriteMovieIds.contains(movie.id);
    final updatedIds = Set<int>.from(currentState.favoriteMovieIds);
    final updatedItems = List<TmdbMediaItem>.from(currentState.items);

    // Optimistic UI Update
    if (isCurrentlyFav) {
      updatedIds.remove(movie.id);
      updatedItems.removeWhere((item) => item.id == movie.id);
    } else {
      updatedIds.add(movie.id);
      updatedItems.insert(0, movie);
    }

    emit(FavoriteMoviesSuccess(
      items: updatedItems,
      favoriteMovieIds: updatedIds,
      currentPage: currentState.currentPage,
      totalPages: currentState.totalPages,
    ));

    try {
      await _service.toggleFavoriteMovie(
        accountId: accountId,
        movieId: movie.id,
        isFavorite: !isCurrentlyFav,
      );
    } catch (e) {
      // Revert optimistic update on failure
      emit(currentState);
    }
  }

  Future<void> fetchNextPage(int accountId, {String sortBy = 'created_at.desc'}) async {
    final currentState = state;
    if (currentState is! FavoriteMoviesSuccess || !currentState.hasMore || currentState.isFetchingMore) {
      return;
    }

    emit(FavoriteMoviesSuccess(
      items: currentState.items,
      favoriteMovieIds: currentState.favoriteMovieIds,
      currentPage: currentState.currentPage,
      totalPages: currentState.totalPages,
      isFetchingMore: true,
    ));

    try {
      final nextPage = currentState.currentPage + 1;
      final res = await _service.getFavoriteMovies(accountId, page: nextPage, sortBy: sortBy);
      final List<TmdbMediaItem> newItems = res['items'];
      final newIds = newItems.map((i) => i.id).toSet();

      emit(FavoriteMoviesSuccess(
        items: [...currentState.items, ...newItems],
        favoriteMovieIds: {...currentState.favoriteMovieIds, ...newIds},
        currentPage: nextPage,
        totalPages: res['total_pages'] as int,
        isFetchingMore: false,
      ));
    } catch (e) {
      emit(currentState);
    }
  }
}
