// middleware/authMiddleware.js
// ============================================================
// Middleware untuk memverifikasi JWT token pada protected routes
// Cara pakai: tambahkan 'authenticateToken' sebelum controller
// Contoh: router.get('/profile', authenticateToken, getProfile)
// ============================================================

const jwt = require('jsonwebtoken');

const authenticateToken = (req, res, next) => {
  // Ambil token dari header Authorization
  // Format header: "Authorization: Bearer <token>"
  const authHeader = req.headers['authorization'];
  const token      = authHeader && authHeader.split(' ')[1]; // Ambil bagian setelah "Bearer "

  if (!token) {
    return res.status(401).json({
      success: false,
      message: 'Akses ditolak. Token tidak ditemukan.',
    });
  }

  try {
    // Verifikasi token menggunakan secret key
    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    // Simpan data user yang ada di token ke req.user
    // Bisa diakses di controller dengan req.user.id, req.user.role, dll
    req.user = decoded;

    next(); // Lanjut ke controller
  } catch (error) {
    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({
        success: false,
        message: 'Sesi kamu telah berakhir. Silakan login kembali.',
      });
    }
    return res.status(403).json({
      success: false,
      message: 'Token tidak valid.',
    });
  }
};

// Middleware untuk cek role admin
const requireAdmin = (req, res, next) => {
  if (req.user && req.user.role === 'admin') {
    next();
  } else {
    return res.status(403).json({
      success: false,
      message: 'Akses ditolak. Hanya admin yang bisa mengakses ini.',
    });
  }
};

module.exports = { authenticateToken, requireAdmin };