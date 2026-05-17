// routes/formulirRoutes.js
// ============================================================
// Definisi semua endpoint untuk Formulir Pendataan (Phase 2)
// Base path: /api/formulir  (didefinisikan di server.js)
// Semua route di sini butuh JWT token (protected)
// ============================================================

const express = require('express');
const {
  getAllTasks,
  getTaskById,
  saveFormulir,
  submitFormulir,
  getFormulirByTask,
  getStats,
} = require('../controllers/formulirController');
const { authenticateToken } = require('../middleware/authMiddleware');

const router = express.Router();

// Semua route formulir wajib login (pakai authenticateToken)

// GET  /api/formulir/stats          → Statistik ringkasan dashboard
router.get('/stats', authenticateToken, getStats);

// GET  /api/formulir/tasks          → Daftar semua survey task
router.get('/tasks', authenticateToken, getAllTasks);

// GET  /api/formulir/tasks/:id      → Detail satu task + formulirnya
router.get('/tasks/:id', authenticateToken, getTaskById);

// POST /api/formulir/save           → Simpan/update formulir (draft)
router.post('/save', authenticateToken, saveFormulir);

// POST /api/formulir/submit/:task_id → Submit formulir (completed)
router.post('/submit/:task_id', authenticateToken, submitFormulir);

// GET  /api/formulir/:task_id       → Ambil formulir berdasarkan task
router.get('/:task_id', authenticateToken, getFormulirByTask);

module.exports = router;
