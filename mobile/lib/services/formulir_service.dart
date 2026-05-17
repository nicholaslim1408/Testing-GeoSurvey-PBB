// lib/services/formulir_service.dart
// ============================================================
// Service layer untuk semua API call Formulir Pendataan
// ============================================================

import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/formulir_model.dart';
import '../utils/storage_helper.dart';

// Hasil operasi generik
class ServiceResult<T> {
  final bool    success;
  final String  message;
  final T?      data;

  const ServiceResult({
    required this.success,
    required this.message,
    this.data,
  });
}

class FormulirService {
  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      headers:        {'Content-Type': 'application/json'},
    ),
  );

  // Helper: tambahkan Authorization header dari token yang tersimpan
  static Future<Options> _authOptions() async {
    final token = await StorageHelper.getToken();
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  // ── GET STATS ───────────────────────────────────────────────
  static Future<ServiceResult<TaskStats>> getStats() async {
    try {
      final response = await _dio.get(
        ApiConfig.formulirStats,
        options: await _authOptions(),
      );
      final data = response.data;
      if (data['success'] == true) {
        return ServiceResult(
          success: true,
          message: 'OK',
          data:    TaskStats.fromJson(data['data']),
        );
      }
      return ServiceResult(success: false, message: data['message'] ?? 'Gagal');
    } on DioException catch (e) {
      return ServiceResult(success: false, message: _parseError(e));
    }
  }

  // ── GET ALL TASKS ───────────────────────────────────────────
  static Future<ServiceResult<List<SurveyTask>>> getAllTasks({
    String? status,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (status != null && status.isNotEmpty) queryParams['status'] = status;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final response = await _dio.get(
        ApiConfig.formulirTasks,
        queryParameters: queryParams,
        options:         await _authOptions(),
      );

      final data = response.data;
      if (data['success'] == true) {
        final list = (data['data'] as List)
            .map((e) => SurveyTask.fromJson(e as Map<String, dynamic>))
            .toList();
        return ServiceResult(success: true, message: 'OK', data: list);
      }
      return ServiceResult(success: false, message: data['message'] ?? 'Gagal');
    } on DioException catch (e) {
      return ServiceResult(success: false, message: _parseError(e));
    }
  }

  // ── GET TASK BY ID ──────────────────────────────────────────
  static Future<ServiceResult<Map<String, dynamic>>> getTaskById(int id) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.formulirTasks}/$id',
        options: await _authOptions(),
      );
      final data = response.data;
      if (data['success'] == true) {
        return ServiceResult(
          success: true,
          message: 'OK',
          data:    data['data'] as Map<String, dynamic>,
        );
      }
      return ServiceResult(success: false, message: data['message'] ?? 'Gagal');
    } on DioException catch (e) {
      return ServiceResult(success: false, message: _parseError(e));
    }
  }

  // ── SAVE FORMULIR (draft) ───────────────────────────────────
  static Future<ServiceResult<int?>> saveFormulir(FormulirModel formulir) async {
    try {
      final response = await _dio.post(
        ApiConfig.formulirSave,
        data:    formulir.toJson(),
        options: await _authOptions(),
      );
      final data = response.data;
      if (data['success'] == true) {
        return ServiceResult(
          success: true,
          message: data['message'] ?? 'Berhasil disimpan',
          data:    data['data']?['formulir_id'] as int?,
        );
      }
      return ServiceResult(success: false, message: data['message'] ?? 'Gagal');
    } on DioException catch (e) {
      return ServiceResult(success: false, message: _parseError(e));
    }
  }

  // ── SUBMIT FORMULIR (completed) ─────────────────────────────
  static Future<ServiceResult<void>> submitFormulir(int taskId) async {
    try {
      final response = await _dio.post(
        '${ApiConfig.formulirSubmit}/$taskId',
        options: await _authOptions(),
      );
      final data = response.data;
      return ServiceResult(
        success: data['success'] == true,
        message: data['message'] ?? 'Gagal submit',
      );
    } on DioException catch (e) {
      return ServiceResult(success: false, message: _parseError(e));
    }
  }

  // ── GET FORMULIR BY TASK ────────────────────────────────────
  static Future<ServiceResult<FormulirModel>> getFormulirByTask(int taskId) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.formulirBase}/$taskId',
        options: await _authOptions(),
      );
      final data = response.data;
      if (data['success'] == true) {
        return ServiceResult(
          success: true,
          message: 'OK',
          data:    FormulirModel.fromJson(data['data']),
        );
      }
      return ServiceResult(success: false, message: data['message'] ?? 'Gagal');
    } on DioException catch (e) {
      return ServiceResult(success: false, message: _parseError(e));
    }
  }

  // ── Parse DioException ──────────────────────────────────────
  static String _parseError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Koneksi timeout. Periksa jaringan kamu.';
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'Tidak bisa terhubung ke server.';
    }
    if (e.response?.data != null) {
      final d = e.response!.data;
      if (d is Map && d.containsKey('message')) return d['message'] as String;
    }
    return 'Terjadi kesalahan jaringan.';
  }
}