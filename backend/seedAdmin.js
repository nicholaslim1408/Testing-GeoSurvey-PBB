// seedAdmin.js
// ============================================================
// Script untuk membuat akun admin pertama kali
// Jalankan SEKALI dengan: node seedAdmin.js
// ============================================================

require('dotenv').config();
const bcrypt   = require('bcrypt');
const { pool } = require('./config/db');

const seedAdmin = async () => {
  try {
    console.log('🌱 Starting admin seed...');

    // Cek apakah admin sudah ada
    const [existing] = await pool.query(
      "SELECT id FROM users WHERE username = 'admin'"
    );

    if (existing.length > 0) {
      console.log('⚠️  Admin sudah ada di database. Seed dibatalkan.');
      process.exit(0);
    }

    // Hash password admin
    const plainPassword  = 'Admin@1234';
    const hashedPassword = await bcrypt.hash(plainPassword, 12);

    // Insert admin
    const [result] = await pool.query(
      `INSERT INTO users (username, email, password, full_name, role, is_approved)
       VALUES (?, ?, ?, ?, 'admin', 1)`,
      ['admin', 'admin@geosurvey.id', hashedPassword, 'Administrator']
    );

    console.log('✅ Admin berhasil dibuat!');
    console.log('   ID       :', result.insertId);
    console.log('   Username : admin');
    console.log('   Password : Admin@1234');
    console.log('   Email    : admin@geosurvey.id');
    console.log('');
    console.log('⚠️  PENTING: Ganti password admin setelah login pertama kali!');
    process.exit(0);
  } catch (error) {
    console.error('❌ Seed gagal:', error.message);
    process.exit(1);
  }
};

seedAdmin();