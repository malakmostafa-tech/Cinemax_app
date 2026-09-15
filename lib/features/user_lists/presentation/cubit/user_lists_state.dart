import 'package:cinemax_app/core/models/tmdb_user_list.dart';

abstract class UserListsState { const UserListsState(); }
class UserListsInitial extends UserListsState { const UserListsInitial(); }
class UserListsLoading extends UserListsState { const UserListsLoading(); }

class UserListsSuccess extends UserListsState {
  final List<TmdbUserList> items;
  final int currentPage;
  final int totalPages;
  final bool isFetchingMore;

  const UserListsSuccess({
    required this.items,
    required this.currentPage,
    required this.totalPages,
    this.isFetchingMore = false,
  });

  bool get hasMore => currentPage < totalPages;
}

class UserListsError extends UserListsState {
  final String message;
  const UserListsError(this.message);
}
