// server.js
// ============================================================
// Entry point utama backend GeoSurvey PBB
// UPDATE Phase 2: tambah formulirRoutes
// ============================================================

require('dotenv').config();

const express        = require('express');
const cors           = require('cors');
const authRoutes     = require('./routes/authRoutes');
const formulirRoutes = require('./routes/formulirRoutes'); // ← BARU Phase 2
const { testConnection } = require('./config/db');

const app  = express();
const PORT = process.env.PORT || 3000;

// ── Middleware Global ─────────────────────────────────────────
app.use(cors({
  origin: function (origin, callback) {
    // Izinkan semua origin (berguna untuk Flutter Web yang port-nya sering berubah-ubah)
    callback(null, true);
  },
  methods:        ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  credentials:    true,
}));

app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// ── Routes ───────────────────────────────────────────────────
app.get('/', (req, res) => {
  res.json({
    success:   true,
    message:   '🌍 GeoSurvey PBB API is running!',
    version:   '2.0.0',
    timestamp: new Date().toISOString(),
  });
});

// Phase 1 - Auth
app.use('/api/auth',     authRoutes);

// Phase 2 - Formulir Pendataan
app.use('/api/formulir', formulirRoutes);

// ── 404 Handler ───────────────────────────────────────────────
app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: `Endpoint ${req.method} ${req.path} tidak ditemukan`,
  });
});

// ── Global Error Handler ──────────────────────────────────────
app.use((err, req, res, next) => {
  console.error('Unhandled error:', err);
  res.status(500).json({
    success: false,
    message: 'Terjadi kesalahan server yang tidak terduga.',
  });
});

// ── Start Server ──────────────────────────────────────────────
const startServer = async () => {
  await testConnection();
  app.listen(PORT, () => {
    console.log(`🚀 Server berjalan di http://localhost:${PORT}`);
    console.log(`📋 Endpoints:`);
    console.log(`   POST http://localhost:${PORT}/api/auth/register`);
    console.log(`   POST http://localhost:${PORT}/api/auth/login`);
    console.log(`   GET  http://localhost:${PORT}/api/auth/profile`);
    console.log(`   GET  http://localhost:${PORT}/api/formulir/stats`);
    console.log(`   GET  http://localhost:${PORT}/api/formulir/tasks`);
    console.log(`   GET  http://localhost:${PORT}/api/formulir/tasks/:id`);
    console.log(`   POST http://localhost:${PORT}/api/formulir/save`);
    console.log(`   POST http://localhost:${PORT}/api/formulir/submit/:task_id`);
    console.log(`   GET  http://localhost:${PORT}/api/formulir/:task_id`);
  });
};

startServer();