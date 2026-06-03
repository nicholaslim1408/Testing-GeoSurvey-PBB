// lib/main.dart
// ============================================================
// Entry point utama aplikasi Flutter GeoSurvey PBB
// ============================================================

import 'package:flutter/material.dart';
import 'config/app_theme.dart';
import 'screens/formulir_screen.dart';
import 'models/formulir_model.dart';

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

      // Bypass login untuk testing FormulirScreen
      home: FormulirScreen(
        task: const SurveyTask(
          id: 1,
          nop: '1234567890',
          namaWp: 'Dummy Wajib Pajak',
          alamatOp: 'Jl. Dummy Alamat No. 1',
          kdKecamatan: '01',
          kdKelurahan: '01',
          kdBlok: '001',
          noUrut: '0001',
          kdJnsOp: '0',
          statusTask: 'pending',
        ),
      ),
    );
  }
}
