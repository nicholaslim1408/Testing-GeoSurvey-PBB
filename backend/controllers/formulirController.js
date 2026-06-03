// controllers/formulirController.js
// ============================================================
// Logika bisnis untuk Formulir Pendataan (Phase 2)
// ============================================================

const { pool } = require('../config/db');

// ─────────────────────────────────────────────────────────────
// GET ALL TASKS  —  GET /api/formulir/tasks
// Ambil semua survey task (bisa filter by status)
// ─────────────────────────────────────────────────────────────
const getAllTasks = async (req, res) => {
  try {
    const { status, search } = req.query;

    let query = `
      SELECT
        t.*,
        u.full_name   AS enumerator_name,
        f.id          AS formulir_id,
        f.status_sync AS formulir_status
      FROM survey_tasks t
      LEFT JOIN users             u ON t.assigned_to     = u.id
      LEFT JOIN formulir_pendataan f ON t.id             = f.task_id
    `;

    const params = [];
    const conditions = [];

    if (status) {
      conditions.push('t.status_task = ?');
      params.push(status);
    }

    if (search) {
      conditions.push('(t.nop LIKE ? OR t.nama_wp LIKE ? OR t.alamat_op LIKE ?)');
      const like = `%${search}%`;
      params.push(like, like, like);
    }

    if (conditions.length > 0) {
      query += ' WHERE ' + conditions.join(' AND ');
    }

    query += ' ORDER BY t.created_at DESC';

    const [tasks] = await pool.query(query, params);

    return res.status(200).json({
      success: true,
      data: tasks,
      total: tasks.length,
    });
  } catch (error) {
    console.error('getAllTasks error:', error);
    return res.status(500).json({ success: false, message: 'Gagal mengambil data tasks.' });
  }
};

// ─────────────────────────────────────────────────────────────
// GET TASK BY ID  —  GET /api/formulir/tasks/:id
// ─────────────────────────────────────────────────────────────
const getTaskById = async (req, res) => {
  try {
    const { id } = req.params;

    const [tasks] = await pool.query(
      `SELECT t.*, u.full_name AS enumerator_name
       FROM survey_tasks t
       LEFT JOIN users u ON t.assigned_to = u.id
       WHERE t.id = ?`,
      [id]
    );

    if (tasks.length === 0) {
      return res.status(404).json({ success: false, message: 'Task tidak ditemukan.' });
    }

    // Cek apakah sudah ada formulir untuk task ini
    const [formulir] = await pool.query(
      'SELECT * FROM formulir_pendataan WHERE task_id = ?',
      [id]
    );

    return res.status(200).json({
      success: true,
      data: {
        task: tasks[0],
        formulir: formulir.length > 0 ? formulir[0] : null,
      },
    });
  } catch (error) {
    console.error('getTaskById error:', error);
    return res.status(500).json({ success: false, message: 'Gagal mengambil data task.' });
  }
};

