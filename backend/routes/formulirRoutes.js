// routes/formulirRoutes.js
// ============================================================
// UPDATE Phase 3: tambah route GET /nop/:nop untuk Scanner
// PENTING: route /nop/:nop harus didefinisikan SEBELUM /:task_id
// supaya Express tidak salah tangkap "nop" sebagai task_id
// ============================================================

const express = require('express');
const {
  getAllTasks,
  getTaskById,
  getTaskByNop,
  saveFormulir,
  submitFormulir,
  getFormulirByTask,
  getStats,
} = require('../controllers/formulirController');
const { authenticateToken } = require('../middleware/authMiddleware');

const router = express.Router();

// ── Semua route butuh JWT token ───────────────────────────────

// GET  /api/formulir/stats          → Statistik dashboard
router.get('/stats',           authenticateToken, getStats);

// GET  /api/formulir/tasks          → Daftar semua task
router.get('/tasks',           authenticateToken, getAllTasks);

// GET  /api/formulir/tasks/:id      → Detail satu task
router.get('/tasks/:id',       authenticateToken, getTaskById);

// GET  /api/formulir/nop/:nop       → Cari task by NOP (Phase 3 Scanner)
// Contoh: GET /api/formulir/nop/32.04.010.001.001.0001.0
router.get('/nop/:nop',        authenticateToken, getTaskByNop);

// POST /api/formulir/save           → Simpan/update formulir (draft)
router.post('/save',           authenticateToken, saveFormulir);

// POST /api/formulir/submit/:task_id → Submit formulir (completed)
router.post('/submit/:task_id',authenticateToken, submitFormulir);

// GET  /api/formulir/:task_id       → Ambil formulir by task
// HARUS di bawah semua route spesifik agar tidak bentrok
router.get('/:task_id',        authenticateToken, getFormulirByTask);

module.exports = router;