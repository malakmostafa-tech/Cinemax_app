import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cinemax_app/core/models/tmdb_media_item.dart';
import 'package:cinemax_app/features/rated_tv_episodes/data/rated_tv_episodes_service.dart';
import 'package:cinemax_app/features/rated_tv_episodes/presentation/cubit/rated_tv_episodes_state.dart';

class RatedTVEpisodesCubit extends Cubit<RatedTVEpisodesState> {
  final RatedTVEpisodesService _service;
  RatedTVEpisodesCubit({RatedTVEpisodesService? service}) : _service = service ?? RatedTVEpisodesService(), super(const RatedTVEpisodesInitial());

  Future<void> loadRatedEpisodes(int accountId, {bool isRefresh = false, String sortBy = 'created_at.desc'}) async {
    if (!isRefresh && state is RatedTVEpisodesLoading) return;
    emit(const RatedTVEpisodesLoading());
    try {
      final res = await _service.getRatedTVEpisodes(accountId, page: 1, sortBy: sortBy);
      final List<TmdbMediaItem> items = res['items'];
      emit(RatedTVEpisodesSuccess(items: items, currentPage: 1, totalPages: res['total_pages'] as int));
    } catch (e) {
      emit(RatedTVEpisodesError(e.toString()));
    }
  }

  Future<void> fetchNextPage(int accountId, {String sortBy = 'created_at.desc'}) async {
    final currentState = state;
    if (currentState is! RatedTVEpisodesSuccess || !currentState.hasMore || currentState.isFetchingMore) return;
    emit(RatedTVEpisodesSuccess(items: currentState.items, currentPage: currentState.currentPage, totalPages: currentState.totalPages, isFetchingMore: true));
    try {
      final res = await _service.getRatedTVEpisodes(accountId, page: currentState.currentPage + 1, sortBy: sortBy);
      final List<TmdbMediaItem> newItems = res['items'];
      emit(RatedTVEpisodesSuccess(items: [...currentState.items, ...newItems], currentPage: currentState.currentPage + 1, totalPages: res['total_pages'] as int, isFetchingMore: false));
    } catch (_) {
      emit(currentState);
    }
  }
}
