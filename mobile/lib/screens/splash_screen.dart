// lib/screens/splash_screen.dart
// ============================================================
// Splash screen - cek apakah user sudah login atau belum
// Tampil sebentar lalu redirect ke halaman yang sesuai
// ============================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/app_theme.dart';
import '../utils/storage_helper.dart';
import 'login_screen.dart';
import 'dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double>    _scaleAnim;
  late Animation<double>    _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 1000),
    );
    _scaleAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Delay untuk splash screen terlihat
    await Future.delayed(const Duration(milliseconds: 1800));

    if (!mounted) return;

    final isLoggedIn = await StorageHelper.isLoggedIn();

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => isLoggedIn
            ? const DashboardScreen()
            : const LoginScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.headerGradient,
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: ScaleTransition(
              scale: _scaleAnim,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon
                  Container(
                    padding:    const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color:        Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: const Icon(
                      Icons.map_rounded,
                      size:  64,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // App Name
                  Text(
                    'GeoSurvey PBB',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize:   32,
                      fontWeight: FontWeight.w800,
                      color:      Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sistem Pendataan Pajak Bumi dan Bangunan',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color:    Colors.white.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Loading indicator
                  SizedBox(
                    width:  24, height: 24,
                    child:  CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color:       Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}