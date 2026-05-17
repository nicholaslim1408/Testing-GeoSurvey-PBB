// controllers/authController.js
// ============================================================
// Logika bisnis untuk Register dan Login
// Semua validasi, hashing, dan JWT generation ada di sini
// ============================================================

const bcrypt   = require('bcrypt');
const jwt      = require('jsonwebtoken');
const { pool } = require('../config/db');

// ─────────────────────────────────────────────────────────────
// REGISTER
// POST /api/auth/register
// Body: { username, email, password, full_name }
// ─────────────────────────────────────────────────────────────
const register = async (req, res) => {
  try {
    const { username, email, password, full_name } = req.body;

    // ── 1. Validasi field wajib ──────────────────────────────
    if (!username || !email || !password || !full_name) {
      return res.status(400).json({
        success: false,
        message: 'Semua field wajib diisi: username, email, password, full_name',
      });
    }

    // ── 2. Validasi format email ─────────────────────────────
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
      return res.status(400).json({
        success: false,
        message: 'Format email tidak valid',
      });
    }

    // ── 3. Validasi kekuatan password ────────────────────────
    // Min 8 karakter, ada huruf besar, kecil, angka, dan simbol
    const passwordRegex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&_\-#])[A-Za-z\d@$!%*?&_\-#]{8,}$/;
    if (!passwordRegex.test(password)) {
      return res.status(400).json({
        success: false,
        message:
          'Password minimal 8 karakter, mengandung huruf besar, huruf kecil, angka, dan simbol (@$!%*?&_-#)',
      });
    }

    // ── 4. Cek apakah username atau email sudah dipakai ──────
    const [existingUsers] = await pool.query(
      'SELECT id FROM users WHERE username = ? OR email = ?',
      [username.trim(), email.trim().toLowerCase()]
    );

    if (existingUsers.length > 0) {
      return res.status(409).json({
        success: false,
        message: 'Username atau email sudah terdaftar',
      });
    }

    // ── 5. Hash password dengan bcrypt (cost factor 12) ──────
    const saltRounds = 12;
    const hashedPassword = await bcrypt.hash(password, saltRounds);

    // ── 6. Simpan user baru ke database ──────────────────────
    // Role default: 'enumerator', is_approved default: 0 (pending)
    const [result] = await pool.query(
      `INSERT INTO users (username, email, password, full_name, role, is_approved)
       VALUES (?, ?, ?, ?, 'enumerator', 0)`,
      [
        username.trim(),
        email.trim().toLowerCase(),
        hashedPassword,
        full_name.trim(),
      ]
    );

    return res.status(201).json({
      success: true,
      message:
        'Registrasi berhasil! Akun kamu sedang menunggu persetujuan admin. ' +
        'Kamu akan bisa login setelah disetujui.',
      data: {
        id:       result.insertId,
        username: username.trim(),
        email:    email.trim().toLowerCase(),
        role:     'enumerator',
      },
    });
  } catch (error) {
    console.error('Register error:', error);
    return res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan server. Silakan coba lagi.',
    });
  }
};

// ─────────────────────────────────────────────────────────────
// LOGIN
// POST /api/auth/login
// Body: { username, password }  (bisa juga pakai email)
// ─────────────────────────────────────────────────────────────
const login = async (req, res) => {
  try {
    const { username, password } = req.body;

    // ── 1. Validasi field wajib ──────────────────────────────
    if (!username || !password) {
      return res.status(400).json({
        success: false,
        message: 'Username/email dan password wajib diisi',
      });
    }

    // ── 2. Cari user berdasarkan username ATAU email ─────────
    const [users] = await pool.query(
      'SELECT * FROM users WHERE username = ? OR email = ?',
      [username.trim(), username.trim().toLowerCase()]
    );

    if (users.length === 0) {
      return res.status(401).json({
        success: false,
        message: 'Username/email atau password salah',
      });
    }

    const user = users[0];

    // ── 3. Verifikasi password dengan bcrypt ─────────────────
    const isPasswordValid = await bcrypt.compare(password, user.password);
    if (!isPasswordValid) {
      return res.status(401).json({
        success: false,
        message: 'Username/email atau password salah',
      });
    }

    // ── 4. Cek status approval ───────────────────────────────
    if (user.is_approved === 0) {
      return res.status(403).json({
        success: false,
        message:
          'Akun kamu belum disetujui admin. Silakan tunggu konfirmasi.',
      });
    }

    // ── 5. Generate JWT token ────────────────────────────────
    const tokenPayload = {
      id:       user.id,
      username: user.username,
      email:    user.email,
      role:     user.role,
    };

    const token = jwt.sign(tokenPayload, process.env.JWT_SECRET, {
      expiresIn: process.env.JWT_EXPIRES_IN || '7d',
    });

    // ── 6. Response sukses (password tidak dikirim ke client) ─
    return res.status(200).json({
      success: true,
      message: 'Login berhasil!',
      data: {
        token,
        user: {
          id:        user.id,
          username:  user.username,
          email:     user.email,
          full_name: user.full_name,
          role:      user.role,
        },
      },
    });
  } catch (error) {
    console.error('Login error:', error);
    return res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan server. Silakan coba lagi.',
    });
  }
};

// ─────────────────────────────────────────────────────────────
// GET PROFILE (Protected)
// GET /api/auth/profile
// Header: Authorization: Bearer <token>
// ─────────────────────────────────────────────────────────────
const getProfile = async (req, res) => {
  try {
    // req.user diisi oleh authMiddleware
    const [users] = await pool.query(
      'SELECT id, username, email, full_name, role, is_approved, created_at FROM users WHERE id = ?',
      [req.user.id]
    );

    if (users.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'User tidak ditemukan',
      });
    }

    return res.status(200).json({
      success: true,
      data: users[0],
    });
  } catch (error) {
    console.error('Get profile error:', error);
    return res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan server.',
    });
  }
};

module.exports = { register, login, getProfile };