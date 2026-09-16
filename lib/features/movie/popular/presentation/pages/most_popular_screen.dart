import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cinemax_app/core/app_colors.dart';
import 'package:cinemax_app/features/movie/domain/entities/movie.dart';
import 'package:cinemax_app/features/movie/presentation/cubit/movie_cubit.dart';
import 'package:cinemax_app/features/movie/presentation/cubit/movie_state.dart';
import 'package:cinemax_app/features/movie/presentation/widgets/custom_status_bar.dart';
import 'package:cinemax_app/features/movie/presentation/widgets/movie_card.dart';

class MostPopularScreen extends StatelessWidget {
  final VoidCallback onBack;
  final Function(Movie) onSelectMovie;

  const MostPopularScreen({
    super.key,
    required this.onBack,
    required this.onSelectMovie,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MovieCubit, MovieState>(
      builder: (context, state) {
        final popularMovies = state.popular;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              children: [
                const CustomStatusBar(),
                const SizedBox(height: 12),
                // Header Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                        onPressed: onBack,
                      ),
                      const Expanded(
                        child: Text(
                          'Most Popular Movie',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Vertical List of Full Width Horizontal Movie Cards
                Expanded(
                  child: state.isLoading && popularMovies.isEmpty
                      ? const Center(
                          child: CircularProgressIndicator(color: AppColors.secondary),
                        )
                      : popularMovies.isEmpty
                          ? const Center(
                              child: Text(
                                'No popular movies found',
                                style: TextStyle(color: AppColors.textSecondary),
                              ),
                            )
                          : ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              itemCount: popularMovies.length,
                              itemBuilder: (context, index) {
                                final movie = popularMovies[index];
                                return MovieCard(
                                  movie: movie,
                                  variant: MovieCardVariant.horizontal,
                                  onTap: () => onSelectMovie(movie),
                                );
                              },
                            ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
