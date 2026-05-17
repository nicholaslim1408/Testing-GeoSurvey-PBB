// lib/utils/storage_helper.dart
// ============================================================
// Helper untuk menyimpan dan mengambil data lokal
// Menggunakan SharedPreferences (bekerja di Flutter Web)
// ============================================================

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class StorageHelper {
  // Key constants untuk SharedPreferences
  static const String _tokenKey    = 'jwt_token';
  static const String _userKey     = 'user_data';
  static const String _isLoggedKey = 'is_logged_in';

  // ── Simpan token JWT ──────────────────────────────────────
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setBool(_isLoggedKey, true);
  }

  // ── Ambil token JWT ───────────────────────────────────────
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // ── Simpan data user ──────────────────────────────────────
  static Future<void> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  // ── Ambil data user ───────────────────────────────────────
  static Future<UserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson == null) return null;
    return UserModel.fromJson(jsonDecode(userJson));
  }

  // ── Cek apakah user sudah login ───────────────────────────
  static Future<bool> isLoggedIn() async {
    final prefs  = await SharedPreferences.getInstance();
    final token  = prefs.getString(_tokenKey);
    final logged = prefs.getBool(_isLoggedKey) ?? false;
    return logged && token != null && token.isNotEmpty;
  }

  // ── Hapus semua data (logout) ─────────────────────────────
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    await prefs.remove(_isLoggedKey);
  }
}