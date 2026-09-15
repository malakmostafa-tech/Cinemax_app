import 'package:cinemax_app/core/api/tmdb_api_client.dart';
import 'package:cinemax_app/core/models/tmdb_user_list.dart';

class UserListsService {
  final TmdbApiClient _apiClient;

  UserListsService({TmdbApiClient? apiClient})
      : _apiClient = apiClient ?? TmdbApiClient();

  Future<Map<String, dynamic>> getUserLists(int accountId, {int page = 1}) async {
    final response = await _apiClient.get(
      '/account/$accountId/lists',
      queryParameters: {'page': page.toString()},
    );

    final List<dynamic> resultsJson = response['results'] ?? [];
    final items = resultsJson.map((j) => TmdbUserList.fromJson(j as Map<String, dynamic>)).toList();

    return {
      'page': response['page'] ?? page,
      'total_pages': response['total_pages'] ?? 1,
      'total_results': response['total_results'] ?? items.length,
      'items': items,
    };
  }
}
