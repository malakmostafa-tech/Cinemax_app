import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cinemax_app/core/app_colors.dart';
import 'package:cinemax_app/features/movie/domain/entities/movie.dart';
import 'package:cinemax_app/features/movie/presentation/cubit/movie_cubit.dart';
import 'package:cinemax_app/features/movie/presentation/cubit/movie_state.dart';
import 'package:cinemax_app/features/movie/presentation/widgets/actor_avatar.dart';
import 'package:cinemax_app/features/movie/presentation/widgets/custom_status_bar.dart';
import 'package:cinemax_app/features/movie/presentation/widgets/movie_card.dart';

class SearchByActorScreen extends StatelessWidget {
  final TextEditingController searchController;
  final ValueChanged<String> onChanged;
  final VoidCallback onCancel;
  final Function(Movie) onSelectMovie;

  const SearchByActorScreen({
    super.key,
    required this.searchController,
    required this.onChanged,
    required this.onCancel,
    required this.onSelectMovie,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MovieCubit, MovieState>(
      builder: (context, state) {
        final actors = state.actors;
        final selectedActorId = state.selectedActorId ?? (actors.isNotEmpty ? actors.first.id : '');
        final selectedActor = actors.isNotEmpty
            ? actors.firstWhere(
                (a) => a.id == selectedActorId,
                orElse: () => actors.first,
              )
            : null;

        final allMovies = [...state.nowPlaying, ...state.popular, ...state.searchResults];
        final relatedMovies = selectedActor != null
            ? allMovies.where((m) {
                return m.cast.any((c) => c.id == selectedActor.id || c.name.toLowerCase() == selectedActor.name.toLowerCase());
              }).toList()
            : <Movie>[];

        final displayMovies = relatedMovies.isNotEmpty ? relatedMovies : state.popular;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CustomStatusBar(),
                const SizedBox(height: 12),
                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 48,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: AppColors.searchBarBg,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  controller: searchController,
                                  style: const TextStyle(color: Colors.white, fontSize: 13),
                                  onChanged: (val) {
                                    onChanged(val);
                                    context.read<MovieCubit>().loadActors(val);
                                  },
                                  decoration: const InputDecoration(
                                    hintText: 'Type title, categories, years, etc',
                                    hintStyle: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                                    border: InputBorder.none,
                                    isDense: true,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: onCancel,
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Actors Header
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Actors',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Horizontal Actors list
                SizedBox(
                  height: 90,
                  child: actors.isEmpty
                      ? const Center(
                          child: CircularProgressIndicator(color: AppColors.secondary),
                        )
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: actors.length,
                          itemBuilder: (context, index) {
                            final actor = actors[index];
                            final isSelected = actor.id == selectedActorId;

                            return ActorAvatar(
                              actor: actor,
                              isSelected: isSelected,
                              onTap: () {
                                context.read<MovieCubit>().setSelectedActor(actor.id);
                              },
                            );
                          },
                        ),
                ),
                const SizedBox(height: 16),
                // Movie Related Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'Movie Related',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'See All',
                        style: TextStyle(
                          color: AppColors.secondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                // Vertical list of related movies
                Expanded(
                  child: displayMovies.isEmpty
                      ? const Center(
                          child: Text(
                            'No movies found for this actor',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        )
                      : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: displayMovies.length,
                          itemBuilder: (context, index) {
                            final movie = displayMovies[index];
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
