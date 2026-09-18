import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cinemax_app/core/app_colors.dart';
import 'package:cinemax_app/features/movie/domain/entities/movie.dart';
import 'package:cinemax_app/features/movie/presentation/cubit/movie_cubit.dart';
import 'package:cinemax_app/features/movie/presentation/cubit/movie_state.dart';
import 'package:cinemax_app/features/movie/presentation/widgets/custom_status_bar.dart';
import 'package:cinemax_app/features/movie/presentation/widgets/movie_card.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onNavigateToSearch;
  final VoidCallback onNavigateToMostPopular;
  final Function(Movie) onSelectMovie;
  final VoidCallback? onNavigateToAi;

  const HomeScreen({
    super.key,
    required this.onNavigateToSearch,
    required this.onNavigateToMostPopular,
    required this.onSelectMovie,
    this.onNavigateToAi,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _heroIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MovieCubit, MovieState>(
      builder: (context, state) {
        if (state.isLoading && state.nowPlaying.isEmpty && state.popular.isEmpty) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.secondary),
            ),
          );
        }

        final heroMovies = state.nowPlaying.isNotEmpty
            ? state.nowPlaying.take(5).toList()
            : state.popular.take(5).toList();

        final Movie? heroMovie = heroMovies.isNotEmpty
            ? heroMovies[_heroIndex % heroMovies.length]
            : null;

        final isCategoryFiltered = state.selectedCategory != 'All';
        final displayMovies = isCategoryFiltered
            ? state.categoryMovies
            : (state.popular.isNotEmpty ? state.popular : state.nowPlaying);

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // -----------------------------------------------------------
                // FIXED HEADER SECTION: Status Bar, Greeting, and Search Bar
                // -----------------------------------------------------------
                const CustomStatusBar(),
                const SizedBox(height: 12),
                // Top Header Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            // Avatar
                            const CircleAvatar(
                              radius: 20,
                              backgroundImage: NetworkImage(
                                'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Hello, ${state.userName.isNotEmpty ? state.userName : 'Smith'}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  const Text(
                                    "Let's stream your favorite movie",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // AI Assistant Icon Button
                      if (widget.onNavigateToAi != null)
                        IconButton(
                          tooltip: 'Cinemax AI',
                          icon: const Icon(Icons.auto_awesome, color: AppColors.secondary, size: 24),
                          onPressed: widget.onNavigateToAi,
                        ),
                      // Wishlist / Heart Icon Button
                      IconButton(
                        icon: const Icon(Icons.favorite_rounded, color: AppColors.heartActive, size: 24),
                        onPressed: () {
                          context.read<MovieCubit>().setActiveBottomTab(2);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Tappable Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GestureDetector(
                    onTap: widget.onNavigateToSearch,
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.searchBarBg,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 20),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Search a title...',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          Icon(Icons.tune_rounded, color: AppColors.textSecondary, size: 20),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // -----------------------------------------------------------
                // SCROLLABLE BODY SECTION: Hero Banner, Categories, and Movies
                // -----------------------------------------------------------
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Hero Banner Carousel
                        if (heroMovie != null) ...[
                          SizedBox(
                            height: 170,
                            child: PageView.builder(
                              physics: const BouncingScrollPhysics(),
                              itemCount: heroMovies.length,
                              onPageChanged: (index) {
                                setState(() => _heroIndex = index);
                              },
                              itemBuilder: (context, index) {
                                final currentHero = heroMovies[index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  child: GestureDetector(
                                    onTap: () => widget.onSelectMovie(currentHero),
                                    child: Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(20),
                                          child: currentHero.backdropUrl.isNotEmpty
                                              ? Image.network(
                                                  currentHero.backdropUrl,
                                                  height: 170,
                                                  width: double.infinity,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error, stackTrace) => Container(
                                                    height: 170,
                                                    width: double.infinity,
                                                    color: AppColors.card,
                                                    child: const Center(
                                                      child: Icon(Icons.movie, color: AppColors.textSecondary, size: 48),
                                                    ),
                                                  ),
                                                )
                                              : Container(
                                                  height: 170,
                                                  width: double.infinity,
                                                  color: AppColors.card,
                                                  child: const Center(
                                                    child: Icon(Icons.movie, color: AppColors.textSecondary, size: 48),
                                                  ),
                                                ),
                                        ),
                                        Positioned.fill(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(20),
                                              gradient: LinearGradient(
                                                colors: [
                                                  Colors.black.withValues(alpha: 0.8),
                                                  Colors.transparent,
                                                ],
                                                begin: Alignment.bottomCenter,
                                                end: Alignment.topCenter,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          bottom: 16,
                                          left: 16,
                                          right: 16,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                currentHero.title,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                currentHero.year > 0 ? 'Released in ${currentHero.year}' : 'Featured Movie',
                                                style: TextStyle(
                                                  color: Colors.white.withValues(alpha: 0.8),
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Carousel Pagination Dots
                          if (heroMovies.length > 1)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                heroMovies.length,
                                (index) => GestureDetector(
                                  onTap: () => setState(() => _heroIndex = index),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    margin: const EdgeInsets.symmetric(horizontal: 3),
                                    height: 6,
                                    width: (_heroIndex % heroMovies.length) == index ? 20 : 6,
                                    decoration: BoxDecoration(
                                      color: (_heroIndex % heroMovies.length) == index
                                          ? AppColors.secondary
                                          : AppColors.textTertiary,
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],

                        const SizedBox(height: 20),
                        // Categories Section Header
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            'Categories',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Horizontally Scrollable Category Filter Chips
                        if (state.categories.isNotEmpty)
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              children: state.categories.map((cat) {
                                final isSelected = cat == state.selectedCategory;

                                return GestureDetector(
                                  onTap: () {
                                    context.read<MovieCubit>().setSelectedCategory(cat);
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 12),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: isSelected ? AppColors.card : Colors.transparent,
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    child: Text(
                                      cat,
                                      style: TextStyle(
                                        color: isSelected ? AppColors.secondary : AppColors.textSecondary,
                                        fontSize: 13,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),

                        const SizedBox(height: 24),
                        // Section Header (Most Popular or Category)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                isCategoryFiltered ? '${state.selectedCategory} Movies' : 'Most popular',
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (!isCategoryFiltered)
                                GestureDetector(
                                  onTap: widget.onNavigateToMostPopular,
                                  child: const Text(
                                    'See All',
                                    style: TextStyle(
                                      color: AppColors.secondary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        // Horizontally Scrollable Movie Cards Row
                        SizedBox(
                          height: 240,
                          child: state.isCategoryLoading
                              ? const Center(
                                  child: CircularProgressIndicator(color: AppColors.secondary),
                                )
                              : displayMovies.isEmpty
                                  ? const Center(
                                      child: Text(
                                        'No movies found',
                                        style: TextStyle(color: AppColors.textSecondary),
                                      ),
                                    )
                                  : ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      physics: const BouncingScrollPhysics(),
                                      padding: const EdgeInsets.symmetric(horizontal: 20),
                                      itemCount: displayMovies.length,
                                      itemBuilder: (context, index) {
                                        final movie = displayMovies[index];
                                        return Padding(
                                          padding: const EdgeInsets.only(right: 14),
                                          child: MovieCard(
                                            movie: movie,
                                            variant: MovieCardVariant.vertical,
                                            onTap: () => widget.onSelectMovie(movie),
                                          ),
                                        );
                                      },
                                    ),
                        ),
                        const SizedBox(height: 24),
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
}
