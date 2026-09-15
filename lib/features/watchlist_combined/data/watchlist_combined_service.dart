import 'package:cinemax_app/core/api/tmdb_api_client.dart';
import 'package:cinemax_app/core/models/tmdb_media_item.dart';

class WatchlistCombinedService {
  final TmdbApiClient _apiClient;
  WatchlistCombinedService({TmdbApiClient? apiClient}) : _apiClient = apiClient ?? TmdbApiClient();

  Future<Map<String, dynamic>> getWatchlist(int accountId, {int page = 1}) async {
    // Fetch both movies and TV in parallel
    final results = await Future.wait([
      _apiClient.get('/account/$accountId/watchlist/movies', queryParameters: {'page': page.toString()}),
      _apiClient.get('/account/$accountId/watchlist/tv', queryParameters: {'page': page.toString()}),
    ]);

    final movieResults = (results[0]['results'] as List? ?? [])
        .map((j) => TmdbMediaItem.fromJson(j, defaultMediaType: 'movie'))
        .toList();
    final tvResults = (results[1]['results'] as List? ?? [])
        .map((j) => TmdbMediaItem.fromJson(j, defaultMediaType: 'tv'))
        .toList();

    final allItems = [...movieResults, ...tvResults];
    final totalPages = (results[0]['total_pages'] as int? ?? 1) + (results[1]['total_pages'] as int? ?? 1);

    return {
      'page': page,
      'total_pages': totalPages,
      'total_results': (results[0]['total_results'] as int? ?? 0) + (results[1]['total_results'] as int? ?? 0),
      'items': allItems,
    };
  }
}
