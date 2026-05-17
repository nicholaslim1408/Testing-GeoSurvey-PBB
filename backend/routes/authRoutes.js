// routes/authRoutes.js
// ============================================================
// Definisi semua endpoint yang berhubungan dengan autentikasi
// Base path: /api/auth  (didefinisikan di server.js)
// ============================================================

const express                             = require('express');
const { register, login, getProfile }     = require('../controllers/authController');
const { authenticateToken }               = require('../middleware/authMiddleware');

const router = express.Router();

// ── Public Routes (tidak butuh token) ────────────────────────
// POST /api/auth/register  → Daftar akun baru
router.post('/register', register);

// POST /api/auth/login     → Login dan dapat JWT token
router.post('/login', login);

// ── Protected Routes (butuh token) ───────────────────────────
// GET /api/auth/profile    → Lihat profil user yang sedang login
router.get('/profile', authenticateToken, getProfile);

module.exports = router;