// config/db.js
// ============================================================
// Koneksi ke MySQL menggunakan connection pool (lebih efisien)
// Pool otomatis mengelola banyak koneksi secara bersamaan
// ============================================================

const mysql = require('mysql2/promise');
require('dotenv').config();

// Buat connection pool
const pool = mysql.createPool({
  host:               process.env.DB_HOST     || 'localhost',
  port:               parseInt(process.env.DB_PORT) || 3306,
  user:               process.env.DB_USER     || 'root',
  password:           process.env.DB_PASSWORD || '',
  database:           process.env.DB_NAME     || 'geosurvey_pbb',
  waitForConnections: true,    // Tunggu jika semua koneksi sedang dipakai
  connectionLimit:    10,      // Maksimal 10 koneksi bersamaan
  queueLimit:         0,       // 0 = unlimited queue
  charset:            'utf8mb4',
});

// Fungsi untuk test koneksi saat server pertama kali start
const testConnection = async () => {
  try {
    const connection = await pool.getConnection();
    console.log('✅ MySQL connected successfully to database:', process.env.DB_NAME);
    connection.release(); // Kembalikan koneksi ke pool
  } catch (error) {
    console.error('❌ MySQL connection failed:', error.message);
    process.exit(1); // Hentikan server jika DB tidak bisa konek
  }
};

module.exports = { pool, testConnection };