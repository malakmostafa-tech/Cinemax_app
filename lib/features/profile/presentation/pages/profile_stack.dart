import 'package:flutter/material.dart';
import 'package:cinemax_app/features/profile/presentation/pages/edit_profile_screen.dart';
import 'package:cinemax_app/features/profile/presentation/pages/language_screen.dart';
import 'package:cinemax_app/features/profile/presentation/pages/notifications_screen.dart';
import 'package:cinemax_app/features/profile/presentation/pages/privacy_policy_screen.dart';
import 'package:cinemax_app/features/profile/presentation/pages/profile_screen.dart';

enum ProfileSubScreen {
  main,
  editProfile,
  privacyPolicy,
  notifications,
  language,
}

class ProfileStack extends StatefulWidget {
  final Function(bool showBottomNav) onBottomNavVisibilityChanged;

  const ProfileStack({
    super.key,
    required this.onBottomNavVisibilityChanged,
  });

  @override
  State<ProfileStack> createState() => _ProfileStackState();
}

class _ProfileStackState extends State<ProfileStack> {
  ProfileSubScreen _currentSubScreen = ProfileSubScreen.main;

  void _navigateTo(ProfileSubScreen subScreen) {
    setState(() {
      _currentSubScreen = subScreen;
    });
    final hideNav = subScreen != ProfileSubScreen.main;
    widget.onBottomNavVisibilityChanged(!hideNav);
  }

  void _popToMain() {
    setState(() {
      _currentSubScreen = ProfileSubScreen.main;
    });
    widget.onBottomNavVisibilityChanged(true);
  }

  @override
  Widget build(BuildContext context) {
    switch (_currentSubScreen) {
      case ProfileSubScreen.editProfile:
        return EditProfileScreen(
          onBack: _popToMain,
        );
      case ProfileSubScreen.privacyPolicy:
        return PrivacyPolicyScreen(
          onBack: _popToMain,
        );
      case ProfileSubScreen.notifications:
        return NotificationsScreen(
          onBack: _popToMain,
        );
      case ProfileSubScreen.language:
        return LanguageScreen(
          onBack: _popToMain,
        );
      case ProfileSubScreen.main:
        return ProfileScreen(
          onNavigateToEditProfile: () => _navigateTo(ProfileSubScreen.editProfile),
          onNavigateToNotifications: () => _navigateTo(ProfileSubScreen.notifications),
          onNavigateToLanguage: () => _navigateTo(ProfileSubScreen.language),
          onNavigateToPrivacyPolicy: () => _navigateTo(ProfileSubScreen.privacyPolicy),
        );
    }
  }
}
