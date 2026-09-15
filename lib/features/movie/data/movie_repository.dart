import 'package:cinemax_app/services/tmdb_service.dart';
import 'package:cinemax_app/features/movie/domain/entities/movie.dart';
import 'package:cinemax_app/features/movie/domain/entities/actor.dart';

class MovieRepository {
  final TMDBService _service;

  MovieRepository(this._service);

  Future<List<Movie>> getNowPlaying() => _service.fetchNowPlaying();
  Future<List<Movie>> getPopular() => _service.fetchPopular();
  Future<List<String>> getGenres() => _service.fetchGenres();
  Future<List<Movie>> searchMovies(String query) => _service.searchMovies(query);
  Future<Movie> getMovieDetail(String id) => _service.fetchMovieDetail(id);

  // Actors
  Future<List<Actor>> getPopularActors() => _service.fetchPopularActors();
  Future<List<Actor>> searchActors(String query) => _service.searchActors(query);

  // TMDB Account Endpoints
  Future<List<Movie>> getFavorites() => _service.fetchFavorites();
  Future<List<Movie>> getFavoriteMovies() => _service.fetchFavoriteMovies();
  Future<List<Movie>> getFavoriteTV() => _service.fetchFavoriteTV();
  Future<List<dynamic>> getUserLists() => _service.fetchUserLists();
  Future<List<Movie>> getRatedMovies() => _service.fetchRatedMovies();
  Future<List<Movie>> getRatedTV() => _service.fetchRatedTV();
  Future<List<Movie>> getRatedTVEpisodes() => _service.fetchRatedTVEpisodes();
  Future<List<Movie>> getWatchlist() => _service.fetchWatchlist();
  Future<List<Movie>> getWatchlistMovies() => _service.fetchWatchlistMovies();
  Future<List<Movie>> getWatchlistTV() => _service.fetchWatchlistTV();

  // Write actions
  Future<bool> addToFavorites({required String mediaId, required String mediaType}) =>
      _service.addToFavorites(mediaId: mediaId, mediaType: mediaType);
  Future<bool> removeFromFavorites({required String mediaId, required String mediaType}) =>
      _service.removeFromFavorites(mediaId: mediaId, mediaType: mediaType);
  Future<bool> addToWatchlist({required String mediaId, required String mediaType}) =>
      _service.addToWatchlist(mediaId: mediaId, mediaType: mediaType);
  Future<bool> removeFromWatchlist({required String mediaId, required String mediaType}) =>
      _service.removeFromWatchlist(mediaId: mediaId, mediaType: mediaType);
}
