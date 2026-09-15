import 'package:cinemax_app/features/movie/domain/entities/actor.dart';
import 'package:cinemax_app/services/tmdb_service.dart';

enum MovieBadge {
  newRelease,
  trending,
  premium,
  free,
}

class Movie {
  final String id;
  final String title;
  final String posterUrl;
  final String backdropUrl;
  final int year;
  final String duration; // e.g. "148 Minutes"
  final double rating; // e.g. 4.5
  final String genre; // e.g. "Action"
  final String ageRating; // e.g. "PG-13", "R"
  final MovieBadge? badge;
  final String type; // "Movie" or "Series"
  final List<Actor> cast;
  final String storyLine;
  final bool isPopular;

  const Movie({
    required this.id,
    required this.title,
    required this.posterUrl,
    required this.backdropUrl,
    required this.year,
    required this.duration,
    required this.rating,
    required this.genre,
    required this.ageRating,
    this.badge,
    this.type = "Movie",
    required this.cast,
    required this.storyLine,
    this.isPopular = false,
  });

  String get badgeText {
    switch (badge) {
      case MovieBadge.newRelease:
        return 'New';
      case MovieBadge.trending:
        return 'Trending';
      case MovieBadge.premium:
        return 'Premium';
      case MovieBadge.free:
        return 'Free';
      case null:
        return '';
    }
  }

  factory Movie.fromJson(Map<String, dynamic> json) {
    List<Actor> cast = [];
    if (json['credits'] != null && json['credits']['cast'] != null) {
      cast = (json['credits']['cast'] as List)
          .map((c) => Actor.fromJson(c as Map<String, dynamic>))
          .toList();
    }

    int parsedYear = 0;
    final dateStr = (json['release_date'] ?? json['first_air_date'] ?? '').toString();
    if (dateStr.isNotEmpty && dateStr.contains('-')) {
      parsedYear = int.tryParse(dateStr.split('-').first) ?? 0;
    }

    String parsedDuration = '0';
    if (json['runtime'] != null) {
      parsedDuration = '${json['runtime']} Minutes';
    } else if (json['episode_run_time'] != null && (json['episode_run_time'] as List).isNotEmpty) {
      parsedDuration = '${(json['episode_run_time'] as List).first} Minutes';
    }

    double parsedRating = 0.0;
    if (json['vote_average'] != null) {
      parsedRating = (json['vote_average'] as num).toDouble();
    }

    String parsedGenre = '';
    if (json['genres'] != null && (json['genres'] as List).isNotEmpty) {
      parsedGenre = json['genres'][0]['name'] ?? '';
    }

    return Movie(
      id: (json['id'] ?? '').toString(),
      title: json['title'] ?? json['name'] ?? '',
      posterUrl: json['poster_path'] != null ? TMDBService.imageUrl(json['poster_path']) : '',
      backdropUrl: json['backdrop_path'] != null ? TMDBService.imageUrl(json['backdrop_path']) : '',
      year: parsedYear,
      duration: parsedDuration,
      rating: parsedRating,
      genre: parsedGenre,
      ageRating: json['adult'] == true ? 'R' : 'PG-13',
      badge: null,
      type: json['media_type'] ?? 'Movie',
      cast: cast,
      storyLine: json['overview'] ?? '',
      isPopular: json['popularity'] != null ? (json['popularity'] as num) > 50 : false,
    );
  }
}
