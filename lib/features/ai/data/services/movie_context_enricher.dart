import 'package:cinemax_app/features/movie/data/movie_repository.dart';
import 'package:cinemax_app/features/movie/domain/entities/movie.dart';

/// Enriches Gemini prompts with TMDB movie data when the user asks about a movie.
class MovieContextEnricher {
  final MovieRepository? _movieRepository;

  MovieContextEnricher([this._movieRepository]);

  Future<String> enrichInput(String userMessage) async {
    if (_movieRepository == null) return userMessage;
    try {
      final context = await _buildMovieContext(userMessage);
      if (context == null || context.isEmpty) return userMessage;
      return '$userMessage\n\n---\nTMDB Movie Context (use accurately when relevant):\n$context';
    } catch (_) {
      return userMessage; // Safe fallback on error
    }
  }

  Future<String?> _buildMovieContext(String userMessage) async {
    final repo = _movieRepository;
    if (repo == null) return null;

    final query = userMessage.trim();
    if (query.length < 3) return null;

    final movies = await repo.searchMovies(query);
    if (movies.isEmpty) return null;

    final match = _pickRelevantMovie(query, movies);
    if (match == null) return null;

    Movie detailMovie;
    try {
      detailMovie = await repo.getMovieDetail(match.id);
    } catch (_) {
      detailMovie = match;
    }

    return _formatContext(detailMovie);
  }

  Movie? _pickRelevantMovie(String query, List<Movie> movies) {
    final normalizedQuery = query.toLowerCase();

    for (final movie in movies.take(5)) {
      final title = movie.title.toLowerCase();
      if (normalizedQuery.contains(title) || title.contains(normalizedQuery)) {
        return movie;
      }
    }

    final asksAboutMovie = RegExp(
      r'\b(about|explain|describe|who directed|director of|cast of|'
      r'starring|similar to|compare|rating of|review of|plot of|story of|فيلم|عن|بطولة|تقييم|قصة)\b',
      caseSensitive: false,
    ).hasMatch(query);

    if (!asksAboutMovie) return null;

    for (final movie in movies.take(3)) {
      final words = movie.title
          .toLowerCase()
          .split(RegExp(r'\s+'))
          .where((word) => word.length > 3);
      if (words.any(normalizedQuery.contains)) return movie;
    }

    return movies.first;
  }

  String _formatContext(Movie movie) {
    final buffer = StringBuffer()
      ..writeln('- Movie ID: ${movie.id}')
      ..writeln('- Title: ${movie.title}')
      ..writeln('- Overview: ${movie.storyLine}')
      ..writeln('- Rating: ${movie.rating.toStringAsFixed(1)}/10')
      ..writeln('- Release Year: ${movie.year}');

    if (movie.genre.isNotEmpty) {
      buffer.writeln('- Genre: ${movie.genre}');
    }

    if (movie.duration.isNotEmpty && movie.duration != '0') {
      buffer.writeln('- Duration: ${movie.duration}');
    }

    if (movie.cast.isNotEmpty) {
      final castNames = movie.cast.take(5).map((a) => a.name).join(', ');
      if (castNames.isNotEmpty) {
        buffer.writeln('- Top Cast: $castNames');
      }
    }

    return buffer.toString().trim();
  }
}
