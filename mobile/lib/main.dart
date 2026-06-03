// lib/main.dart
// ============================================================
// Entry point utama aplikasi Flutter GeoSurvey PBB
// ============================================================

import 'package:flutter/material.dart';
import 'config/app_theme.dart';
import 'screens/splash_screen.dart';

void main() {
  // Pastikan Flutter sudah ter-initialize sebelum runApp
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const GeoSurveyApp());
}

class GeoSurveyApp extends StatelessWidget {
  const GeoSurveyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GeoSurvey PBB',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,

      // Mulai dari SplashScreen yang akan cek status login
      home: const SplashScreen(),
    );
  }
}
