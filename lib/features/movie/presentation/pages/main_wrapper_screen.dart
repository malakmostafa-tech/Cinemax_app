import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cinemax_app/core/app_colors.dart';
import 'package:cinemax_app/features/movie/domain/entities/movie.dart';
import 'package:cinemax_app/features/movie/presentation/cubit/movie_cubit.dart';
import 'package:cinemax_app/features/movie/presentation/cubit/movie_state.dart';
import 'package:cinemax_app/features/movie/presentation/pages/home_screen.dart';
import 'package:cinemax_app/features/movie/popular/presentation/pages/most_popular_screen.dart';
import 'package:cinemax_app/features/movie/detail/presentation/pages/movie_detail_screen.dart';
import 'package:cinemax_app/features/movie/search/presentation/pages/search_initial_screen.dart';
import 'package:cinemax_app/features/movie/search/presentation/pages/search_results_screen.dart';
import 'package:cinemax_app/features/movie/wishlist/presentation/pages/wishlist_screen.dart';
import 'package:cinemax_app/features/movie/presentation/widgets/custom_bottom_nav_bar.dart';

import 'package:cinemax_app/features/profile/presentation/pages/profile_stack.dart';

enum _ActiveSubScreen { none, detail, mostPopular }

class MainWrapperScreen extends StatefulWidget {
  const MainWrapperScreen({super.key});

  @override
  State<MainWrapperScreen> createState() => _MainWrapperScreenState();
}

class _MainWrapperScreenState extends State<MainWrapperScreen> {
  _ActiveSubScreen _subScreen = _ActiveSubScreen.none;
  Movie? _selectedMovie;
  final TextEditingController _searchController = TextEditingController();
  bool _showBottomNavBar = true;

  void _navigateToDetail(Movie movie) {
    setState(() {
      _selectedMovie = movie;
      _subScreen = _ActiveSubScreen.detail;
    });
  }

  void _navigateToMostPopular() {
    setState(() => _subScreen = _ActiveSubScreen.mostPopular);
  }

  void _popSubScreen() {
    setState(() {
      _subScreen = _ActiveSubScreen.none;
      _selectedMovie = null;
      _showBottomNavBar = true;
    });
  }

  HomeScreen _buildHomeScreen(BuildContext context) {
    return HomeScreen(
      onNavigateToSearch: () => context.read<MovieCubit>().setActiveBottomTab(1),
      onNavigateToMostPopular: _navigateToMostPopular,
      onSelectMovie: _navigateToDetail,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MovieCubit, MovieState>(
      builder: (context, state) {
        if (_subScreen == _ActiveSubScreen.detail && _selectedMovie != null) {
          return MovieDetailScreen(
            movie: _selectedMovie!,
            onBack: _popSubScreen,
          );
        }

        if (_subScreen == _ActiveSubScreen.mostPopular) {
          return MostPopularScreen(
            onBack: _popSubScreen,
            onSelectMovie: _navigateToDetail,
          );
        }

        final Widget currentTabScreen;

        switch (state.activeBottomTab) {
          case 0:
            currentTabScreen = _buildHomeScreen(context);
            break;
          case 1:
            if (state.searchQuery.trim().isEmpty) {
              currentTabScreen = SearchInitialScreen(
                searchController: _searchController,
                onSubmitted: (query) {
                  context.read<MovieCubit>().setSearchQuery(query);
                },
                onCancel: () {
                  _searchController.clear();
                  context.read<MovieCubit>().setSearchQuery('');
                  context.read<MovieCubit>().setActiveBottomTab(0);
                },
              );
            } else {
              currentTabScreen = SearchResultsScreen(
                initialQuery: state.searchQuery,
                onCancel: () {
                  _searchController.clear();
                  context.read<MovieCubit>().setSearchQuery('');
                },
                onSelectMovie: _navigateToDetail,
              );
            }
            break;
          case 2:
            currentTabScreen = WishlistScreen(
              onBack: () {
                context.read<MovieCubit>().setActiveBottomTab(0);
              },
              onSelectMovie: _navigateToDetail,
            );
            break;
          case 3:
            currentTabScreen = ProfileStack(
              onBottomNavVisibilityChanged: (show) {
                setState(() {
                  _showBottomNavBar = show;
                });
              },
            );
            break;
          default:
            currentTabScreen = _buildHomeScreen(context);
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          body: currentTabScreen,
          bottomNavigationBar: _showBottomNavBar
              ? CustomBottomNavBar(
                  currentIndex: state.activeBottomTab,
                  onTap: (index) {
                    setState(() {
                      _showBottomNavBar = true;
                    });
                    context.read<MovieCubit>().setActiveBottomTab(index);
                    if (_subScreen != _ActiveSubScreen.none) {
                      _popSubScreen();
                    }
                  },
                )
              : null,
        );
      },
    );
  }
}

