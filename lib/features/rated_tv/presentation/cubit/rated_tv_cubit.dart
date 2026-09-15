import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cinemax_app/core/models/tmdb_media_item.dart';
import 'package:cinemax_app/features/rated_tv/data/rated_tv_service.dart';
import 'package:cinemax_app/features/rated_tv/presentation/cubit/rated_tv_state.dart';

class RatedTVCubit extends Cubit<RatedTVState> {
  final RatedTVService _service;
  RatedTVCubit({RatedTVService? service}) : _service = service ?? RatedTVService(), super(const RatedTVInitial());

  Future<void> loadRatedTV(int accountId, {bool isRefresh = false, String sortBy = 'created_at.desc'}) async {
    if (!isRefresh && state is RatedTVLoading) return;
    emit(const RatedTVLoading());
    try {
      final res = await _service.getRatedTV(accountId, page: 1, sortBy: sortBy);
      final List<TmdbMediaItem> items = res['items'];
      emit(RatedTVSuccess(items: items, currentPage: 1, totalPages: res['total_pages'] as int));
    } catch (e) {
      emit(RatedTVError(e.toString()));
    }
  }

  Future<void> fetchNextPage(int accountId, {String sortBy = 'created_at.desc'}) async {
    final currentState = state;
    if (currentState is! RatedTVSuccess || !currentState.hasMore || currentState.isFetchingMore) return;
    emit(RatedTVSuccess(items: currentState.items, currentPage: currentState.currentPage, totalPages: currentState.totalPages, isFetchingMore: true));
    try {
      final res = await _service.getRatedTV(accountId, page: currentState.currentPage + 1, sortBy: sortBy);
      final List<TmdbMediaItem> newItems = res['items'];
      emit(RatedTVSuccess(items: [...currentState.items, ...newItems], currentPage: currentState.currentPage + 1, totalPages: res['total_pages'] as int, isFetchingMore: false));
    } catch (_) {
      emit(currentState);
    }
  }
}
