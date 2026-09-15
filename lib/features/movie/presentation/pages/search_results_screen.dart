import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cinemax_app/core/app_colors.dart';
import 'package:cinemax_app/features/movie/domain/entities/movie.dart';
import 'package:cinemax_app/features/movie/presentation/cubit/movie_cubit.dart';
import 'package:cinemax_app/features/movie/presentation/cubit/movie_state.dart';
import 'package:cinemax_app/features/movie/presentation/pages/search_by_actor_screen.dart';
import 'package:cinemax_app/features/movie/presentation/pages/search_no_results_screen.dart';
import 'package:cinemax_app/features/movie/presentation/widgets/custom_status_bar.dart';
import 'package:cinemax_app/features/movie/presentation/widgets/movie_card.dart';

class SearchResultsScreen extends StatefulWidget {
  final String initialQuery;
  final VoidCallback onCancel;
  final Function(Movie) onSelectMovie;

  const SearchResultsScreen({
    super.key,
    required this.initialQuery,
    required this.onCancel,
    required this.onSelectMovie,
  });

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
    if (widget.initialQuery.trim().isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<MovieCubit>().search(widget.initialQuery);
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MovieCubit, MovieState>(
      builder: (context, state) {
        final query = _controller.text.trim();

        if (state.selectedSearchTab == 1) {
          return SearchByActorScreen(
            searchController: _controller,
            onChanged: (val) {
              context.read<MovieCubit>().setSearchQuery(val);
              setState(() {});
            },
            onCancel: widget.onCancel,
            onSelectMovie: widget.onSelectMovie,
          );
        }

        final matchingMovies = state.searchResults;

        if (!state.isLoading && matchingMovies.isEmpty && query.isNotEmpty) {
          return SearchNoResultsScreen(
            query: query,
            searchController: _controller,
            onChanged: (val) {
              context.read<MovieCubit>().search(val);
              setState(() {});
            },
            onCancel: widget.onCancel,
          );
        }

        final featuredMovie = matchingMovies.isNotEmpty
            ? matchingMovies.first
            : (state.popular.isNotEmpty ? state.popular.first : null);

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CustomStatusBar(),
                const SizedBox(height: 12),
                // Search Bar Top
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
                                  controller: _controller,
                                  style: const TextStyle(color: Colors.white, fontSize: 13),
                                  onChanged: (val) {
                                    context.read<MovieCubit>().search(val);
                                  },
                                  onSubmitted: (val) {
                                    context.read<MovieCubit>().search(val);
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
                        onTap: widget.onCancel,
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
                const SizedBox(height: 16),
                // Filter Tabs Row: Today, Actors, Movie
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      _buildTabItem(context, 'Today', 0, state.selectedSearchTab),
                      const SizedBox(width: 24),
                      _buildTabItem(context, 'Actors', 1, state.selectedSearchTab),
                      const SizedBox(width: 24),
                      _buildTabItem(context, 'Movie', 2, state.selectedSearchTab),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: state.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(color: AppColors.secondary),
                        )
                      : SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // "Today" featured section
                              if (featuredMovie != null) ...[
                                const Text(
                                  'Today',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                MovieCard(
                                  movie: featuredMovie,
                                  variant: MovieCardVariant.horizontal,
                                  onTap: () => widget.onSelectMovie(featuredMovie),
                                ),
                                const SizedBox(height: 20),
                              ],
                              // "Recommend for you" section header
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: const [
                                  Text(
                                    'Recommend for you',
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
                              const SizedBox(height: 14),
                              // List of recommended/matching movies
                              ...matchingMovies.map((movie) {
                                return MovieCard(
                                  movie: movie,
                                  variant: MovieCardVariant.horizontal,
                                  onTap: () => widget.onSelectMovie(movie),
                                );
                              }),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabItem(BuildContext context, String title, int index, int currentTab) {
    final isSelected = index == currentTab;

    return GestureDetector(
      onTap: () {
        context.read<MovieCubit>().setSelectedSearchTab(index);
      },
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              color: isSelected ? AppColors.secondary : AppColors.textSecondary,
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w400,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 2,
            width: 30,
            color: isSelected ? AppColors.secondary : Colors.transparent,
          ),
        ],
      ),
    );
  }
}
