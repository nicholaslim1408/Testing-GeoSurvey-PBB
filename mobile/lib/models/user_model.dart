// lib/models/user_model.dart
// ============================================================
// Model data untuk User
// Digunakan untuk parse response JSON dari API
// ============================================================

class UserModel {
  final int    id;
  final String username;
  final String email;
  final String fullName;
  final String role;

  const UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.fullName,
    required this.role,
  });

  // Buat UserModel dari JSON response API
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id:       json['id']        as int,
      username: json['username']  as String,
      email:    json['email']     as String,
      fullName: json['full_name'] as String? ?? '',
      role:     json['role']      as String,
    );
  }

  // Konversi ke Map untuk disimpan di SharedPreferences
  Map<String, dynamic> toJson() => {
    'id':        id,
    'username':  username,
    'email':     email,
    'full_name': fullName,
    'role':      role,
  };
}