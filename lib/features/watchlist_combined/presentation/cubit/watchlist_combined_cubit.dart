import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cinemax_app/core/models/tmdb_media_item.dart';
import 'package:cinemax_app/features/watchlist_combined/data/watchlist_combined_service.dart';
import 'package:cinemax_app/features/watchlist_combined/presentation/cubit/watchlist_combined_state.dart';

class WatchlistCombinedCubit extends Cubit<WatchlistCombinedState> {
  final WatchlistCombinedService _service;
  WatchlistCombinedCubit({WatchlistCombinedService? service}) : _service = service ?? WatchlistCombinedService(), super(const WatchlistCombinedInitial());

  Future<void> loadWatchlist(int accountId, {bool isRefresh = false}) async {
    if (!isRefresh && state is WatchlistCombinedLoading) return;
    emit(const WatchlistCombinedLoading());
    try {
      final res = await _service.getWatchlist(accountId, page: 1);
      final List<TmdbMediaItem> items = res['items'];
      emit(WatchlistCombinedSuccess(items: items, currentPage: 1, totalPages: res['total_pages'] as int));
    } catch (e) {
      emit(WatchlistCombinedError(e.toString()));
    }
  }

  Future<void> fetchNextPage(int accountId) async {
    final currentState = state;
    if (currentState is! WatchlistCombinedSuccess || !currentState.hasMore || currentState.isFetchingMore) return;
    emit(WatchlistCombinedSuccess(items: currentState.items, currentPage: currentState.currentPage, totalPages: currentState.totalPages, isFetchingMore: true));
    try {
      final res = await _service.getWatchlist(accountId, page: currentState.currentPage + 1);
      final List<TmdbMediaItem> newItems = res['items'];
      emit(WatchlistCombinedSuccess(items: [...currentState.items, ...newItems], currentPage: currentState.currentPage + 1, totalPages: res['total_pages'] as int, isFetchingMore: false));
    } catch (_) {
      emit(currentState);
    }
  }
}
