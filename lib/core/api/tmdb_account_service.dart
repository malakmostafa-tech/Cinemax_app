import 'package:cinemax_app/core/api/tmdb_api_client.dart';

class TmdbAccountService {
  final TmdbApiClient _apiClient;

  TmdbAccountService({TmdbApiClient? apiClient})
      : _apiClient = apiClient ?? TmdbApiClient();

  Future<Map<String, dynamic>> getAccountDetails() async {
    final data = await _apiClient.get('/account');
    return data;
  }
}
