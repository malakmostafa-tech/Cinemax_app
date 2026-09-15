import 'package:cinemax_app/services/tmdb_service.dart';

class Actor {
  final String id;
  final String name;
  final String photoUrl;
  final List<String> relatedMovieIds;

  const Actor({
    required this.id,
    required this.name,
    required this.photoUrl,
    this.relatedMovieIds = const [],
  });

  String get firstName => name.split(' ').first;

  factory Actor.fromJson(Map<String, dynamic> json) {
    return Actor(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      photoUrl: json['profile_path'] != null ? TMDBService.imageUrl(json['profile_path']) : '',
      relatedMovieIds: const [],
    );
  }
}
