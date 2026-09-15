abstract class TmdbAccountState { const TmdbAccountState(); }
class TmdbAccountInitial extends TmdbAccountState { const TmdbAccountInitial(); }
class TmdbAccountLoading extends TmdbAccountState { const TmdbAccountLoading(); }

class TmdbAccountAuthenticated extends TmdbAccountState {
  final int accountId;
  final String username;
  const TmdbAccountAuthenticated({required this.accountId, required this.username});
}

class TmdbAccountError extends TmdbAccountState {
  final String message;
  const TmdbAccountError(this.message);
}