// ─────────────────────────────────────────────────────────────
// SAVE FORMULIR  —  POST /api/formulir/save
// Upsert: buat baru atau update jika sudah ada
// ─────────────────────────────────────────────────────────────
const saveFormulir = async (req, res) => {
  try {
    const enumeratorId = req.user.id; // dari JWT middleware

    const {
      task_id,
      nop,
      // Data tanah
      luas_bumi,
      jenis_bumi,
      kondisi_tanah,
      // Data bangunan
      luas_bangunan,
      jumlah_lantai,
      tahun_dibangun,
      kondisi_bangunan,
      // Material
      material_dinding,
      material_atap,
      material_lantai,
      // Lainnya
      fasilitas,
      catatan,
      penggunaan_bangunan,
      status_kepemilikan,
      tahun_renovasi,
      daya_listrik,
      akses_jalan,
      lebar_jalan,
      pagar,
      sumber_air,
      status_hunian,
    } = req.body;

    // ── Validasi field wajib ──────────────────────────────────
    if (!task_id || !nop) {
      return res.status(400).json({
        success: false,
        message: 'task_id dan nop wajib diisi.',
      });
    }
    if (!luas_bumi && luas_bumi !== 0) {
      return res.status(400).json({
        success: false,
        message: 'Luas bumi wajib diisi.',
      });
    }
    if (!luas_bangunan && luas_bangunan !== 0) {
      return res.status(400).json({
        success: false,
        message: 'Luas bangunan wajib diisi.',
      });
    }

    // ── Cek task ada ──────────────────────────────────────────
    const [tasks] = await pool.query(
      'SELECT id FROM survey_tasks WHERE id = ?',
      [task_id]
    );
    if (tasks.length === 0) {
      return res.status(404).json({ success: false, message: 'Task tidak ditemukan.' });
    }

    // ── Cek apakah formulir sudah ada untuk task ini ──────────
    const [existing] = await pool.query(
      'SELECT id FROM formulir_pendataan WHERE task_id = ?',
      [task_id]
    );

    const fasilitasJson = fasilitas
      ? JSON.stringify(Array.isArray(fasilitas) ? fasilitas : [fasilitas])
      : null;

    if (existing.length > 0) {
      // ── UPDATE formulir yang sudah ada ────────────────────
      await pool.query(
        `UPDATE formulir_pendataan SET
          luas_bumi        = ?, jenis_bumi       = ?, kondisi_tanah    = ?,
          luas_bangunan    = ?, jumlah_lantai    = ?, tahun_dibangun   = ?,
          kondisi_bangunan = ?, material_dinding = ?, material_atap    = ?,
          material_lantai  = ?, fasilitas        = ?, catatan          = ?,
          penggunaan_bangunan = ?, status_kepemilikan = ?, tahun_renovasi = ?,
          daya_listrik     = ?, akses_jalan      = ?, lebar_jalan      = ?,
          pagar            = ?, sumber_air       = ?, status_hunian    = ?,
          status_sync      = 'draft'
        WHERE task_id = ?`,
        [
          luas_bumi || 0,
          jenis_bumi || null,
          kondisi_tanah || null,
          luas_bangunan || 0,
          jumlah_lantai || 1,
          tahun_dibangun || null,
          kondisi_bangunan || null,
          material_dinding || null,
          material_atap || null,
          material_lantai || null,
          fasilitasJson,
          catatan || null,
          penggunaan_bangunan || null,
          status_kepemilikan || null,
          tahun_renovasi || null,
          daya_listrik || null,
          akses_jalan || null,
          lebar_jalan || null,
          pagar || null,
          sumber_air || null,
          status_hunian || null,
          task_id,
        ]
      );

      // Update status task jadi in_progress
      await pool.query(
        "UPDATE survey_tasks SET status_task = 'in_progress' WHERE id = ?",
        [task_id]
      );

      return res.status(200).json({
        success: true,
        message: 'Formulir berhasil diperbarui.',
        data: { formulir_id: existing[0].id },
      });
    } else {
      // ── INSERT formulir baru ──────────────────────────────
      const [result] = await pool.query(
        `INSERT INTO formulir_pendataan
          (task_id, enumerator_id, nop,
           luas_bumi, jenis_bumi, kondisi_tanah,
           luas_bangunan, jumlah_lantai, tahun_dibangun, kondisi_bangunan,
           material_dinding, material_atap, material_lantai,
           fasilitas, catatan,
           penggunaan_bangunan, status_kepemilikan, tahun_renovasi,
           daya_listrik, akses_jalan, lebar_jalan,
           pagar, sumber_air, status_hunian,
           status_sync)
         VALUES (?,?,?, ?,?,?, ?,?,?,?, ?,?,?, ?,?, ?,?,?, ?,?,?, ?,?,?, 'draft')`,
        [
          task_id,
          enumeratorId,
          nop,
          luas_bumi || 0,
          jenis_bumi || null,
          kondisi_tanah || null,
          luas_bangunan || 0,
          jumlah_lantai || 1,
          tahun_dibangun || null,
          kondisi_bangunan || null,
          material_dinding || null,
          material_atap || null,
          material_lantai || null,
          fasilitasJson,
          catatan || null,
          penggunaan_bangunan || null,
          status_kepemilikan || null,
          tahun_renovasi || null,
          daya_listrik || null,
          akses_jalan || null,
          lebar_jalan || null,
          pagar || null,
          sumber_air || null,
          status_hunian || null,
        ]
      );

      // Update status task jadi in_progress
      await pool.query(
        "UPDATE survey_tasks SET status_task = 'in_progress', assigned_to = ? WHERE id = ?",
        [enumeratorId, task_id]
      );

      return res.status(201).json({
        success: true,
        message: 'Formulir berhasil disimpan.',
        data: { formulir_id: result.insertId },
      });
    }
  } catch (error) {
    console.error('saveFormulir error:', error);
    return res.status(500).json({ success: false, message: 'Gagal menyimpan formulir.' });
  }
};

