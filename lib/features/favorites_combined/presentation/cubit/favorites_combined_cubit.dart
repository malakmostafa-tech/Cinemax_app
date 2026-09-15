import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cinemax_app/core/models/tmdb_media_item.dart';
import 'package:cinemax_app/features/favorites_combined/data/favorites_combined_service.dart';
import 'package:cinemax_app/features/favorites_combined/presentation/cubit/favorites_combined_state.dart';

class FavoritesCombinedCubit extends Cubit<FavoritesCombinedState> {
  final FavoritesCombinedService _service;

  FavoritesCombinedCubit({FavoritesCombinedService? service})
      : _service = service ?? FavoritesCombinedService(),
        super(const FavoritesCombinedInitial());

  Future<void> loadFavorites(int accountId, {bool isRefresh = false}) async {
    if (!isRefresh && state is FavoritesCombinedLoading) return;
    emit(const FavoritesCombinedLoading());

    try {
      final res = await _service.getFavorites(accountId, page: 1);
      final List<TmdbMediaItem> items = res['items'];
      final totalPages = res['total_pages'] as int;

      emit(FavoritesCombinedSuccess(
        items: items,
        currentPage: 1,
        totalPages: totalPages,
      ));
    } catch (e) {
      emit(FavoritesCombinedError(e.toString()));
    }
  }

  Future<void> fetchNextPage(int accountId) async {
    final currentState = state;
    if (currentState is! FavoritesCombinedSuccess || !currentState.hasMore || currentState.isFetchingMore) {
      return;
    }

    emit(FavoritesCombinedSuccess(
      items: currentState.items,
      currentPage: currentState.currentPage,
      totalPages: currentState.totalPages,
      isFetchingMore: true,
    ));

    try {
      final nextPage = currentState.currentPage + 1;
      final res = await _service.getFavorites(accountId, page: nextPage);
      final List<TmdbMediaItem> newItems = res['items'];

      emit(FavoritesCombinedSuccess(
        items: [...currentState.items, ...newItems],
        currentPage: nextPage,
        totalPages: res['total_pages'] as int,
        isFetchingMore: false,
      ));
    } catch (e) {
      emit(currentState);
    }
  }
}
