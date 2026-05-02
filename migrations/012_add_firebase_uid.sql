-- Migration: 012_add_firebase_uid.sql

-- 1. Tambahkan kolom firebase_uid untuk Unified Firebase Social Login
ALTER TABLE users ADD COLUMN IF NOT EXISTS firebase_uid VARCHAR(255) UNIQUE DEFAULT NULL;
CREATE INDEX IF NOT EXISTS idx_users_firebase_uid ON users (firebase_uid);

-- 2. Update constraint auth_provider agar mendukung 'twitter'
ALTER TABLE users DROP CONSTRAINT IF EXISTS chk_auth_provider;
ALTER TABLE users ADD CONSTRAINT chk_auth_provider
    CHECK (auth_provider IN ('local', 'google', 'apple', 'github', 'twitter'));
