-- Migration: 011_add_oauth_support.sql

-- 1. password jadi nullable (Google user tidak punya password)
ALTER TABLE users ALTER COLUMN password DROP NOT NULL;
ALTER TABLE users ALTER COLUMN password SET DEFAULT NULL;

-- 2. simpan Google ID untuk lookup returning user
ALTER TABLE users ADD COLUMN IF NOT EXISTS google_id VARCHAR(255) UNIQUE DEFAULT NULL;

-- 3. track metode registrasi
ALTER TABLE users ADD COLUMN IF NOT EXISTS auth_provider VARCHAR(20) NOT NULL DEFAULT 'local';

ALTER TABLE users ADD CONSTRAINT chk_auth_provider
    CHECK (auth_provider IN ('local', 'google', 'apple', 'github'));

CREATE INDEX IF NOT EXISTS idx_users_google_id ON users (google_id);
