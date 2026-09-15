import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cinemax_app/core/models/tmdb_user_list.dart';
import 'package:cinemax_app/features/user_lists/data/user_lists_service.dart';
import 'package:cinemax_app/features/user_lists/presentation/cubit/user_lists_state.dart';

class UserListsCubit extends Cubit<UserListsState> {
  final UserListsService _service;

  UserListsCubit({UserListsService? service})
      : _service = service ?? UserListsService(),
        super(const UserListsInitial());

  Future<void> loadUserLists(int accountId, {bool isRefresh = false}) async {
    if (!isRefresh && state is UserListsLoading) return;
    emit(const UserListsLoading());
    try {
      final res = await _service.getUserLists(accountId, page: 1);
      final List<TmdbUserList> items = res['items'];
      emit(UserListsSuccess(items: items, currentPage: 1, totalPages: res['total_pages'] as int));
    } catch (e) {
      emit(UserListsError(e.toString()));
    }
  }

  Future<void> fetchNextPage(int accountId) async {
    final currentState = state;
    if (currentState is! UserListsSuccess || !currentState.hasMore || currentState.isFetchingMore) return;

    emit(UserListsSuccess(
      items: currentState.items,
      currentPage: currentState.currentPage,
      totalPages: currentState.totalPages,
      isFetchingMore: true,
    ));

    try {
      final res = await _service.getUserLists(accountId, page: currentState.currentPage + 1);
      final List<TmdbUserList> newItems = res['items'];
      emit(UserListsSuccess(
        items: [...currentState.items, ...newItems],
        currentPage: currentState.currentPage + 1,
        totalPages: res['total_pages'] as int,
        isFetchingMore: false,
      ));
    } catch (_) {
      emit(currentState);
    }
  }
}
