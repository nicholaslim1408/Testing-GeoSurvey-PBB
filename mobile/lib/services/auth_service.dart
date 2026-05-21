// lib/services/auth_service.dart
// ============================================================
// Service layer untuk semua API call yang berhubungan dengan auth
// Menggunakan Dio sebagai HTTP client
// ============================================================

import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/user_model.dart';
import '../utils/storage_helper.dart';

// Model untuk hasil operasi auth
class AuthResult {
  final bool    success;
  final String  message;
  final String? token;
  final UserModel? user;

  const AuthResult({
    required this.success,
    required this.message,
    this.token,
    this.user,
  });
}

class AuthService {
  // Singleton Dio instance
  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      headers: {'Content-Type': 'application/json'},
    ),
  );

  // ── REGISTER ───────────────────────────────────────────────
  static Future<AuthResult> register({
    required String username,
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final response = await _dio.post(
        ApiConfig.register,
        data: {
          'username':  username.trim(),
          'email':     email.trim().toLowerCase(),
          'password':  password,
          'full_name': fullName.trim(),
        },
      );

      final data = response.data;
      return AuthResult(
        success: data['success'] == true,
        message: data['message'] ?? 'Registrasi berhasil',
      );
    } on DioException catch (e) {
      return AuthResult(
        success: false,
        message: _parseDioError(e),
      );
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'Terjadi kesalahan. Coba lagi.',
      );
    }
  }

  // ── LOGIN ──────────────────────────────────────────────────
  static Future<AuthResult> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiConfig.login,
        data: {
          'username': username.trim(),
          'password': password,
        },
      );

      final data = response.data;

      if (data['success'] == true) {
        final token = data['data']['token'] as String;
        final user  = UserModel.fromJson(data['data']['user']);

        // Simpan token dan user ke storage lokal
        await StorageHelper.saveToken(token);
        await StorageHelper.saveUser(user);

        return AuthResult(
          success: true,
          message: data['message'] ?? 'Login berhasil',
          token:   token,
          user:    user,
        );
      }

      return AuthResult(
        success: false,
        message: data['message'] ?? 'Login gagal',
      );
    } on DioException catch (e) {
      return AuthResult(
        success: false,
        message: _parseDioError(e),
      );
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'Terjadi kesalahan. Coba lagi.',
      );
    }
  }

  // ── LOGOUT ─────────────────────────────────────────────────
  static Future<void> logout() async {
    await StorageHelper.clearAll();
  }

  // ── Parse error message dari DioException ──────────────────
  static String _parseDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Koneksi timeout. Periksa jaringan kamu.';
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'Tidak bisa terhubung ke server. Coba Hubungi admin jika masalah berlanjut.';
    }
    // Error dari response server (400, 401, 403, 409, 500)
    if (e.response != null && e.response!.data != null) {
      final data = e.response!.data;
      if (data is Map && data.containsKey('message')) {
        return data['message'] as String;
      }
    }
    return 'Terjadi kesalahan jaringan.';
  }
}