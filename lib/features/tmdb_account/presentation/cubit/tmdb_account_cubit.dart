import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cinemax_app/core/api/tmdb_account_service.dart';
import 'package:cinemax_app/features/tmdb_account/presentation/cubit/tmdb_account_state.dart';

class TmdbAccountCubit extends Cubit<TmdbAccountState> {
  final TmdbAccountService _service;

  TmdbAccountCubit({TmdbAccountService? service})
      : _service = service ?? TmdbAccountService(),
        super(const TmdbAccountInitial());

  Future<void> loadAccount() async {
    emit(const TmdbAccountLoading());
    try {
      final data = await _service.getAccountDetails();
      final accountId = data['id'] as int?;
      final username = data['username'] as String? ?? 'User';

      if (accountId == null) {
        emit(const TmdbAccountError('Account ID not found. Please verify your TMDB token.'));
        return;
      }

      emit(TmdbAccountAuthenticated(accountId: accountId, username: username));
    } catch (e) {
      emit(TmdbAccountError(e.toString()));
    }
  }
}
