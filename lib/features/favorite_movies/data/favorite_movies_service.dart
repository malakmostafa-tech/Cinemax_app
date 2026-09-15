import 'package:cinemax_app/core/api/tmdb_api_client.dart';
import 'package:cinemax_app/core/models/tmdb_media_item.dart';

class FavoriteMoviesService {
  final TmdbApiClient _apiClient;

  FavoriteMoviesService({TmdbApiClient? apiClient})
      : _apiClient = apiClient ?? TmdbApiClient();

  Future<Map<String, dynamic>> getFavoriteMovies(
    int accountId, {
    int page = 1,
    String sortBy = 'created_at.desc',
  }) async {
    final response = await _apiClient.get(
      '/account/$accountId/favorite/movies',
      queryParameters: {
        'page': page.toString(),
        'sort_by': sortBy,
      },
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

  Future<bool> toggleFavoriteMovie({
    required int accountId,
    required int movieId,
    required bool isFavorite,
  }) async {
    final response = await _apiClient.post(
      '/account/$accountId/favorite',
      body: {
        'media_type': 'movie',
        'media_id': movieId,
        'favorite': isFavorite,
      },
    );
    return (response['success'] as bool?) ?? true;
  }
}
