import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cinemax_app/features/movie/presentation/cubit/movie_state.dart';
import 'package:cinemax_app/services/tmdb_service.dart';
import 'package:cinemax_app/features/movie/data/movie_repository.dart';
import 'package:cinemax_app/features/movie/domain/entities/movie.dart';

class MovieCubit extends Cubit<MovieState> {
  final MovieRepository _repository;

  MovieCubit([MovieRepository? repository])
      : _repository = repository ??
            MovieRepository(
              TMDBService(
                apiKey: dotenv.isInitialized ? dotenv.get('TMDB_API_KEY', fallback: '') : '',
                sessionId: dotenv.isInitialized ? dotenv.get('TMDB_SESSION_ID', fallback: '') : '',
                accountId: dotenv.isInitialized ? dotenv.get('TMDB_ACCOUNT_ID', fallback: '') : '',
              ),
            ),
        super(const MovieState()) {
    // Load initial data (now playing, popular, categories, actors)
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    await Future.wait([
      loadNowPlaying(),
      loadPopular(),
      loadCategories(),
      loadActors(),
    ]);
  }

  Future<void> loadNowPlaying() async {
    emit(state.copyWith(isLoading: true));
    try {
      final movies = await _repository.getNowPlaying();
      emit(state.copyWith(nowPlaying: movies, isLoading: false));
    } catch (_) {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> loadPopular() async {
    emit(state.copyWith(isLoading: true));
    try {
      final movies = await _repository.getPopular();
      emit(state.copyWith(popular: movies, isLoading: false));
    } catch (_) {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> loadCategories() async {
    try {
      final categories = await _repository.getGenres();
      if (categories.isNotEmpty) {
        emit(state.copyWith(categories: ['All', ...categories]));
      }
    } catch (_) {
      // Keep existing categories on failure
    }
  }

  Future<void> loadActors([String? query]) async {
    try {
      final actors = (query != null && query.trim().isNotEmpty)
          ? await _repository.searchActors(query)
          : await _repository.getPopularActors();
      emit(state.copyWith(actors: actors));
    } catch (_) {
      // Keep existing actors on failure
    }
  }

  Future<void> search(String query) async {
    emit(state.copyWith(searchQuery: query, isLoading: true));
    if (query.trim().isEmpty) {
      emit(state.copyWith(searchResults: const [], isLoading: false));
      return;
    }
    try {
      final results = await _repository.searchMovies(query);
      emit(state.copyWith(searchResults: results, isLoading: false));
    } catch (_) {
      emit(state.copyWith(searchResults: const [], isLoading: false));
    }
  }

  Future<Movie?> loadMovieDetail(String id) async {
    try {
      return await _repository.getMovieDetail(id);
    } catch (_) {
      return null;
    }
  }

  // UI actions
  void toggleWishlist(String movieId) {
    final updated = Set<String>.from(state.wishlist);
    if (updated.contains(movieId)) {
      updated.remove(movieId);
    } else {
      updated.add(movieId);
    }
    emit(state.copyWith(wishlist: updated));
  }

  void clearWishlist() => emit(state.copyWith(wishlist: <String>{}));

  void setSearchQuery(String query) => emit(state.copyWith(searchQuery: query));

  void setSelectedCategory(String category) => emit(state.copyWith(selectedCategory: category));

  void setSelectedSearchTab(int index) => emit(state.copyWith(selectedSearchTab: index));

  void setSelectedActor(String actorId) => emit(state.copyWith(selectedActorId: actorId));

  void setActiveBottomTab(int tabIndex) => emit(state.copyWith(activeBottomTab: tabIndex));

  void updateUserProfile({String? name, String? email, String? phone, String? avatarUrl}) {
    emit(state.copyWith(
      userName: name,
      userEmail: email,
      userPhone: phone,
      userAvatarUrl: avatarUrl,
    ));
  }

  void toggleNotifications(bool value) => emit(state.copyWith(showNotifications: value));

  void selectLanguage(String language) => emit(state.copyWith(selectedLanguage: language));

  void setProfileError(String? error) {
    if (error == null) {
      emit(state.copyWith(clearProfileError: true));
    } else {
      emit(state.copyWith(profileError: error));
    }
  }
}
