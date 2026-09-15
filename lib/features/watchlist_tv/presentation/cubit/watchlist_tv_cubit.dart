import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cinemax_app/core/models/tmdb_media_item.dart';
import 'package:cinemax_app/features/watchlist_tv/data/watchlist_tv_service.dart';
import 'package:cinemax_app/features/watchlist_tv/presentation/cubit/watchlist_tv_state.dart';

class WatchlistTVCubit extends Cubit<WatchlistTVState> {
  final WatchlistTVService _service;
  WatchlistTVCubit({WatchlistTVService? service}) : _service = service ?? WatchlistTVService(), super(const WatchlistTVInitial());

  Future<void> loadWatchlistTV(int accountId, {bool isRefresh = false, String sortBy = 'created_at.desc'}) async {
    if (!isRefresh && state is WatchlistTVLoading) return;
    emit(const WatchlistTVLoading());
    try {
      final res = await _service.getWatchlistTV(accountId, page: 1, sortBy: sortBy);
      final List<TmdbMediaItem> items = res['items'];
      emit(WatchlistTVSuccess(items: items, watchlistTVIds: items.map((i) => i.id).toSet(), currentPage: 1, totalPages: res['total_pages'] as int));
    } catch (e) {
      emit(WatchlistTVError(e.toString()));
    }
  }

  Future<void> toggleWatchlist({required int accountId, required TmdbMediaItem show}) async {
    final currentState = state;
    if (currentState is! WatchlistTVSuccess) return;

    final isCurrentlyWatchlisted = currentState.watchlistTVIds.contains(show.id);
    final updatedIds = Set<int>.from(currentState.watchlistTVIds);
    final updatedItems = List<TmdbMediaItem>.from(currentState.items);

    if (isCurrentlyWatchlisted) {
      updatedIds.remove(show.id);
      updatedItems.removeWhere((item) => item.id == show.id);
    } else {
      updatedIds.add(show.id);
      updatedItems.insert(0, show);
    }

    emit(WatchlistTVSuccess(items: updatedItems, watchlistTVIds: updatedIds, currentPage: currentState.currentPage, totalPages: currentState.totalPages));

    try {
      await _service.toggleWatchlistTV(accountId: accountId, tvId: show.id, isWatchlist: !isCurrentlyWatchlisted);
    } catch (_) {
      emit(currentState);
    }
  }

  Future<void> fetchNextPage(int accountId, {String sortBy = 'created_at.desc'}) async {
    final currentState = state;
    if (currentState is! WatchlistTVSuccess || !currentState.hasMore || currentState.isFetchingMore) return;
    emit(WatchlistTVSuccess(items: currentState.items, watchlistTVIds: currentState.watchlistTVIds, currentPage: currentState.currentPage, totalPages: currentState.totalPages, isFetchingMore: true));
    try {
      final res = await _service.getWatchlistTV(accountId, page: currentState.currentPage + 1, sortBy: sortBy);
      final List<TmdbMediaItem> newItems = res['items'];
      emit(WatchlistTVSuccess(items: [...currentState.items, ...newItems], watchlistTVIds: {...currentState.watchlistTVIds, ...newItems.map((i) => i.id)}, currentPage: currentState.currentPage + 1, totalPages: res['total_pages'] as int, isFetchingMore: false));
    } catch (_) {
      emit(currentState);
    }
  }
}
