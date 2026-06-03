// server.js
// ============================================================
// UPDATE Phase 3: version bump ke 3.0.0, tambah log endpoint baru
// ============================================================

require('dotenv').config();

const express        = require('express');
const cors           = require('cors');
const authRoutes     = require('./routes/authRoutes');
const formulirRoutes = require('./routes/formulirRoutes');
const { testConnection } = require('./config/db');

const app  = express();
const PORT = process.env.PORT || 3000;

// ── Middleware Global ─────────────────────────────────────────
app.use(cors({
  origin: [
    'http://localhost:54041',
    'http://localhost:5000',
    'http://localhost:3000',
    'http://localhost:8080',
    'http://127.0.0.1:5000',
    'http://127.0.0.1:8080',
  ],
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
    version:   '3.0.0',
    timestamp: new Date().toISOString(),
  });
});

app.use('/api/auth',     authRoutes);
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
    console.log(`\n📋 Auth Endpoints:`);
    console.log(`   POST http://localhost:${PORT}/api/auth/register`);
    console.log(`   POST http://localhost:${PORT}/api/auth/login`);
    console.log(`   GET  http://localhost:${PORT}/api/auth/profile`);
    console.log(`\n📋 Formulir Endpoints:`);
    console.log(`   GET  http://localhost:${PORT}/api/formulir/stats`);
    console.log(`   GET  http://localhost:${PORT}/api/formulir/tasks`);
    console.log(`   GET  http://localhost:${PORT}/api/formulir/tasks/:id`);
    console.log(`   POST http://localhost:${PORT}/api/formulir/save`);
    console.log(`   POST http://localhost:${PORT}/api/formulir/submit/:task_id`);
    console.log(`   GET  http://localhost:${PORT}/api/formulir/:task_id`);
    console.log(`\n📋 Scanner Endpoints (Phase 3):`);
    console.log(`   GET  http://localhost:${PORT}/api/formulir/nop/:nop`);
  });
};

startServer();