// ─────────────────────────────────────────────────────────────
// SUBMIT FORMULIR  —  POST /api/formulir/submit/:task_id
// Tandai formulir sebagai completed (siap sync ke SIMPBB)
// ─────────────────────────────────────────────────────────────
const submitFormulir = async (req, res) => {
  try {
    const { task_id } = req.params;

    // Cek formulir ada
    const [formulir] = await pool.query(
      'SELECT id FROM formulir_pendataan WHERE task_id = ?',
      [task_id]
    );

    if (formulir.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Formulir belum diisi. Isi formulir terlebih dahulu.',
      });
    }

    // Update status
    await pool.query(
      "UPDATE formulir_pendataan SET status_sync = 'synced', synced_at = NOW() WHERE task_id = ?",
      [task_id]
    );
    await pool.query(
      "UPDATE survey_tasks SET status_task = 'completed' WHERE id = ?",
      [task_id]
    );

    return res.status(200).json({
      success: true,
      message: 'Formulir berhasil disubmit. Status: Completed.',
    });
  } catch (error) {
    console.error('submitFormulir error:', error);
    return res.status(500).json({ success: false, message: 'Gagal submit formulir.' });
  }
};

// ─────────────────────────────────────────────────────────────
// GET FORMULIR BY TASK  —  GET /api/formulir/:task_id
// ─────────────────────────────────────────────────────────────
const getFormulirByTask = async (req, res) => {
  try {
    const { task_id } = req.params;

    const [formulir] = await pool.query(
      `SELECT f.*, t.nop, t.nama_wp, t.alamat_op, t.status_task
       FROM formulir_pendataan f
       JOIN survey_tasks t ON f.task_id = t.id
       WHERE f.task_id = ?`,
      [task_id]
    );

    if (formulir.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Formulir belum diisi untuk task ini.',
      });
    }

    // Parse JSON fasilitas
    const data = formulir[0];
    if (data.fasilitas && typeof data.fasilitas === 'string') {
      try { data.fasilitas = JSON.parse(data.fasilitas); } catch (_) { }
    }

    return res.status(200).json({ success: true, data });
  } catch (error) {
    console.error('getFormulirByTask error:', error);
    return res.status(500).json({ success: false, message: 'Gagal mengambil formulir.' });
  }
};

// ─────────────────────────────────────────────────────────────
// GET STATS  —  GET /api/formulir/stats
// Ringkasan data untuk dashboard
// ─────────────────────────────────────────────────────────────
const getStats = async (req, res) => {
  try {
    const [[totalRow]] = await pool.query('SELECT COUNT(*) AS total FROM survey_tasks');
    const [[pendingRow]] = await pool.query("SELECT COUNT(*) AS total FROM survey_tasks WHERE status_task = 'pending'");
    const [[progressRow]] = await pool.query("SELECT COUNT(*) AS total FROM survey_tasks WHERE status_task = 'in_progress'");
    const [[doneRow]] = await pool.query("SELECT COUNT(*) AS total FROM survey_tasks WHERE status_task = 'completed'");

    return res.status(200).json({
      success: true,
      data: {
        total: totalRow.total,
        pending: pendingRow.total,
        in_progress: progressRow.total,
        completed: doneRow.total,
      },
    });
  } catch (error) {
    console.error('getStats error:', error);
    return res.status(500).json({ success: false, message: 'Gagal mengambil statistik.' });
  }
};

module.exports = {
  getAllTasks,
  getTaskById,
  saveFormulir,
  submitFormulir,
  getFormulirByTask,
  getStats,
};