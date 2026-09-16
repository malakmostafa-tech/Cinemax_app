import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cinemax_app/features/movie/domain/entities/movie.dart';
import 'package:cinemax_app/features/movie/domain/entities/actor.dart';

/// Service class for interacting with the The Movie Database (TMDB) API.
/// Provides simple, beginner-friendly methods with try/catch and safe null handling.
class TMDBService {
  static const String _baseUrl = 'https://api.themoviedb.org/3';
  static const String _imageBase = 'https://image.tmdb.org/t/p/w500';

  final String apiKey;
  final String sessionId;
  final String accountId;

  TMDBService({
    required this.apiKey,
    required this.sessionId,
    required this.accountId,
  });

  /// Helper to build full TMDB API URL with api_key and optional query parameters.
  Uri _uri(String path, [Map<String, String>? extraParams]) {
    final query = {'api_key': apiKey, ...?extraParams};
    return Uri.parse('$_baseUrl$path').replace(queryParameters: query);
  }

  // ==========================================
  // CORE DISCOVERY & MOVIE ENDPOINTS
  // ==========================================

  /// Fetch movies currently playing in theatres (GET /movie/now_playing).
  Future<List<Movie>> fetchNowPlaying() async {
    try {
      final response = await http.get(_uri('/movie/now_playing'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final results = (data['results'] as List<dynamic>?) ?? [];
        return results
            .map((item) => Movie.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  /// Fetch most popular movies (GET /movie/popular).
  Future<List<Movie>> fetchPopular() async {
    try {
      final response = await http.get(_uri('/movie/popular'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final results = (data['results'] as List<dynamic>?) ?? [];
        return results
            .map((item) => Movie.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  /// Search movies by title query (GET /search/movie).
  Future<List<Movie>> searchMovies(String query) async {
    if (query.trim().isEmpty) return [];
    try {
      final response = await http.get(_uri('/search/movie', {'query': query}));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final results = (data['results'] as List<dynamic>?) ?? [];
        return results
            .map((item) => Movie.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  /// Fetch detailed information for a single movie, including credits (GET /movie/{id}).
  Future<Movie> fetchMovieDetail(String id) async {
    try {
      final response =
          await http.get(_uri('/movie/$id', {'append_to_response': 'credits'}));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return Movie.fromJson(data);
      }
      throw Exception('Failed to load movie detail with status ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  // ==========================================
  // GENRES & FILTERING
  // ==========================================

  /// Fetch list of official movie genres (GET /genre/movie/list).
  Future<List<String>> fetchGenres() async {
    final map = await fetchGenreMap();
    return map.keys.toList();
  }

  /// Returns a map of genre name -> genre ID for lookup.
  Future<Map<String, int>> fetchGenreMap() async {
    try {
      final response = await http.get(_uri('/genre/movie/list'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final genres = (data['genres'] as List<dynamic>?) ?? [];
        final map = <String, int>{};
        for (final g in genres) {
          final name = g['name'] as String?;
          final id = g['id'] as int?;
          if (name != null && id != null) {
            map[name] = id;
          }
        }
        return map;
      }
      return {};
    } catch (_) {
      return {};
    }
  }

  /// Filter movies by genre ID (GET /discover/movie?with_genres={genreId}).
  Future<List<Movie>> fetchMoviesByGenre(int genreId) async {
    try {
      final response = await http.get(
        _uri('/discover/movie', {'with_genres': genreId.toString()}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final results = (data['results'] as List<dynamic>?) ?? [];
        return results
            .map((item) => Movie.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  // ==========================================
  // ACTORS & PERSONS
  // ==========================================

  /// Search actors/people by name (GET /search/person).
  Future<List<Actor>> searchActors(String query) async {
    if (query.trim().isEmpty) return [];
    try {
      final response = await http.get(_uri('/search/person', {'query': query}));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final results = (data['results'] as List<dynamic>?) ?? [];
        return results
            .map((item) => Actor.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  /// Fetch currently popular actors (GET /person/popular).
  Future<List<Actor>> fetchPopularActors() async {
    try {
      final response = await http.get(_uri('/person/popular'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final results = (data['results'] as List<dynamic>?) ?? [];
        return results
            .map((item) => Actor.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  // ==========================================
  // 10 ACCOUNT-SPECIFIC ENDPOINTS
  // ==========================================

  /// 1. Combined favorites (combines favorite movies and favorite TV shows).
  Future<List<Movie>> getFavorites() async {
    final movies = await getFavoriteMovies();
    final tv = await getFavoriteTV();
    return [...movies, ...tv];
  }

  /// Alias for getFavorites() for backward compatibility.
  Future<List<Movie>> fetchFavorites() => getFavorites();

  /// 2. Get favorite movies (GET /account/{account_id}/favorite/movies).
  Future<List<Movie>> getFavoriteMovies() async {
    try {
      final uri = _uri('/account/$accountId/favorite/movies', {'session_id': sessionId});
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final results = (data['results'] as List<dynamic>?) ?? [];
        return results
            .map((item) => Movie.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  /// Alias for getFavoriteMovies().
  Future<List<Movie>> fetchFavoriteMovies() => getFavoriteMovies();

  /// 3. Get favorite TV shows (GET /account/{account_id}/favorite/tv).
  Future<List<Movie>> getFavoriteTV() async {
    try {
      final uri = _uri('/account/$accountId/favorite/tv', {'session_id': sessionId});
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final results = (data['results'] as List<dynamic>?) ?? [];
        return results
            .map((item) => Movie.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  /// Alias for getFavoriteTV().
  Future<List<Movie>> fetchFavoriteTV() => getFavoriteTV();

  /// 4. Get custom user lists (GET /account/{account_id}/lists).
  Future<List<dynamic>> getUserLists() async {
    try {
      final uri = _uri('/account/$accountId/lists', {'session_id': sessionId});
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return (data['results'] as List<dynamic>?) ?? [];
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  /// Alias for getUserLists().
  Future<List<dynamic>> fetchUserLists() => getUserLists();

  /// 5. Get rated movies (GET /account/{account_id}/rated/movies).
  Future<List<Movie>> getRatedMovies() async {
    try {
      final uri = _uri('/account/$accountId/rated/movies', {'session_id': sessionId});
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final results = (data['results'] as List<dynamic>?) ?? [];
        return results
            .map((item) => Movie.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  /// Alias for getRatedMovies().
  Future<List<Movie>> fetchRatedMovies() => getRatedMovies();

  /// 6. Get rated TV shows (GET /account/{account_id}/rated/tv).
  Future<List<Movie>> getRatedTV() async {
    try {
      final uri = _uri('/account/$accountId/rated/tv', {'session_id': sessionId});
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final results = (data['results'] as List<dynamic>?) ?? [];
        return results
            .map((item) => Movie.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  /// Alias for getRatedTV().
  Future<List<Movie>> fetchRatedTV() => getRatedTV();

  /// 7. Get rated TV episodes (GET /account/{account_id}/rated/tv/episodes).
  Future<List<Movie>> getRatedTVEpisodes() async {
    try {
      final uri = _uri('/account/$accountId/rated/tv/episodes', {'session_id': sessionId});
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final results = (data['results'] as List<dynamic>?) ?? [];
        return results
            .map((item) => Movie.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  /// Alias for getRatedTVEpisodes().
  Future<List<Movie>> fetchRatedTVEpisodes() => getRatedTVEpisodes();

  /// 8. Combined watchlist (combines watchlist movies and watchlist TV shows).
  Future<List<Movie>> getWatchlist() async {
    final movies = await getWatchlistMovies();
    final tv = await getWatchlistTV();
    return [...movies, ...tv];
  }

  /// Alias for getWatchlist().
  Future<List<Movie>> fetchWatchlist() => getWatchlist();

  /// 9. Get watchlist movies (GET /account/{account_id}/watchlist/movies).
  Future<List<Movie>> getWatchlistMovies() async {
    try {
      final uri = _uri('/account/$accountId/watchlist/movies', {'session_id': sessionId});
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final results = (data['results'] as List<dynamic>?) ?? [];
        return results
            .map((item) => Movie.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  /// Alias for getWatchlistMovies().
  Future<List<Movie>> fetchWatchlistMovies() => getWatchlistMovies();

  /// 10. Get watchlist TV shows (GET /account/{account_id}/watchlist/tv).
  Future<List<Movie>> getWatchlistTV() async {
    try {
      final uri = _uri('/account/$accountId/watchlist/tv', {'session_id': sessionId});
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final results = (data['results'] as List<dynamic>?) ?? [];
        return results
            .map((item) => Movie.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  /// Alias for getWatchlistTV().
  Future<List<Movie>> fetchWatchlistTV() => getWatchlistTV();

  // ==========================================
  // WRITE ACTIONS
  // ==========================================

  /// Post body helper for account updates.
  Future<bool> _post(String path, Map<String, dynamic> body) async {
    try {
      final uri = _uri(path, {'session_id': sessionId});
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json;charset=utf-8'},
        body: jsonEncode(body),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  /// Add item to user favorites (POST /account/{account_id}/favorite).
  Future<bool> addToFavorites({required String mediaId, required String mediaType}) async {
    return _post('/account/$accountId/favorite', {
      'media_type': mediaType,
      'media_id': int.tryParse(mediaId) ?? mediaId,
      'favorite': true,
    });
  }

  /// Remove item from user favorites (POST /account/{account_id}/favorite).
  Future<bool> removeFromFavorites({required String mediaId, required String mediaType}) async {
    return _post('/account/$accountId/favorite', {
      'media_type': mediaType,
      'media_id': int.tryParse(mediaId) ?? mediaId,
      'favorite': false,
    });
  }

  /// Add item to user watchlist (POST /account/{account_id}/watchlist).
  Future<bool> addToWatchlist({required String mediaId, required String mediaType}) async {
    return _post('/account/$accountId/watchlist', {
      'media_type': mediaType,
      'media_id': int.tryParse(mediaId) ?? mediaId,
      'watchlist': true,
    });
  }

  /// Remove item from user watchlist (POST /account/{account_id}/watchlist).
  Future<bool> removeFromWatchlist({required String mediaId, required String mediaType}) async {
    return _post('/account/$accountId/watchlist', {
      'media_type': mediaType,
      'media_id': int.tryParse(mediaId) ?? mediaId,
      'watchlist': false,
    });
  }

  // ==========================================
  // IMAGE UTILITIES
  // ==========================================

  /// Helper to convert a TMDB relative image path (e.g. "/abc.jpg") into a full URL.
  static String imageUrl(String path) {
    if (path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    return '$_imageBase$path';
  }
}
