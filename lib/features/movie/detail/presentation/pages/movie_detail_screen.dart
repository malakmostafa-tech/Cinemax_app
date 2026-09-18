import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cinemax_app/core/app_colors.dart';
import 'package:cinemax_app/features/movie/domain/entities/movie.dart';
import 'package:cinemax_app/features/movie/presentation/cubit/movie_cubit.dart';
import 'package:cinemax_app/features/movie/presentation/cubit/movie_state.dart';
import 'package:cinemax_app/features/movie/presentation/widgets/actor_avatar.dart';
import 'package:cinemax_app/features/movie/presentation/widgets/custom_status_bar.dart';
import 'package:cinemax_app/features/movie/presentation/widgets/share_bottom_sheet.dart';

class MovieDetailScreen extends StatefulWidget {
  final Movie movie;
  final VoidCallback onBack;

  const MovieDetailScreen({
    super.key,
    required this.movie,
    required this.onBack,
  });

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  bool _isStoryExpanded = false;
  late Movie _currentMovie;

  @override
  void initState() {
    super.initState();
    _currentMovie = widget.movie;
    _fetchFullDetails();
  }

  Future<void> _fetchFullDetails() async {
    final detail = await context.read<MovieCubit>().loadMovieDetail(widget.movie.id);
    if (mounted && detail != null) {
      setState(() {
        _currentMovie = detail;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MovieCubit, MovieState>(
      builder: (context, state) {
        final isWishlisted = state.wishlist.contains(_currentMovie.id);

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CustomStatusBar(),
                  const SizedBox(height: 8),
                  // Header Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                          onPressed: widget.onBack,
                        ),
                        Expanded(
                          child: Text(
                            _currentMovie.title,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            isWishlisted ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            color: isWishlisted ? AppColors.heartActive : Colors.white,
                            size: 22,
                          ),
                          onPressed: () {
                            context.read<MovieCubit>().toggleWishlist(_currentMovie.id);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Large Poster with Glow/Blur Backdrop Effect
                  Center(
                    child: SizedBox(
                      width: 220,
                      height: 300,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Soft glow backdrop
                          if (_currentMovie.posterUrl.isNotEmpty)
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24),
                                  image: DecorationImage(
                                    image: NetworkImage(_currentMovie.posterUrl),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                                  child: Container(color: Colors.black.withValues(alpha: 0.3)),
                                ),
                              ),
                            ),
                          // Main Poster Image Card
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: _currentMovie.posterUrl.isNotEmpty
                                ? Image.network(
                                    _currentMovie.posterUrl,
                                    width: 200,
                                    height: 280,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      width: 200,
                                      height: 280,
                                      color: AppColors.cardLight,
                                      child: const Icon(Icons.movie_rounded, color: AppColors.textSecondary, size: 50),
                                    ),
                                  )
                                : Container(
                                    width: 200,
                                    height: 280,
                                    color: AppColors.cardLight,
                                    child: const Icon(Icons.movie_rounded, color: AppColors.textSecondary, size: 50),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Meta Row (Year, Runtime, Genre)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 12,
                      runSpacing: 6,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.calendar_today_rounded, color: AppColors.textSecondary, size: 13),
                            const SizedBox(width: 4),
                            Text(
                              _currentMovie.year > 0 ? '${_currentMovie.year}' : 'N/A',
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.access_time_rounded, color: AppColors.textSecondary, size: 13),
                            const SizedBox(width: 4),
                            Text(
                              _currentMovie.duration,
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.movie_outlined, color: AppColors.textSecondary, size: 13),
                            const SizedBox(width: 4),
                            Text(
                              _currentMovie.genre.isNotEmpty ? _currentMovie.genre : 'Movie',
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Star Rating Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star_rounded, color: AppColors.primary, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        _currentMovie.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Action Buttons Row (Orange Play pill + Download + Share)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Orange Play CTA Button
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                              elevation: 0,
                            ),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Playing ${_currentMovie.title}...'),
                                  backgroundColor: AppColors.card,
                                ),
                              );
                            },
                            icon: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 24),
                            label: const Text(
                              'Play',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Download Circular Button
                        Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(
                            color: AppColors.card,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.file_download_outlined, color: AppColors.secondary, size: 22),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Downloading movie...'),
                                  backgroundColor: AppColors.card,
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Share Circular Button
                        Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(
                            color: AppColors.card,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.ios_share_rounded, color: AppColors.secondary, size: 20),
                            onPressed: () {
                              ShareBottomSheet.show(context);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  // "Story Line" Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Story Line',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (_currentMovie.storyLine.isNotEmpty)
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: _isStoryExpanded
                                      ? _currentMovie.storyLine
                                      : (_currentMovie.storyLine.length > 120
                                          ? '${_currentMovie.storyLine.substring(0, 120)}...'
                                          : _currentMovie.storyLine),
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 13,
                                    height: 1.5,
                                  ),
                                ),
                                if (_currentMovie.storyLine.length > 120)
                                  WidgetSpan(
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _isStoryExpanded = !_isStoryExpanded;
                                        });
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 4),
                                        child: Text(
                                          _isStoryExpanded ? ' Less' : ' More',
                                          style: const TextStyle(
                                            color: AppColors.secondary,
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          )
                        else
                          const Text(
                            'No overview available for this movie.',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  // "Cast and Crew" Section
                  if (_currentMovie.cast.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Cast and Crew',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 90,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _currentMovie.cast.length,
                        itemBuilder: (context, index) {
                          final actor = _currentMovie.cast[index];
                          return ActorAvatar(
                            actor: actor,
                            isSelected: false,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
