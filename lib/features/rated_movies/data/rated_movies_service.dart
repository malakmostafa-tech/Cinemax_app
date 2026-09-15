import 'package:cinemax_app/core/api/tmdb_api_client.dart';
import 'package:cinemax_app/core/models/tmdb_media_item.dart';

class RatedMoviesService {
  final TmdbApiClient _apiClient;
  RatedMoviesService({TmdbApiClient? apiClient}) : _apiClient = apiClient ?? TmdbApiClient();

  Future<Map<String, dynamic>> getRatedMovies(int accountId, {int page = 1, String sortBy = 'created_at.desc'}) async {
    final response = await _apiClient.get(
      '/account/$accountId/rated/movies',
      queryParameters: {'page': page.toString(), 'sort_by': sortBy},
    );
    final List<dynamic> resultsJson = response['results'] ?? [];
    final items = resultsJson.map((j) => TmdbMediaItem.fromJson(j, defaultMediaType: 'movie')).toList();
    return {
      'page': response['page'] ?? page,
      'total_pages': response['total_pages'] ?? 1,
      'total_results': response['total_results'] ?? items.length,
      'items': items,
    };
  }
}
