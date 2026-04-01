-- Migration: 004_create_articles_table.sql
-- Run: psql -U postgres -d free_api_news -f migrations/004_create_articles_table.sql

CREATE TABLE IF NOT EXISTS articles (
    id                BIGSERIAL PRIMARY KEY,
    category_id       BIGINT                   NOT NULL REFERENCES categories(id) ON DELETE RESTRICT,
    author_id         BIGINT                   NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    title             VARCHAR(500)             NOT NULL,
    slug              VARCHAR(500)             NOT NULL UNIQUE,
    excerpt           TEXT,
    content           TEXT                     NOT NULL,
    image_url         TEXT,
    thumbnail_url     TEXT,
    read_time_minutes INTEGER                  NOT NULL DEFAULT 1,
    status            VARCHAR(20)              NOT NULL DEFAULT 'draft',
    published_at      TIMESTAMP WITH TIME ZONE,
    created_at        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Constraint valid status values
ALTER TABLE articles ADD CONSTRAINT chk_articles_status
    CHECK (status IN ('draft', 'published', 'archived'));

CREATE INDEX IF NOT EXISTS idx_articles_category_id  ON articles (category_id);
CREATE INDEX IF NOT EXISTS idx_articles_author_id    ON articles (author_id);
CREATE INDEX IF NOT EXISTS idx_articles_slug         ON articles (slug);
CREATE INDEX IF NOT EXISTS idx_articles_status       ON articles (status);
CREATE INDEX IF NOT EXISTS idx_articles_published_at ON articles (published_at DESC);
