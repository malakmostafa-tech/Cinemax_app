import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cinemax_app/core/models/tmdb_media_item.dart';
import 'package:cinemax_app/features/rated_movies/data/rated_movies_service.dart';
import 'package:cinemax_app/features/rated_movies/presentation/cubit/rated_movies_state.dart';

class RatedMoviesCubit extends Cubit<RatedMoviesState> {
  final RatedMoviesService _service;
  RatedMoviesCubit({RatedMoviesService? service}) : _service = service ?? RatedMoviesService(), super(const RatedMoviesInitial());

  Future<void> loadRatedMovies(int accountId, {bool isRefresh = false, String sortBy = 'created_at.desc'}) async {
    if (!isRefresh && state is RatedMoviesLoading) return;
    emit(const RatedMoviesLoading());
    try {
      final res = await _service.getRatedMovies(accountId, page: 1, sortBy: sortBy);
      final List<TmdbMediaItem> items = res['items'];
      emit(RatedMoviesSuccess(items: items, currentPage: 1, totalPages: res['total_pages'] as int));
    } catch (e) {
      emit(RatedMoviesError(e.toString()));
    }
  }

  Future<void> fetchNextPage(int accountId, {String sortBy = 'created_at.desc'}) async {
    final currentState = state;
    if (currentState is! RatedMoviesSuccess || !currentState.hasMore || currentState.isFetchingMore) return;
    emit(RatedMoviesSuccess(items: currentState.items, currentPage: currentState.currentPage, totalPages: currentState.totalPages, isFetchingMore: true));
    try {
      final res = await _service.getRatedMovies(accountId, page: currentState.currentPage + 1, sortBy: sortBy);
      final List<TmdbMediaItem> newItems = res['items'];
      emit(RatedMoviesSuccess(items: [...currentState.items, ...newItems], currentPage: currentState.currentPage + 1, totalPages: res['total_pages'] as int, isFetchingMore: false));
    } catch (_) {
      emit(currentState);
    }
  }
}
