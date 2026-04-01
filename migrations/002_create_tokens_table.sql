-- Migration: 002_create_tokens_table.sql
-- Run: psql -U postgres -d free_api_news -f migrations/002_create_tokens_table.sql

CREATE TABLE IF NOT EXISTS tokens (
    id             BIGSERIAL PRIMARY KEY,
    user_id        BIGINT                   NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    access_token   TEXT                     NOT NULL,
    refresh_token  TEXT                     NOT NULL UNIQUE,
    access_expiry  TIMESTAMP WITH TIME ZONE NOT NULL,
    refresh_expiry TIMESTAMP WITH TIME ZONE NOT NULL,
    is_revoked     BOOLEAN                  NOT NULL DEFAULT FALSE,
    created_at     TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_tokens_user_id       ON tokens (user_id);
CREATE INDEX IF NOT EXISTS idx_tokens_refresh_token ON tokens (refresh_token);
CREATE INDEX IF NOT EXISTS idx_tokens_is_revoked    ON tokens (is_revoked);

-- Auto-cleanup: delete expired tokens (can also be called via cron / app scheduler)
-- DELETE FROM tokens WHERE refresh_expiry < NOW();
