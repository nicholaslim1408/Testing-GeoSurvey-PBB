// lib/config/api_config.dart
// ============================================================
// UPDATE Phase 3: tambah endpoint search by NOP
// ============================================================

class ApiConfig {
  static const String baseUrl = 'http://10.65.74.61:3000';

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

  // ── Scanner Endpoints (Phase 3) ───────────────────────────
  // GET /api/formulir/nop/:nop → cari task berdasarkan NOP hasil scan
  static const String formulirByNop = '$baseUrl/api/formulir/nop';

  // ── Timeout ───────────────────────────────────────────────
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 15);
}