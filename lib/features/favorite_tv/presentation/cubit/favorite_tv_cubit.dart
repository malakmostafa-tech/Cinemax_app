import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cinemax_app/core/models/tmdb_media_item.dart';
import 'package:cinemax_app/features/favorite_tv/data/favorite_tv_service.dart';
import 'package:cinemax_app/features/favorite_tv/presentation/cubit/favorite_tv_state.dart';

class FavoriteTVCubit extends Cubit<FavoriteTVState> {
  final FavoriteTVService _service;

  FavoriteTVCubit({FavoriteTVService? service})
      : _service = service ?? FavoriteTVService(),
        super(const FavoriteTVInitial());

  Future<void> loadFavoriteTV(int accountId, {bool isRefresh = false, String sortBy = 'created_at.desc'}) async {
    if (!isRefresh && state is FavoriteTVLoading) return;
    emit(const FavoriteTVLoading());
    try {
      final res = await _service.getFavoriteTV(accountId, page: 1, sortBy: sortBy);
      final List<TmdbMediaItem> items = res['items'];
      emit(FavoriteTVSuccess(
        items: items,
        favoriteTVIds: items.map((i) => i.id).toSet(),
        currentPage: 1,
        totalPages: res['total_pages'] as int,
      ));
    } catch (e) {
      emit(FavoriteTVError(e.toString()));
    }
  }

  Future<void> toggleFavorite({required int accountId, required TmdbMediaItem show}) async {
    final currentState = state;
    if (currentState is! FavoriteTVSuccess) return;

    final isCurrentlyFav = currentState.favoriteTVIds.contains(show.id);
    final updatedIds = Set<int>.from(currentState.favoriteTVIds);
    final updatedItems = List<TmdbMediaItem>.from(currentState.items);

    if (isCurrentlyFav) {
      updatedIds.remove(show.id);
      updatedItems.removeWhere((item) => item.id == show.id);
    } else {
      updatedIds.add(show.id);
      updatedItems.insert(0, show);
    }

    emit(FavoriteTVSuccess(
      items: updatedItems,
      favoriteTVIds: updatedIds,
      currentPage: currentState.currentPage,
      totalPages: currentState.totalPages,
    ));

    try {
      await _service.toggleFavoriteTV(accountId: accountId, tvId: show.id, isFavorite: !isCurrentlyFav);
    } catch (_) {
      emit(currentState);
    }
  }

  Future<void> fetchNextPage(int accountId, {String sortBy = 'created_at.desc'}) async {
    final currentState = state;
    if (currentState is! FavoriteTVSuccess || !currentState.hasMore || currentState.isFetchingMore) return;

    emit(FavoriteTVSuccess(
      items: currentState.items,
      favoriteTVIds: currentState.favoriteTVIds,
      currentPage: currentState.currentPage,
      totalPages: currentState.totalPages,
      isFetchingMore: true,
    ));

    try {
      final res = await _service.getFavoriteTV(accountId, page: currentState.currentPage + 1, sortBy: sortBy);
      final List<TmdbMediaItem> newItems = res['items'];
      emit(FavoriteTVSuccess(
        items: [...currentState.items, ...newItems],
        favoriteTVIds: {...currentState.favoriteTVIds, ...newItems.map((i) => i.id)},
        currentPage: currentState.currentPage + 1,
        totalPages: res['total_pages'] as int,
        isFetchingMore: false,
      ));
    } catch (_) {
      emit(currentState);
    }
  }
}
