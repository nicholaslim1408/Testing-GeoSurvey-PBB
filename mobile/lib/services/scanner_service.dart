// lib/services/scanner_service.dart
// ============================================================
// Service layer untuk Scanner NOP (Phase 3)
// Setelah QR/Barcode berhasil discan, NOP dikirim ke API
// untuk mencari data task yang sesuai
// ============================================================

import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/formulir_model.dart';
import '../utils/storage_helper.dart';

// Hasil pencarian NOP
class NopSearchResult {
  final bool        success;
  final String      message;
  final SurveyTask? task;
  final bool        hasFormulir; // apakah task sudah punya formulir

  const NopSearchResult({
    required this.success,
    required this.message,
    this.task,
    this.hasFormulir = false,
  });
}

class ScannerService {
  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      headers:        {'Content-Type': 'application/json'},
    ),
  );

  // Helper: Authorization header
  static Future<Options> _authOptions() async {
    final token = await StorageHelper.getToken();
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  // ── CARI TASK BERDASARKAN NOP ─────────────────────────────
  // Dipanggil setelah scanner berhasil membaca QR/Barcode
  static Future<NopSearchResult> findTaskByNop(String rawNop) async {
    try {
      // Bersihkan NOP dari karakter yang tidak perlu
      final nop = rawNop.trim();

      if (nop.isEmpty) {
        return const NopSearchResult(
          success: false,
          message: 'NOP tidak boleh kosong.',
        );
      }

      // Encode NOP untuk URL (titik dan spasi perlu di-encode)
      final encodedNop = Uri.encodeComponent(nop);

      final response = await _dio.get(
        '${ApiConfig.formulirByNop}/$encodedNop',
        options: await _authOptions(),
      );

      final data = response.data;

      if (data['success'] == true) {
        final taskJson = data['data']['task'] as Map<String, dynamic>;
        final task     = SurveyTask.fromJson(taskJson);
        final hasForm  = data['data']['formulir'] != null;

        return NopSearchResult(
          success:     true,
          message:     data['message'] ?? 'Task ditemukan',
          task:        task,
          hasFormulir: hasForm,
        );
      }

      return NopSearchResult(
        success: false,
        message: data['message'] ?? 'NOP tidak ditemukan',
      );
    } on DioException catch (e) {
      // 404 = NOP tidak ditemukan di database
      if (e.response?.statusCode == 404) {
        final msg = e.response?.data?['message'] as String?
            ?? 'NOP tidak ditemukan dalam database.';
        return NopSearchResult(success: false, message: msg);
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return const NopSearchResult(
          success: false,
          message: 'Koneksi timeout. Periksa jaringan kamu.',
        );
      }
      if (e.type == DioExceptionType.connectionError) {
        return const NopSearchResult(
          success: false,
          message: 'Tidak bisa terhubung ke server. '
                   'Pastikan backend sudah berjalan.',
        );
      }
      return NopSearchResult(
        success: false,
        message: 'Terjadi kesalahan jaringan: ${e.message}',
      );
    } catch (e) {
      return NopSearchResult(
        success: false,
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  // ── VALIDASI FORMAT NOP ───────────────────────────────────
  // NOP valid: minimal 10 karakter, mengandung angka
  // Contoh valid: "32.04.010.001.001.0001.0" atau "32040100010010001 0"
  static bool isValidNopFormat(String nop) {
    final cleaned = nop.replaceAll(RegExp(r'[\s.]'), '');
    // NOP harus berisi angka saja setelah dibersihkan, min 10 digit
    return RegExp(r'^\d{10,}').hasMatch(cleaned);
  }
}