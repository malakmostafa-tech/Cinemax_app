import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cinemax_app/main.dart';
import 'package:cinemax_app/features/movie/domain/entities/movie.dart';
import 'package:cinemax_app/features/movie/domain/entities/actor.dart';
import 'package:cinemax_app/features/movie/presentation/cubit/movie_cubit.dart';
import 'package:cinemax_app/features/movie/data/movie_repository.dart';
import 'package:cinemax_app/services/tmdb_service.dart';

class _FakeTMDBService extends TMDBService {
  _FakeTMDBService() : super(apiKey: '', sessionId: '', accountId: '');

  @override
  Future<List<Movie>> fetchNowPlaying() async => [];

  @override
  Future<List<Movie>> fetchPopular() async => [];

  @override
  Future<List<String>> fetchGenres() async => [];

  @override
  Future<List<Actor>> fetchPopularActors() async => [];
}

void main() {
  testWidgets('App renders CinemaxApp home widget', (WidgetTester tester) async {
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      if (details.exception is NetworkImageLoadException) {
        return;
      }
      originalOnError?.call(details);
    };

    final cubit = MovieCubit(MovieRepository(_FakeTMDBService()));
    await tester.pumpWidget(CinemaxApp(cubit: cubit));
    await tester.pump();
    expect(find.byType(CinemaxApp), findsOneWidget);

    FlutterError.onError = originalOnError;
  });
}
