import 'package:cinemax_app/features/movie/domain/entities/movie.dart';
import 'package:cinemax_app/features/movie/domain/entities/actor.dart';

class MovieState {
  final Set<String> wishlist;
  final String searchQuery;
  final String selectedCategory;
  final int selectedSearchTab;
  final String? selectedActorId;
  final int activeBottomTab;

  // Profile section state
  final String userName;
  final String userEmail;
  final String userPhone;
  final String userAvatarUrl;
  final bool showNotifications;
  final String selectedLanguage;
  final String? profileError;
  final bool isLoading;
  final bool isCategoryLoading;
  final List<Movie> searchResults;
  final List<Actor> actors;

  // Movie data fields from TMDB
  final List<Movie> nowPlaying;
  final List<Movie> popular;
  final List<Movie> categoryMovies;
  final List<String> categories;
  final Map<String, int> genreMap;

  const MovieState({
    this.wishlist = const {},
    this.searchQuery = '',
    this.selectedCategory = 'All',
    this.selectedSearchTab = 0,
    this.selectedActorId,
    this.activeBottomTab = 0,
    this.userName = 'Tiffany',
    this.userEmail = 'Tiffany.jeansey@gmail.com',
    this.userPhone = '+1 82120142306',
    this.userAvatarUrl =
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=300&q=80',
    this.showNotifications = true,
    this.selectedLanguage = 'English (UK)',
    this.profileError,
    this.isLoading = false,
    this.isCategoryLoading = false,
    this.searchResults = const [],
    this.actors = const [],
    this.nowPlaying = const [],
    this.popular = const [],
    this.categoryMovies = const [],
    this.categories = const [
      'All',
      'Action',
      'Comedy',
      'Animation',
      'Drama',
      'Romance',
      'Sci-Fi'
    ],
    this.genreMap = const {},
  });

  MovieState copyWith({
    Set<String>? wishlist,
    String? searchQuery,
    String? selectedCategory,
    int? selectedSearchTab,
    String? selectedActorId,
    int? activeBottomTab,
    String? userName,
    String? userEmail,
    String? userPhone,
    String? userAvatarUrl,
    bool? showNotifications,
    String? selectedLanguage,
    String? profileError,
    bool? isLoading,
    bool? isCategoryLoading,
    List<Movie>? searchResults,
    List<Actor>? actors,
    List<Movie>? nowPlaying,
    List<Movie>? popular,
    List<Movie>? categoryMovies,
    List<String>? categories,
    Map<String, int>? genreMap,
    bool clearProfileError = false,
  }) {
    return MovieState(
      wishlist: wishlist ?? this.wishlist,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedSearchTab: selectedSearchTab ?? this.selectedSearchTab,
      selectedActorId: selectedActorId ?? this.selectedActorId,
      activeBottomTab: activeBottomTab ?? this.activeBottomTab,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      userPhone: userPhone ?? this.userPhone,
      userAvatarUrl: userAvatarUrl ?? this.userAvatarUrl,
      showNotifications: showNotifications ?? this.showNotifications,
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
      profileError: clearProfileError ? null : (profileError ?? this.profileError),
      isLoading: isLoading ?? this.isLoading,
      isCategoryLoading: isCategoryLoading ?? this.isCategoryLoading,
      searchResults: searchResults ?? this.searchResults,
      actors: actors ?? this.actors,
      nowPlaying: nowPlaying ?? this.nowPlaying,
      popular: popular ?? this.popular,
      categoryMovies: categoryMovies ?? this.categoryMovies,
      categories: categories ?? this.categories,
      genreMap: genreMap ?? this.genreMap,
    );
  }
}
