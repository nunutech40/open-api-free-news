-- Migration: 003_create_categories_table.sql
-- Run: psql -U postgres -d free_api_news -f migrations/003_create_categories_table.sql

CREATE TABLE IF NOT EXISTS categories (
    id         BIGSERIAL PRIMARY KEY,
    name       VARCHAR(100)             NOT NULL,
    slug       VARCHAR(100)             NOT NULL UNIQUE,
    is_active  BOOLEAN                  NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_categories_slug      ON categories (slug);
CREATE INDEX IF NOT EXISTS idx_categories_is_active ON categories (is_active);

-- Seed default categories
INSERT INTO categories (name, slug) VALUES
    ('Technology', 'technology'),
    ('Finance',    'finance'),
    ('Sports',     'sports'),
    ('World',      'world'),
    ('Science',    'science')
ON CONFLICT (slug) DO NOTHING;
