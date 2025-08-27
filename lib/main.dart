import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const InfiniteChallengeApp());
}

class InfiniteChallengeApp extends StatelessWidget {
  const InfiniteChallengeApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return MaterialApp(
      title: 'Infinite Challenge',
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}