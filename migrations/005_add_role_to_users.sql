-- Migration: 005_add_role_to_users.sql
-- Run: psql -U postgres -d free_api_news -f migrations/005_add_role_to_users.sql

ALTER TABLE users ADD COLUMN IF NOT EXISTS role VARCHAR(20) NOT NULL DEFAULT 'user';

-- Constraint valid role values
ALTER TABLE users ADD CONSTRAINT chk_users_role
    CHECK (role IN ('user', 'admin'));

CREATE INDEX IF NOT EXISTS idx_users_role ON users (role);
