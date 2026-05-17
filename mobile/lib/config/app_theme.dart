// lib/config/app_theme.dart
// ============================================================
// Theme dan konstanta warna sesuai SRS:
// Color scheme: Kuning, Hijau, Biru
// Typography: Plus Jakarta Sans (via Google Fonts)
// ============================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Primary: Biru (warna utama PBB/pemerintahan)
  static const Color primary       = Color(0xFF1A56DB);
  static const Color primaryLight  = Color(0xFF3B82F6);
  static const Color primaryDark   = Color(0xFF1E3A8A);

  // Accent: Hijau (sukses, approved)
  static const Color accent        = Color(0xFF059669);
  static const Color accentLight   = Color(0xFF10B981);

  // Warning: Kuning (pending, warning)
  static const Color warning       = Color(0xFFF59E0B);
  static const Color warningLight  = Color(0xFFFCD34D);

  // Error: Merah
  static const Color error         = Color(0xFFDC2626);
  static const Color errorLight    = Color(0xFFFEE2E2);

  // Background
  static const Color background    = Color(0xFFF8FAFC);
  static const Color surface       = Color(0xFFFFFFFF);
  static const Color surfaceVariant= Color(0xFFF1F5F9);

  // Text
  static const Color textPrimary   = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textHint      = Color(0xFF94A3B8);

  // Border
  static const Color border        = Color(0xFFE2E8F0);
  static const Color borderFocus   = Color(0xFF1A56DB);

  // Gradient untuk header/splash
  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end:   Alignment.bottomRight,
    colors: [Color(0xFF1E3A8A), Color(0xFF1A56DB), Color(0xFF3B82F6)],
  );
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3:     true,
      colorScheme:      ColorScheme.fromSeed(
        seedColor:  AppColors.primary,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: AppColors.background,

      // Typography: Plus Jakarta Sans
      textTheme: GoogleFonts.plusJakartaSansTextTheme().copyWith(
        displayLarge: GoogleFonts.plusJakartaSans(
          fontSize: 32, fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        displayMedium: GoogleFonts.plusJakartaSans(
          fontSize: 28, fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        headlineLarge: GoogleFonts.plusJakartaSans(
          fontSize: 24, fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        headlineMedium: GoogleFonts.plusJakartaSans(
          fontSize: 20, fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleLarge: GoogleFonts.plusJakartaSans(
          fontSize: 18, fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        bodyLarge: GoogleFonts.plusJakartaSans(
          fontSize: 16, fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
        ),
        bodyMedium: GoogleFonts.plusJakartaSans(
          fontSize: 14, fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
        ),
        labelLarge: GoogleFonts.plusJakartaSans(
          fontSize: 14, fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),

      // ElevatedButton style
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor:    AppColors.primary,
          foregroundColor:    Colors.white,
          minimumSize:        const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 15, fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // InputDecoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled:      true,
        fillColor:   AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderFocus, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        hintStyle: GoogleFonts.plusJakartaSans(
          color: AppColors.textHint, fontSize: 14,
        ),
        labelStyle: GoogleFonts.plusJakartaSans(
          color: AppColors.textSecondary, fontSize: 14,
        ),
        errorStyle: GoogleFonts.plusJakartaSans(
          color: AppColors.error, fontSize: 12,
        ),
      ),
    );
  }
}