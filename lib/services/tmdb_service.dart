import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cinemax_app/features/movie/domain/entities/movie.dart';
import 'package:cinemax_app/features/movie/domain/entities/actor.dart';

class TMDBService {
  static const _baseUrl = 'https://api.themoviedb.org/3';
  static const _imageBase = 'https://image.tmdb.org/t/p/w500';

  final String apiKey;
  final String sessionId;
  final String accountId;

  TMDBService({
    required this.apiKey,
    required this.sessionId,
    required this.accountId,
  });

  // Helper to build full URL with api_key query param
  Uri _uri(String path, [Map<String, String>? extra]) {
    final query = {'api_key': apiKey, ...?extra};
    return Uri.parse('$_baseUrl$path').replace(queryParameters: query);
  }

  Future<List<Movie>> fetchNowPlaying() async {
    try {
      final response = await http.get(_uri('/movie/now_playing'));
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final results = data['results'] as List<dynamic>;
      return results.map((e) => Movie.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      // Return empty list on error to keep UI stable
      return [];
    }
  }

  Future<List<Movie>> fetchPopular() async {
    try {
      final response = await http.get(_uri('/movie/popular'));
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final results = data['results'] as List<dynamic>;
      return results.map((e) => Movie.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Movie>> searchMovies(String query) async {
    try {
      final response = await http.get(_uri('/search/movie', {'query': query}));
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final results = data['results'] as List<dynamic>;
      return results.map((e) => Movie.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<Movie> fetchMovieDetail(String id) async {
    try {
      final response = await http.get(_uri('/movie/$id', {'append_to_response': 'credits'}));
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return Movie.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  // ---------- Actors ----------
  Future<List<Actor>> fetchPopularActors() async {
    try {
      final response = await http.get(_uri('/person/popular'));
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final results = data['results'] as List<dynamic>;
      return results.map((e) => Actor.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<Actor>> searchActors(String query) async {
    try {
      final response = await http.get(_uri('/search/person', {'query': query}));
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final results = data['results'] as List<dynamic>;
      return results.map((e) => Actor.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  // ---------- Favorites ----------
  Future<List<Movie>> fetchFavoriteMovies() async {
    try {
      final uri = _uri('/account/$accountId/favorite/movies', {'session_id': sessionId});
      final response = await http.get(uri);
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final results = data['results'] as List<dynamic>;
      return results.map((e) => Movie.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<Movie>> fetchFavoriteTV() async {
    try {
      final uri = _uri('/account/$accountId/favorite/tv', {'session_id': sessionId});
      final response = await http.get(uri);
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final results = data['results'] as List<dynamic>;
      return results.map((e) => Movie.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<Movie>> fetchFavorites() async {
    final movies = await fetchFavoriteMovies();
    final tv = await fetchFavoriteTV();
    return [...movies, ...tv];
  }

  // ---------- Watchlist ----------
  Future<List<Movie>> fetchWatchlistMovies() async {
    try {
      final uri = _uri('/account/$accountId/watchlist/movies', {'session_id': sessionId});
      final response = await http.get(uri);
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final results = data['results'] as List<dynamic>;
      return results.map((e) => Movie.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<Movie>> fetchWatchlistTV() async {
    try {
      final uri = _uri('/account/$accountId/watchlist/tv', {'session_id': sessionId});
      final response = await http.get(uri);
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final results = data['results'] as List<dynamic>;
      return results.map((e) => Movie.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<Movie>> fetchWatchlist() async {
    final movies = await fetchWatchlistMovies();
    final tv = await fetchWatchlistTV();
    return [...movies, ...tv];
  }

  // ---------- Rated ----------
  Future<List<Movie>> fetchRatedMovies() async {
    try {
      final uri = _uri('/account/$accountId/rated/movies', {'session_id': sessionId});
      final response = await http.get(uri);
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final results = data['results'] as List<dynamic>;
      return results.map((e) => Movie.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<Movie>> fetchRatedTV() async {
    try {
      final uri = _uri('/account/$accountId/rated/tv', {'session_id': sessionId});
      final response = await http.get(uri);
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final results = data['results'] as List<dynamic>;
      return results.map((e) => Movie.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<Movie>> fetchRatedTVEpisodes() async {
    try {
      final uri = _uri('/account/$accountId/rated/tv/episodes', {'session_id': sessionId});
      final response = await http.get(uri);
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final results = data['results'] as List<dynamic>;
      return results.map((e) => Movie.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  // ---------- Genres ----------
  /// Returns a map of genre name → genre ID fetched from TMDB.
  Future<Map<String, int>> fetchGenreMap() async {
    try {
      final response = await http.get(_uri('/genre/movie/list'));
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final genres = data['genres'] as List<dynamic>;
      final map = <String, int>{};
      for (final g in genres) {
        map[g['name'] as String] = g['id'] as int;
      }
      return map;
    } catch (_) {
      return {};
    }
  }

  /// Convenience: returns just the genre names (keys of fetchGenreMap).
  Future<List<String>> fetchGenres() async {
    final map = await fetchGenreMap();
    return map.keys.toList();
  }

  /// Fetches movies from /discover/movie filtered by a TMDB genre ID.
  Future<List<Movie>> fetchMoviesByGenre(int genreId) async {
    try {
      final response = await http.get(_uri('/discover/movie', {'with_genres': genreId.toString()}));
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final results = data['results'] as List<dynamic>;
      return results.map((e) => Movie.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  // ---------- User Lists ----------
  Future<List<dynamic>> fetchUserLists() async {
    try {
      final uri = _uri('/account/$accountId/lists', {'session_id': sessionId});
      final response = await http.get(uri);
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['results'] as List<dynamic>;
    } catch (_) {
      return [];
    }
  }

  // ---------- Write actions ----------
  Future<bool> _post(String path, Map<String, dynamic> body) async {
    final uri = _uri(path, {'session_id': sessionId});
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json;charset=utf-8'},
      body: jsonEncode(body),
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }

  Future<bool> addToFavorites({required String mediaId, required String mediaType}) async {
    return _post('/account/$accountId/favorite', {
      'media_type': mediaType,
      'media_id': int.tryParse(mediaId) ?? mediaId,
      'favorite': true,
    });
  }

  Future<bool> removeFromFavorites({required String mediaId, required String mediaType}) async {
    return _post('/account/$accountId/favorite', {
      'media_type': mediaType,
      'media_id': int.tryParse(mediaId) ?? mediaId,
      'favorite': false,
    });
  }

  Future<bool> addToWatchlist({required String mediaId, required String mediaType}) async {
    return _post('/account/$accountId/watchlist', {
      'media_type': mediaType,
      'media_id': int.tryParse(mediaId) ?? mediaId,
      'watchlist': true,
    });
  }

  Future<bool> removeFromWatchlist({required String mediaId, required String mediaType}) async {
    return _post('/account/$accountId/watchlist', {
      'media_type': mediaType,
      'media_id': int.tryParse(mediaId) ?? mediaId,
      'watchlist': false,
    });
  }

  // Convert TMDB image path to full URL
  static String imageUrl(String path) {
    if (path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    return '$_imageBase$path';
  }
}
