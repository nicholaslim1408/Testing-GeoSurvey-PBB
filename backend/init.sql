-- ============================================================
-- GeoSurvey PBB - Database Schema
-- Phase 1: User Authentication & Phase 2: Formulir
-- ============================================================

CREATE DATABASE IF NOT EXISTS geosurvey_pbb
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE geosurvey_pbb;

-- 1. Tabel users
CREATE TABLE IF NOT EXISTS users (
  id           INT AUTO_INCREMENT PRIMARY KEY,
  username     VARCHAR(100)  NOT NULL UNIQUE,
  email        VARCHAR(150)  NOT NULL UNIQUE,
  password     VARCHAR(255)  NOT NULL,           -- bcrypt hash
  full_name    VARCHAR(150)  NOT NULL,
  role         ENUM('enumerator', 'admin') NOT NULL DEFAULT 'enumerator',
  is_approved  TINYINT(1)    NOT NULL DEFAULT 0, -- 0 = pending, 1 = approved
  created_at   DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at   DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP
                             ON UPDATE CURRENT_TIMESTAMP
);

-- 2. Seed Admin & Enumerator (Untuk Testing)
INSERT IGNORE INTO users (username, email, password, full_name, role, is_approved)
VALUES 
(
  'admin',
  'admin@geosurvey.id',
  '$2b$12$YI9Df2otrWHRp2yAld0r.OTA1maTMileUuv0ZUJFUxn0N/usYmhDO', -- Password: Admin@1234
  'Administrator',
  'admin',
  1
),
(
  'petugas1',
  'petugas1@geosurvey.id',
  '$2b$12$YI9Df2otrWHRp2yAld0r.OTA1maTMileUuv0ZUJFUxn0N/usYmhDO', -- Password: Admin@1234
  'Petugas Enumerator 1',
  'enumerator',
  1
);

-- 3. Tabel survey_tasks
CREATE TABLE IF NOT EXISTS survey_tasks (
  id              INT AUTO_INCREMENT PRIMARY KEY,
  nop             VARCHAR(30)   NOT NULL UNIQUE,
  nama_wp         VARCHAR(150)  NOT NULL,
  alamat_op       TEXT          NOT NULL,
  kd_propinsi     VARCHAR(5)    NOT NULL DEFAULT '32',
  kd_dati2        VARCHAR(5)    NOT NULL DEFAULT '04',
  kd_kecamatan    VARCHAR(10)   NOT NULL,
  kd_kelurahan    VARCHAR(10)   NOT NULL,
  kd_blok         VARCHAR(10)   NOT NULL,
  no_urut         VARCHAR(10)   NOT NULL,
  kd_jns_op       VARCHAR(5)    NOT NULL DEFAULT '0',
  status_task     ENUM('pending','in_progress','completed') NOT NULL DEFAULT 'pending',
  assigned_to     INT           NULL,
  latitude        DECIMAL(10,8) NULL,
  longitude       DECIMAL(11,8) NULL,
  created_at      DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at      DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP
                               ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (assigned_to) REFERENCES users(id) ON DELETE SET NULL
);

-- 4. Tabel formulir_pendataan
CREATE TABLE IF NOT EXISTS formulir_pendataan (
  id              INT AUTO_INCREMENT PRIMARY KEY,
  task_id         INT           NOT NULL,
  enumerator_id   INT           NOT NULL,
  nop             VARCHAR(30)   NOT NULL,
  luas_bumi       DECIMAL(10,2) NOT NULL DEFAULT 0,
  jenis_bumi      VARCHAR(50)   NULL,
  kondisi_tanah   ENUM('baik','sedang','buruk') NULL,
  luas_bangunan   DECIMAL(10,2) NOT NULL DEFAULT 0,
  jumlah_lantai   INT           NOT NULL DEFAULT 1,
  tahun_dibangun  INT           NULL,
  kondisi_bangunan ENUM('baik','sedang','buruk') NULL,
  material_dinding  VARCHAR(100) NULL,
  material_atap     VARCHAR(100) NULL,
  material_lantai   VARCHAR(100) NULL,
  fasilitas       JSON          NULL,
  catatan         TEXT          NULL,
  status_sync     ENUM('draft','synced','failed') NOT NULL DEFAULT 'draft',
  synced_at       DATETIME      NULL,
  created_at      DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at      DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP
                               ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (task_id)       REFERENCES survey_tasks(id) ON DELETE CASCADE,
  FOREIGN KEY (enumerator_id) REFERENCES users(id)        ON DELETE CASCADE
);

-- 5. Seed Survey Tasks
INSERT IGNORE INTO survey_tasks
  (nop, nama_wp, alamat_op, kd_kecamatan, kd_kelurahan, kd_blok, no_urut, kd_jns_op, status_task, latitude, longitude)
VALUES
  ('32.04.010.001.001.0001.0', 'BUDI SANTOSO', 'JL. MERDEKA NO. 12, RT 001/002', '010','001','001','0001','0', 'pending', -6.9147, 107.6098),
  ('32.04.010.001.001.0002.0', 'SITI RAHAYU', 'JL. PAHLAWAN NO. 45, RT 003/004', '010','001','001','0002','0', 'pending', -6.9152, 107.6105),
  ('32.04.010.001.002.0001.0', 'AHMAD FAUZI', 'JL. DIPONEGORO NO. 7, RT 002/001', '010','001','002','0001','0', 'pending', -6.9160, 107.6112),
  ('32.04.010.002.001.0001.0', 'DEWI LESTARI', 'JL. SUDIRMAN NO. 88, RT 001/003', '010','002','001','0001','0', 'pending', -6.9170, 107.6120),
  ('32.04.010.002.001.0002.0', 'HENDRA WIJAYA', 'JL. GATOT SUBROTO NO. 23', '010','002','001','0002','0', 'pending', -6.9178, 107.6130);
