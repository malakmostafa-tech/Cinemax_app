import 'package:flutter/material.dart';
import 'package:cinemax_app/features/onboarding/presentation/pages/onboarding_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CINEMAX',
      debugShowCheckedModeBanner: false,
      home: const OnboardingScreen(),
    );
  }
}
