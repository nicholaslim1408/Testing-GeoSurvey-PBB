// lib/config/api_config.dart
// ============================================================
// UPDATE Phase 2: tambah endpoint formulir
// ============================================================

class ApiConfig {
  static const String baseUrl = 'http://localhost:3000';

  // ── Auth Endpoints (Phase 1) ──────────────────────────────
  static const String register = '$baseUrl/api/auth/register';
  static const String login    = '$baseUrl/api/auth/login';
  static const String profile  = '$baseUrl/api/auth/profile';

  // ── Formulir Endpoints (Phase 2) ──────────────────────────
  static const String formulirBase   = '$baseUrl/api/formulir';
  static const String formulirStats  = '$baseUrl/api/formulir/stats';
  static const String formulirTasks  = '$baseUrl/api/formulir/tasks';
  static const String formulirSave   = '$baseUrl/api/formulir/save';
  static const String formulirSubmit = '$baseUrl/api/formulir/submit';

  // ── Timeout ───────────────────────────────────────────────
  static const Duration connectTimeout = Duration(seconds: 60);
  static const Duration receiveTimeout = Duration(seconds: 65);
}